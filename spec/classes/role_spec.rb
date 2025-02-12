require 'spec_helper'

describe 'role' do
  let(:params) do
    { namespace: 'my_roles' }
  end

  context 'using minimal configuration (namespace)' do
    let(:params) { super() }

    it { is_expected.to compile }
    it { is_expected.to contain_class('role::default') }
  end

  context 'parameters' do
    context '(search_)namespace(s)' do
      let(:params) do
        { resolve_order: 'param', role: 'param_role' }
      end

      context 'validate' do
        describe 'neither provided' do
          let(:params) { super() }

          it do
            is_expected.to compile.and_raise_error(%r{namespace or a not empty search_namespaces})
          end
        end
        describe 'search_namespaces empty' do
          let(:params) { super().merge(search_namespaces: []) }

          it do
            is_expected.to compile.and_raise_error(%r{namespace or a not empty search_namespaces})
          end
        end
      end

      {
        'namespace' => { namespace: 'my_roles' },
        'search_namespaces' => { search_namespaces: ['other_namespace', 'my_roles'] },
        'both' => { namespace: 'my_roles', search_namespaces: ['other_namespace', 'other2'] },
      }.each do |provided, parms|
        describe "#{provided} provided" do
          let(:params) do
            super().merge(parms)
          end

          it do
            is_expected.to compile
            is_expected.to contain_class('my_roles::param_role')
          end
        end
      end
    end

    describe 'separator' do
      let(:pre_condition) do
        'class role_bar() {}'
      end
      let(:params) do
        {
          separator: '_',
          namespace: 'role',
          resolve_order: ['param', 'default'],
          role: 'bar',
        }
      end

      it { is_expected.to contain_class('role_bar') }
    end

    context 'resolve_order' do
      describe 'as single value' do
        let(:params) do
          super().merge(resolve_order: 'param', role: 'param_role')
        end

        it do
          is_expected.to compile
          is_expected.to contain_class('my_roles::param_role')
        end
      end

      describe 'as an array' do
        let(:params) do
          super().merge(resolve_order: ['param', 'default'], role: 'param_role')
        end

        it do
          is_expected.to compile
          is_expected.to contain_class('my_roles::param_role')
        end
      end
    end

    context 'method dependent parameters' do
      ['trusted', 'fact', 'callback'].each do |method|
        describe "with method => #{method}" do
          let(:params) do
            {
              resolve_order: [method],
              namespace: 'foobar',
            }
          end

          it do
            is_expected.to compile.and_raise_error(%r{You should specify the (trusted_extension_name|fact_name|function_callback_name) when (trusted|fact|callback) is used})
          end
        end
      end
    end
  end

  context 'translate role callback' do
    let(:pre_condition) do
      'class ns::foo::bar::xyz() {}'
    end
    let(:trusted_facts) do
      {
        'pp_role' => 'foo__bar__xyz',
      }
    end
    let(:params) do
      {
        namespace: 'ns',
        resolve_order: ['trusted'],
        trusted_extension_name: 'pp_role',
      }
    end

    describe 'with function name' do
      let(:params) do
        super().merge(translate_role_callback: 'role::translate_double_underscores')
      end

      it do
        skip 'Unsupported on puppet 4.x' if %r{^4\.}.match?(Puppet.version)
        is_expected.to contain_class('ns::foo::bar::xyz')
      end
    end

    describe 'with hash map' do
      let(:trusted_facts) do
        {
          'pp_role' => 'foo__bar//xyz',
        }
      end
      let(:params) do
        super().merge(
          translate_role_callback: {
            '_[_]+' => '::',
            '/+' => '::',
          },
        )
      end

      it { is_expected.to contain_class('ns::foo::bar::xyz') }
    end
  end

  context 'namespace configuration' do
    describe 'empty string' do
      let(:pre_condition) do
        'class foo::bar() {}'
      end

      let(:params) do
        {
          namespace: '',
          resolve_order: ['param', 'default'],
          role: 'foo::bar',
        }
      end

      it { is_expected.to contain_class('foo::bar') }
    end

    describe 'provided' do
      let(:pre_condition) do
        'class my_namespace::foo::bar() {}'
      end

      let(:params) do
        {
          namespace: 'my_namespace',
          resolve_order: ['param', 'default'],
          role: 'foo::bar',
        }
      end

      it { is_expected.to contain_class('my_namespace::foo::bar') }
    end
  end

  context 'search namespaces configuration' do
    let(:pre_condition) do
      '
      class my_namespace::spaced() {}
      class my_otherspace::spaced() {}
      class my_prefix_spaced() {}
      class emptyspaced() {}
      '
    end

    let(:params) do
      {
        separator: '::',
        resolve_order: 'param',
        role: 'spaced',
      }
    end

    describe 'no match in namespaces' do
      let(:params) do
        super().merge(search_namespaces: ['does_not_exist', 'also_does_not_exist'])
      end

      it do
        is_expected.to compile.and_raise_error(%r{role '[^']*' not found on any of the search namespaces})
      end
    end

    describe 'use first match' do
      let(:params) do
        super().merge(search_namespaces: ['my_otherspace', 'my_namespace'])
      end

      it do
        is_expected.to compile
        is_expected.to contain_class('my_otherspace::spaced')
      end
    end

    describe 'double empty' do
      let(:params) do
        super().merge(role: 'emptyspaced', search_namespaces: [{ '' => '' }])
      end

      it do
        is_expected.to compile
        is_expected.to contain_class('emptyspaced')
      end
    end

    describe 'with separator config' do
      let(:params) do
        super().merge(search_namespaces: [{ 'my_prefix' => '_' }])
      end

      it do
        is_expected.to compile
        is_expected.to contain_class('my_prefix_spaced')
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

    describe 'callback' do
      let(:params) do
        super().merge(
          resolve_order: ['callback'],
          function_callback_name: 'my_roles::role_callback',
        )
      end

      it do
        skip 'Unsupported in puppet 4.x' if %r{^4\.}.match?(Puppet.version)
        is_expected.to contain_class('my_roles::function_role')
      end
    end
  end

  context 'resolve ordering' do
    describe 'skip until match is found' do
      let(:params) do
        super().merge(
          resolve_order: ['trusted', 'fact', 'param', 'default'],
          role: 'param_role',
          trusted_extension_name: 'pp_role',
          fact_name: 'role',
        )
      end

      it do
        is_expected.to contain_class('my_roles::param_role')
      end
    end

    context 'with fail' do
      describe 'it fails when no match is found' do
        let(:params) do
          super().merge(
            resolve_order: ['trusted', 'fact', 'fail', 'param'],
            role: 'param_role',
            trusted_extension_name: 'pp_role',
            fact_name: 'role',
          )
        end

        it do
          is_expected.to compile.and_raise_error(%r{Attempted methods: trusted, fact\.})
        end
      end

      describe 'it does not fail with a match' do
        let(:params) do
          super().merge(
            resolve_order: ['trusted', 'fact', 'fail', 'param'],
            role: 'param_role',
            trusted_extension_name: 'pp_role',
            fact_name: 'role',
          )
        end
        let(:facts) do
          { role: 'fact_role' }
        end

        it do
          is_expected.to compile
          is_expected.to contain_class('my_roles::fact_role')
        end
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
            resolve_order: ['trusted', 'fact', 'param'],
          )
        end

        it do
          is_expected.to contain_class('my_roles::trusted_role')
        end
      end
      describe 'param > trusted > fact' do
        let(:params) do
          super().merge(
            resolve_order: ['param', 'trusted', 'fact'],
          )
        end

        it do
          is_expected.to contain_class('my_roles::param_role')
        end
      end
    end
  end
end
