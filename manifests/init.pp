# Assigns the correct role to each node.
#
# We determine the role by following order, stopping at the first
# defined value:
#   * provided parameter (or hiera)
#   * An fact named $fact_name
#   * 'default'
#
# The role name does not need to include the namespace '::role'
#
# It acts as a proxy which allows you to store your roles in a different namespaced
# module. For a single host, you can also use a specific configuration (upstream / shared
# roles and profiles for example. It's not a thing yet, but it will happen.
#
# @param role The role this node should get.
# @param namespace The module namespace that holds your roles.
#   If undef, the role name will be the class to include.
#   Otherwise, the $separator will be used to glue it with the namespace.
# @param separator Anything to put in between the namespace and the role.
# @param fact_name Name of the fact that contains the role.
#
# @param default_role the default role to assume.
# @param default_namespace namespace to use if the default is used.
# @param default_separator separator to use if the default is used.
#
class role (
  Optional[String[1]] $role      = undef,

  Optional[String[1]] $trusted_extension_name           = undef,
  Optional[String[1]] $fact_name              = undef,
  Optional[String[1]] $function_callback_name = undef,

  String           $namespace = '',
  String           $separator = '::',

  String           $default_role = 'default',
  String           $default_namespace = '::role',
  String           $default_separator = '::',

  Array[Role::ResolveMethod] $resolve_order = ['default'],
  #Array[Role::ResolveMethod] $resolve_order = ['trusted', 'param', 'fact', 'callback', 'default'],
) {

  # Check if the required 'configuration' is present
  if 'trusted' in $resolve_order {
    assert_type(String[1], $trusted_extension_name)
  }
  if 'fact' in $resolve_order {
    assert_type(String[1], $fact_name)
  }
  if 'callback' in $resolve_order {
    assert_type(String[1], $function_callback_name)
  }

  $resolve_array = $resolve_order.map |String $method| {
    case $method {
      'param' : {
        if $role {
          $resolved = $role
        }
        else {
          $resolved = undef
          next()
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
          $deferred = Deferred($function_callback_name)
          $resolved = $deferred.call()
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
        $tried = $resolve_order.reduce([]) |$tries, $method| {
          if ($method == 'fail') { break() }
          $tries + $method
        }.join(', ')
        fail("Unable to resolve a role and hard failure requested. Attempted methods: ${tried}.")
      }
      default: {
        $resolved = undef
        break()
      }
    }
    $resolved
  }.filter |$value| { $value =~ NotUndef }

  if size($resolve_array) == 0 {
    $resolved = $default_role
    $_namespace = $default_namespace
    $_separator = $default_separator
  } else {
    $resolved = $resolve_array[0]
    $_namespace = $namespace ? {
      undef   => '',
      default => $namespace,
    }
    $_separator = $separator
  }

  include "${_namespace}${_separator}${resolved}"
}
