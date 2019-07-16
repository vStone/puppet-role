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
