require 'spec_helper'

describe 'Role::SearchNamespace' do
  it { is_expected.to allow_values('single') }
  it { is_expected.to allow_values('') }
  it { is_expected.to allow_values('with' => 'separator') }
  it { is_expected.to allow_values('empty' => nil) }
  it { is_expected.to allow_values('' => '__') }
  it { is_expected.not_to allow_values(1) }
  it { is_expected.not_to allow_values(true) }
  it { is_expected.not_to allow_values([]) }
  it { is_expected.not_to allow_values('foo' => ['bar']) }
end
