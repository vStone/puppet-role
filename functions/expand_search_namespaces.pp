# This function is used to sanitize `Role::SearchNamespace`s and return
# a single map with namespace - separator entries.
#
# @example hiera configured namespaces
#
#   $search_namespaces = [
#     '',
#     { 'my_roles' => '_' },
#     'public_roles',
#   ]
#   $expanded = role::expand_search_namespaces('::', $search_namespaces)
#   # => {'' => '::', 'my_roles' => '_', 'public_roles' => '::' }
#
#
# @param separator Default separator to use when the namespace does not provide one.
# @param search `Role::SearchNamespace`s to expand.
# @return [Hash[String, String]] Expanded configuration.
function role::expand_search_namespaces(
  String $separator,
  Variant[Role::SearchNamespace, Array[Role::SearchNamespace]] $search,
) >> Hash[String, String] {


  $namespaces = [$search].flatten.unique.reduce({}) |Hash[String, String] $memo, Role::SearchNamespace $space| {
    if $space =~ String {
      $memo + { $space => $separator }
    }
    else {
      $memo + $space.reduce({}) |Hash[String, String] $spaces, Tuple $kv| {
        $key = $kv[0]
        $value = $kv[1]
        $_value = $value ? {
          undef   => $separator,
          default => $value,
        }
        $memo + { $key =>  $_value }
      }
    }
  }
}
