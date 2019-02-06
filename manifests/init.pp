# Assigns the correct role to each node.
#
# It acts as a proxy which allows you to store your roles in a different namespaced
# module. For a single host, you can also use a specific configuration (upstream / shared
# roles and profiles).
#
# To get started, you should define the namespace to use.
#
# @param namespace The module namespace that holds your roles. If you are not using namespaces and map
#   roles directly to class names, make this an empty string ('').
# @param separator Anything to put in between the namespace and the role.
# @param resolve_order The order in which we will be looking for the correct
#   role to use. Currently supported values are:
#   * `trusted`: Use a trusted fact. The name must be configured using `trusted_extension_name`.
#   * `fact`: Use a fact. The name must be configured using `fact_name`.
#   * `param`: Uses the provided `role` parameter. This can also be used to configure using hiera.
#   * `default`: Fall back to the default value. You would typically put this after other methods.
#   * `fail`: Fail the run if this method is reached. This enforces setting up a role and skips using the default role.
#   * `callback`: BROKEN. DO NOT USE (yet). Use a function callback. The function must be configured using `function_callback_name`.
#
# @param role The role this node should get.
# @param trusted_extension_name Name of the trusted fact (extension).
# @param fact_name Name of the fact that contains the role.
#
# @param default_role the default role to assume.
# @param default_namespace namespace to use if the default is used.
# @param default_separator separator to use if the default is used.
#
class role (
  String $namespace,
  String $separator = '::',
  Array[Role::ResolveMethod] $resolve_order = ['param', 'default'],

  Optional[String[1]] $role                   = undef,
  Optional[String[1]] $trusted_extension_name = undef,
  Optional[String[1]] $fact_name              = undef,
  # Optional[String[1]] $function_callback_name = undef,

  String $default_role      = 'default',
  String $default_namespace = '::role',
  String $default_separator = '::',
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
      #'callback': {
      #  if $function_callback_name {
      #    $deferred = Deferred($function_callback_name)
      #    $resolved = $deferred.call()
      #    #$resolved = call($function_callback_name)
      #    }
      #    else {
      #     $resolved = undef
      #   }
      # }
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
