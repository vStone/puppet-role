require 'spec_helper'

describe 'role::translate_with_map' do
  it { is_expected.to run.with_params.and_raise_error(%r{expects .* arguments}) }
  it { is_expected.to run.with_params('foobar').and_raise_error(%r{expects .* arguments}) }
  it { is_expected.to run.with_params('__', 1).and_raise_error(%r{map.*expects}) }

  it do
    is_expected.to run.with_params(
      'foo__bar/xyz', '_[_]+' => '::', '/+' => '::'
    ).and_return('foo::bar::xyz')
  end

  it do
    is_expected.to run.with_params(
      'foo::bar', { '__' => '::' }, true
    ).and_raise_error(%r{'::' found in 'foo::bar'})
  end
end
