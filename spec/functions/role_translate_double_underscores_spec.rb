require 'spec_helper'

describe 'role::translate_double_underscores' do
  it { is_expected.to run.with_params.and_raise_error(%r{expects 1 argument}) }
  it { is_expected.to run.with_params(1).and_raise_error(%r{role.*expects}) }

  it { is_expected.to run.with_params('foo__bar').and_return('foo::bar') }
  it { is_expected.to run.with_params('foo__bar__xyz').and_return('foo::bar::xyz') }
  it { is_expected.to run.with_params('foo____bar').and_return('foo::bar') }
end
