require 'spec_helper'

describe 'cron' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'with default parameters' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('cron') }
          it { is_expected.to create_cron__user('root') }
          it { is_expected.to create_simpcat_build('cron') }
          it { is_expected.to create_file('/etc/cron.deny').with({:ensure => 'absent'}) }
          it { is_expected.to create_service('crond').with({
            :ensure     => 'running',
            :enable     => true,
            :hasstatus  => true,
            :hasrestart => true
          }) }
        end

        context 'with a users parameter' do
          let(:params) {{
            :users => ['test','foo','bar']
          }}
          it { is_expected.to create_cron__user('test') }
          it { is_expected.to create_cron__user('foo') }
          it { is_expected.to create_cron__user('bar') }
        end

        context 'only install tmpwatch on el6' do
          if facts[:os][:release][:major] == 6
            it { is_expected.to create_package('tmpwatch') }
          else
            it { is_expected.not_to create_package('tmpwatch') }
          end
        end

      end
    end
  end
end
