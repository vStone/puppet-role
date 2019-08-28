# Translate a role by executing a gsubstr(pattern, value, 'G') with patterns and
# values from the provided map.
#
# @param role Role to perform translate on.
# @param map A map with gsubstr translations with key as pattern and value
#   as replacement.
# @param strict Experimental parameter. If enabled, fails the puppet run when
#   a role includes characters that are in the target map present as values.
#   This would indicate that a role is being provided which would not
#   have expected replacement values in use. (This could happen during a migration,
#   for example.
# @return [String] Translated role.
function role::translate_with_map(
  String $role,
  Hash[
    Variant[String, Regexp],
    String
  ] $map,
  Boolean $strict = false,
) >> String {
  $map.reduce($role) |String $memo, Tuple[Variant[String, Regexp], String] $translate| {
    if $translate[1] in $role {
      if $strict {
        fail("Role includes remapped values: '${translate[1]}' found in '${role}'")
      }
      else {
        warning("Role includes remapped values: '${translate[1]}' found in '${role}'")
      }
    }
    $memo.regsubst($translate[0], $translate[1], 'G')
  }
}
