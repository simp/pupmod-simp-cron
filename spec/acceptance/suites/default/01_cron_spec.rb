require 'spec_helper_acceptance'

test_name 'cron'

describe 'cron class' do
  let(:manifest) {
    <<-EOS
      include 'cron'
    EOS
  }
  let(:manifest_users) {
    <<-EOS
      class {'cron':
        users => [' joe', 'emily']
      }

      cron::user { ' nick ':}
    EOS
  }
  let(:expected_content) {
    <<-EOS
emily
joe
nick
root
    EOS
  }

  context 'on each host' do
    hosts.each do |host|
      it 'should work with default values' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, :catch_changes => true)
      end

      it 'should add users' do
        apply_manifest_on(host, manifest_users, :catch_failures => true)
        on(host, 'cat /etc/cron.allow') do
          expect(stdout).to match(expected_content)
        end
      end
    end
  end
end
