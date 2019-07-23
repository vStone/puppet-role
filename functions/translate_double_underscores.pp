# Translates all double (or more) underscores in a role to '::'
#
# @param role Role to perform translate on.
# @return [String] Translated role.
function role::translate_double_underscores(String $role) >> String {
  role::translate_with_map($role, {/_[_]+/ => '::' })
}
