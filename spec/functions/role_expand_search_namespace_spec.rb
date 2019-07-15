require 'spec_helper'

describe 'role::expand_search_namespaces' do
  it { is_expected.to run.with_params.and_raise_error(%r{expects 2 arguments}) }
  it { is_expected.to run.with_params('__').and_raise_error(%r{expects 2 arguments}) }
  it { is_expected.to run.with_params('__', 1).and_raise_error(%r{expects a value of type}) }
  context 'expand' do
    it do
      is_expected.to run.with_params('_sep_', 'simple').and_return('simple' => '_sep_')
    end

    it do
      is_expected.to run.with_params(
        '_sep_',
        [
          '',
          { 'nil' => nil },
          { 'weird' => ':_:' },
        ],
      ).and_return('' => '_sep_',
                   'nil' => '_sep_',
                   'weird' => ':_:')
    end
  end
end
