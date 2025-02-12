# Translates all (repeated) slashes in a role to '::'
#
# @param role Role to perform translate on.
# @return [String] Translated role.
function role::translate_slash(String $role) >> String {
  role::translate_with_map($role, { '[/]+' => '::' })
}
