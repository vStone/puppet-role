require 'spec_helper'

describe 'Role::ResolveMethod' do
  it { is_expected.not_to allow_values('_nope_') }
end
