function role::translate_slash(String $role) >> String {
  $role.regsubst('[/]+', '::', 'G')
}
