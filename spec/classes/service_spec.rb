require 'spec_helper'

describe 'cron::service' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) do
          os_facts
        end

        context 'with default parameters' do
          it { is_expected.to create_service('crond').with({
            :ensure => 'running',
            :enable => true,
            :hasstatus => true,
            :hasrestart => true
            })
          }
        end

        context 'with parameters' do
          let(:params) {{
            :service_name => 'trevor',
            :enable => false
          }}

          it { is_expected.to create_service('trevor').with({
            :ensure => 'stopped',
            :enable => false,
            :hasstatus => true,
            :hasrestart => true
            })
          }
        end

      end
    end
  end
end
