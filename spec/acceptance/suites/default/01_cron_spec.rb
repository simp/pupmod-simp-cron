require 'spec_helper_acceptance'

test_name 'cron'

describe 'cron class' do
  let(:manifest) do
    <<-EOS
      include 'cron'
    EOS
  end
  let(:manifest_users) do
    <<-EOS
      class {'cron':
        users => [' joe', 'emily']
      }

      cron::user { ' nick ':}
    EOS
  end
  let(:expected_content) do
    <<-EOS
emily
joe
nick
root
    EOS
  end

  context 'on each host' do
    hosts.each do |host|
      it 'works with default values' do
        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end

      it 'adds users' do
        apply_manifest_on(host, manifest_users, catch_failures: true)
        on(host, 'cat /etc/cron.allow') do
          expect(stdout).to match(expected_content)
        end
      end
    end
  end
end
