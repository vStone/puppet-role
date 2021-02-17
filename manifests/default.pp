# Dummy default role that does nothing.
class role::default {

  notify {'The role module usage':
    message => @("USAGE")
    ==============================
    Looks this node is using the default role. This means that the role module
    probably not has been properly initialized.

    You should override the `default_prefix` parameter with your own prefix and
    optionally supply a default_role.
    ==============================
    | - USAGE
  }

}
