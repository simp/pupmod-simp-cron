require 'spec_helper'

describe 'cron::user' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'with default parameters' do
          let(:title) { 'foobar' }
          it { is_expected.to create_simpcat_fragment('cron+foobar.user') }
          it { is_expected.to create_pam__access__manage('cron_user_foobar') }
        end

        context 'with a title that needs gsubbin' do
          let(:title) { 'foo/bar' }
          it { is_expected.to create_simpcat_fragment('cron+foo__bar.user') }
          it { is_expected.to create_pam__access__manage('cron_user_foo__bar') }
        end

      end
    end
  end
end
