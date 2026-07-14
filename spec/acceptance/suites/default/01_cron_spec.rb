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
      # Exercise noop from a clean (uninstalled) state: on a fresh node the Sicura
      # console previews the module with `puppet apply --noop`, which must not error
      # even though nothing cron manages exists yet. Real idempotence is covered
      # by the applies below. A post-convergence noop check is deliberately omitted:
      # `puppet apply --noop --detailed-exitcodes` always exits 0, so it could never
      # fail and would test nothing.
      context 'in noop mode from a clean state' do
        # Setup, not an assertion: as before(:context) a failure errors this context
        # rather than aborting the whole suite under .rspec's --fail-fast. `puppet
        # resource` exits 0 whether it removes the package or finds it already absent
        # (no --detailed-exitcodes), so no acceptable_exit_codes override is needed.
        before(:context) do
          on(host, 'puppet resource package cronie ensure=absent')
        end

        it 'applies without errors in noop mode' do
          apply_manifest_on(host, manifest, catch_failures: true, noop: true)
        end
      end

      it 'works with default values' do
        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end

      it 'adds users' do
        apply_manifest_on(host, manifest_users, catch_failures: true)
        result = on(host, 'cat /etc/cron.allow')
        expect(result.stdout).to match(expected_content)
      end
    end
  end
end
