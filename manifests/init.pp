# Assigns the correct role to each node.
#
# We determine the role by following order, stopping at the first
# defined value:
#   * provided parameter (or hiera)
#   * Global (scoped) variable or fact named `role`
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
# @param default_role the default role to assume.
# @param default_namespace namespace to use if the default is used.
# @param default_separator separator to use if the default is used.
class role (
  Optional[String] $role      = undef,
  Optional[String] $namespace = '::role',
  String           $separator = '::',

  String           $default_role = 'default',
  String           $default_namespace = '::role',
  String           $default_separator = '::',
) {

  if $role {
    $_role = $role
    $_isdefault = false
  }
  elsif defined('$::role') {
    $_role = $role
    $_isdefault = false
  }
  else {
    $_role = $default_role
    $_isdefault = true
  }

  if $_isdefault {
    $_namespace = $default_namespace
    $_separator = $default_separator
  }
  else {
    $_namespace = $namespace ? {
      undef   => '',
      default => $namespace,
    }
    $_separator = $separator
  }

  include "${_namespace}${_separator}${_role}"

}
