require 'spec_helper'

describe 'cron' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) do
          os_facts
        end

        context 'with default parameters' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('cron') }
          it { is_expected.to contain_class('cron::install')}
          it { is_expected.to contain_class('cron::service')}
          it { is_expected.to create_cron__user('root') }
          it { is_expected.to create_concat('/etc/cron.allow') }
          it { is_expected.to create_file('/etc/cron.deny').with({:ensure => 'absent'}) }
          #defaults for install
          it { is_expected.to create_package('cronie') }
          it { is_expected.not_to create_package('tmpwatch') }
        end

        context 'with a users parameter' do
          let(:params) {{
            :users => ['test','foo','bar']
          }}
          it { is_expected.to create_cron__user('test') }
          it { is_expected.to create_cron__user('foo') }
          it { is_expected.to create_cron__user('bar') }
        end

        context 'when not managing packages' do
          let(:params) {{
            :install_tmpwatch => true,
            :manage_packages  => false
          }}

          it { is_expected.to_not create_package('tmpwatch') }
          it { is_expected.to_not create_package('cronie') }
        end

        context 'when add_root_user is false' do
          let(:params) {{
            :add_root_user => false
          }}
          it { is_expected.to_not create_cron__user('root') }
        end
      end
    end
  end
end
