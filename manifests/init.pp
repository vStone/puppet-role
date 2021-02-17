# Assigns the correct role to each node.
#
# It acts as a proxy which allows you to store your roles in a different namespaced
# module. For a single host, you can also use a specific configuration (upstream / shared
# roles and profiles).
#
# To get started, you should define the namespace (or search_namespaces) to use.
#
# @param namespace The module namespace that holds your roles. If you are not using namespaces and map
#   roles directly to class names, make this an empty string ('').
# @param search_namespaces A list of namespaces to search. If using this, we will attempt to find the
#   first existing role in order. If no match is found, the puppet run will fail.
# @param separator Anything to put in between the namespace and the role.
# @param resolve_order The order in which we will be looking for the correct
#   role to use. Currently supported values are:
#   * `trusted`: Use a trusted fact. The name must be configured using `trusted_extension_name`.
#   * `fact`: Use a fact. The name must be configured using `fact_name`.
#   * `param`: Uses the provided `role` parameter. This can also be used to configure using hiera.
#   * `callback`: Use a function callback. The function must be configured using `function_callback_name`. (Not available on puppet 4.x!)
#   * `default`: Fall back to the default value. You would typically put this after other methods.
#   * `fail`: Fail the run if this method is reached. This enforces setting up a role and skips using the default role.
#
# @param role The role this node should get.
# @param trusted_extension_name Name of the trusted fact (extension).
# @param fact_name Name of the fact that contains the role.
# @param function_callback_name A function that returns the role.
# @param translate_role_callback Optionally, a function name that should be used or a map with gsubstr tuples.
#   * function name: A puppet function to call.
#       It should accept a single value and return a string. (Not available on puppet 4.x!)
#       See `role::translate_slash` and `role::translate_double_underscores` for examples.
#   * a Hash: A mapping with keypairs that is passed to `role::translate_with_map`.
#
# @param default_role the default role to assume. Used when no resolve method provides a result.
# @param default_namespace namespace to use if the default is used.
# @param default_separator separator to use if the default is used.
#
class role (
  Optional[String] $namespace = undef,
  String $separator = '::',
  Variant[Role::ResolveMethod, Array[Role::ResolveMethod]] $resolve_order = ['param', 'default'],

  Optional[String[1]] $role                   = undef,
  Optional[String[1]] $trusted_extension_name = undef,
  Optional[String[1]] $fact_name              = undef,
  Optional[String[1]] $function_callback_name = undef,
  Variant[Undef, String[1], Hash] $translate_role_callback = undef,

  Optional[Array[Role::SearchNamespace]] $search_namespaces = undef,

  String $default_role      = 'default',
  String $default_namespace = 'role',
  String $default_separator = '::',
) {

  # Check if the required 'configuration' is present
  if 'trusted' in $resolve_order {
    assert_type(String[1], $trusted_extension_name) |$_exp, $_actual| {
      fail('You should specify the trusted_extension_name when trusted is used in the resolve_array')
    }
  }
  if 'fact' in $resolve_order {
    assert_type(String[1], $fact_name) |$_exp, $_actual| {
      fail('You should specify the fact_name when fact is used in the resolve_array')
    }
  }
  if 'callback' in $resolve_order {
    assert_type(String[1], $function_callback_name) |$_exp, $_actual| {
      fail('You should specify the function_callback_name when callback is used in the resolve_array')
    }
  }
  unless $namespace or ($search_namespaces and size($search_namespaces) > 0) {
    fail('Either namespace or a not empty search_namespaces must be provided.')
  }

  $resolve_array = [$resolve_order].flatten.reduce([]) |Array[Optional[String]] $found, String $method| {
    case $method {
      'param' : {
        if $role {
          $resolved = $role
        }
        else {
          $resolved = undef
        }
      }
      'fact': {
        if $fact_name and has_key($::facts, $fact_name) {
          $resolved = $::facts[$fact_name]
        }
        else {
          $resolved = undef
        }
      }
      'callback': {
        if $function_callback_name {
          $resolved = call($function_callback_name)
        }
        else {
          $resolved = undef
        }
      }
      'trusted': {
        if $trusted_extension_name and has_key($::trusted['extensions'], $trusted_extension_name) {
          $resolved = $::trusted['extensions'][$trusted_extension_name]
        }
        else {
          $resolved = undef
        }
      }
      'fail': {
        if $found.filter |$value| { $value =~ NotUndef }.length() == 0 {
          $tried = $resolve_order.reduce([]) |$tries, $method| {
            if ($method == 'fail') { break() }
            $tries + $method
          }.join(', ')
          fail("Unable to resolve a role and hard failure requested. Attempted methods: ${tried}.")
        }
        break()
      }
      default: {
        $resolved = undef
        break()
      }
    }
    $found + [ $resolved ]
  }.filter |$value| { $value =~ NotUndef }

  # Nothing was resolved.
  if size($resolve_array) == 0 {
    include "${default_namespace}${default_separator}${default_role}"
  } else {
    $resolved = $translate_role_callback ? {
      undef   => $resolve_array[0],
      Hash    => role::translate_with_map($resolve_array[0], $translate_role_callback),
      default => call($translate_role_callback, $resolve_array[0]),
    }

    # namespace was provided.
    if $namespace {
      include "${namespace}${separator}${resolved}"
    }
    # search_namespaces
    else {
      # sanitize the array with namespaces
      $search = role::expand_search_namespaces($separator, $search_namespaces)
      # find roles with a class that actually exists
      $existing_roles = $search.map |String $space, String $separator| {
        $rolename = "${space}${separator}${resolved}"
        if defined($rolename) { $rolename }
        else { false }
      }.filter |$val| {
        $val =~ String
      }
      if size($existing_roles) > 0 {
        include $existing_roles[0]
      } else {
        fail("Requested role '${resolved}' not found on any of the search namespaces.")
      }
    }
  }
}
