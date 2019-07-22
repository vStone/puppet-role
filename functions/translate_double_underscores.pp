function role::translate_double_underscores(String $role) >> String {
  $role.regsubst(/_[_]+/, '::', 'G')
}
