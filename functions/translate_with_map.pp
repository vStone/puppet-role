# Translate a role by executing a gsubstr(pattern, value, 'G') with patterns and
# values from the provided map.
#
# @param role Role to perform translate on.
# @param map A map with gsubstr translations with key as pattern and value
#   as replacement.
# @return [String] Translated role.
function role::translate_with_map(
  String $role,
  Hash[
    Variant[String, Regexp],
    String
  ] $map
) >> String {
  $map.reduce($role) |String $memo, Tuple[Variant[String, Regexp], String] $translate| {
    $memo.regsubst($translate[0], $translate[1], 'G')
  }
}
