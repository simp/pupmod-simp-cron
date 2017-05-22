require 'spec_helper'

describe 'cron::user' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with default parameters' do
        let(:title) { 'foobar' }
        it { is_expected.to create_simpcat_fragment('cron+foobar.user') }
        it { is_expected.not_to create_pam__access__rule('cron_user_foobar') }
      end

      context 'with pam => not false' do
        let(:title) { 'foobar' }
        let(:params) {{ :pam => true }}
        it { is_expected.to create_pam__access__rule('cron_user_foobar') }
      end

      context 'with a title that needs gsubbin' do
        let(:title) { 'foo/bar' }
        it { is_expected.to create_simpcat_fragment('cron+foo__bar.user') }
      end

    end
  end
end
