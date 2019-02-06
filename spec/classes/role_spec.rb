require 'spec_helper'

describe 'role' do
  let(:params) do
    { namespace: 'my_roles' }
  end

  context 'using defaults' do
    let(:params) do
      super()
    end

    it { is_expected.to compile }
    it { is_expected.to contain_class('role::default') }
  end

  context 'namespace configuration' do
    let(:params) { { } }

    describe 'missing' do
      it { is_expected.to compile.and_raise_error(/expects a value for parameter 'namespace'/) }
    end

    describe 'empty' do
      let(:pre_condition) do
        'class foo::bar() {}'
      end
      let(:params) do
        {
          namespace: '',
          resolve_order: %w[param default],
          role: 'foo::bar',
        }
      end

      it { is_expected.to contain_class('foo::bar') }
    end

    describe 'provided' do
      let(:pre_condition) do
        'class my_namespace::bar() {}'
      end
      let(:params) do
        {
          namespace: 'my_namespace',
          resolve_order: %w[param default],
          role: 'bar',
        }
      end

      it { is_expected.to contain_class('my_namespace::bar') }
    end

    describe 'separator' do
      let(:pre_condition) do
        'class role_bar() {}'
      end
      let(:params) do
        {
          separator: '_',
          namespace: 'role',
          resolve_order: %w[param default],
          role: 'bar',
        }
      end

      it { is_expected.to contain_class('role_bar') }
    end
  end

  context 'missing configuration parameters' do
    #%w[trusted fact callback].each do |method|
    %w[trusted fact].each do |method|
      context "with method => #{method}" do
        let(:params) do
          {
            resolve_order: [method],
            namespace: 'foobar',
          }
        end

        it do
          is_expected.to compile.and_raise_error(/expects a String value/)
        end
      end
    end
  end

  context 'resolve methods' do
    context 'default overrides' do
      let(:pre_condition) do
        'class custom_roles__default_role {}'
      end
      let(:params) do
        super().merge(
          resolve_order: ['default'],
          default_namespace: 'custom_roles',
          default_role: 'default_role',
          default_separator: '__',
        )
      end

      it do
        is_expected.to contain_class('custom_roles__default_role')
      end
    end

    describe 'trusted' do
      let(:trusted_facts) do
        {
          'pp_role' => 'trusted_role',
        }
      end
      let(:params) do
        super().merge(
          resolve_order: ['trusted'],
          trusted_extension_name: 'pp_role',
        )
      end

      it do
        is_expected.to contain_class('my_roles::trusted_role')
      end
    end

    describe 'param' do
      let(:params) do
        super().merge(
          resolve_order: ['param'],
          role: 'param_role',
        )
      end

      it do
        is_expected.to contain_class('my_roles::param_role')
      end
    end

    describe 'fact' do
      let(:facts) do
        { role: 'fact_role' }
      end
      let(:params) do
        super().merge(
          resolve_order: ['fact'],
          fact_name: 'role',
        )
      end

      it do
        is_expected.to contain_class('my_roles::fact_role')
      end
    end

    # describe 'callback' do
    #   let(:params) do
    #     super().merge(
    #       resolve_order: ['callback'],
    #       function_callback_name: 'my_roles::role_callback',
    #     )
    #   end

    #   it do
    #     is_expected.to contain_class('my_roles::function_role')
    #   end
    # end
  end

  context 'resolve ordering' do
    context 'skip until match is found' do
      let(:params) do
        super().merge(
          #resolve_order: %w[trusted fact param callback],
          resolve_order: %w[trusted fact param],
          role: 'param_role',
          trusted_extension_name: 'pp_role',
          fact_name: 'role',
          function_callback_name: 'my_roles::role_callback',
        )
      end

      it do
        is_expected.to contain_class('my_roles::param_role')
      end
    end

    context 'follow correct ordering' do
      let(:facts) do
        { role: 'fact_role' }
      end
      let(:trusted_facts) do
        { pp_role: 'trusted_role' }
      end
      let(:params) do
        super().merge(
          role: 'param_role',
          trusted_extension_name: 'pp_role',
          fact_name: 'role',
          function_callback_name: 'my_roles::role_callback',
        )
      end

      describe 'trusted > fact > param' do
        let(:params) do
          super().merge(
            resolve_order: %w[trusted fact param],
          )
        end

        it do
          is_expected.to contain_class('my_roles::trusted_role')
        end
      end
      describe 'param > trusted > fact' do
        let(:params) do
          super().merge(
            resolve_order: %w[param trusted fact],
          )
        end

        it do
          is_expected.to contain_class('my_roles::param_role')
        end
      end
    end

    describe 'stop when fail is in the ordering' do
      let(:params) do
        super().merge(
          resolve_order: %w[trusted fact fail],
          role: 'param_role',
          trusted_extension_name: 'pp_role',
          fact_name: 'role',
        )
      end

      it do
        is_expected.to compile.and_raise_error(/Attempted methods: trusted, fact\./)
      end
    end
  end
end
