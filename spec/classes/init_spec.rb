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
          it { is_expected.to contain_class('cron::install') }
          it { is_expected.to contain_class('cron::service') }
          it { is_expected.to create_cron__user('root') }
          it { is_expected.to create_concat('/etc/cron.allow') }
          it { is_expected.not_to create_file('/etc/cron.deny') }
          # defaults for install
          it { is_expected.to create_package('cronie') }
          it { is_expected.not_to create_package('tmpwatch') }
        end

        context 'with a users parameter' do
          let(:params) do
            {
              users: ['test', 'foo', 'bar']
            }
          end

          it { is_expected.to create_cron__user('test') }
          it { is_expected.to create_cron__user('foo') }
          it { is_expected.to create_cron__user('bar') }
        end

        context 'when not managing packages' do
          let(:params) do
            {
              install_tmpwatch: true,
           manage_packages: false
            }
          end

          it { is_expected.not_to create_package('tmpwatch') }
          it { is_expected.not_to create_package('cronie') }
        end

        context 'when add_root_user is false' do
          let(:params) do
            {
              add_root_user: false
            }
          end

          it { is_expected.not_to create_cron__user('root') }
        end

        context 'when cron_deny_ensure is absent' do
          let(:params) do
            {
              cron_deny_ensure: 'absent'
            }
          end

          it { is_expected.to create_file('/etc/cron.deny').with_ensure('absent') }
        end

        context 'when cron_deny_ensure is file' do
          let(:params) do
            {
              cron_deny_ensure: 'file'
            }
          end

          # Only the explicitly set attribute is managed; owner/group/mode
          # are left unmanaged
          it {
            is_expected.to create_file('/etc/cron.deny').with(
              ensure: 'file',
              owner: nil,
              group: nil,
              mode: nil,
            )
          }
        end

        context 'when cron_deny_mode is set' do
          let(:params) do
            {
              cron_deny_mode: '0600'
            }
          end

          it {
            is_expected.to create_file('/etc/cron.deny').with(
              ensure: nil,
              owner: nil,
              group: nil,
              mode: '0600',
            )
          }
        end

        context 'when cron_deny_owner and cron_deny_group are set' do
          let(:params) do
            {
              cron_deny_owner: 'root',
              cron_deny_group: 'root'
            }
          end

          it {
            is_expected.to create_file('/etc/cron.deny').with(
              ensure: nil,
              owner: 'root',
              group: 'root',
              mode: nil,
            )
          }
        end

        context 'when all cron_deny_* parameters are set' do
          let(:params) do
            {
              cron_deny_ensure: 'file',
              cron_deny_owner: 'root',
              cron_deny_group: 'root',
              cron_deny_mode: '0600'
            }
          end

          it {
            is_expected.to create_file('/etc/cron.deny').with(
              ensure: 'file',
              owner: 'root',
              group: 'root',
              mode: '0600',
            )
          }
        end
      end
    end
  end
end
