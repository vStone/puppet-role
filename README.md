# role

[TOC levels=2-4]: # "#### Table of Contents"

#### Table of Contents
- [Introduction](#introduction)
- [Setup](#setup)
    - [Setup Requirements](#setup-requirements)
    - [Compatibility](#compatibility)
- [Quickstart: Configure your namespace.](#quickstart-configure-your-namespace)
- [Configuration](#configuration)
    - [resolve_order](#resolve_order)
    - [search_namespaces](#search_namespaces)
- [Notes](#notes)
    - [Windows Users](#windows-users)
    - [Trusted facts](#trusted-facts)
- [Development](#development)

## Introduction

This module aims to abstract resolving the correct role for your
machine. It supports several ways to figure out the role:

* Use trusted facts
* Use facts
* Use a parameter (allows configuration through hiera)
* Use a custom function (Note, only available on Puppet > 5.x)
* Fallback to a default
* or Fail if there is no role found.

It also allows setting up a waterfall mechanism: no trusted fact? how
about a regular one? a param?

## Setup

### Setup Requirements

Depending on how you want to use this module, you will need to learn
about:
* hiera
* trusted facts
* (custom) facts
* writing functions

On a puppet side: we depend on the stdlib module for additional
functions.

### Compatibility

Most functionality should be usable with > puppet 4.x with
the exception of features that depend on #call():

* `callback` in `role::resolve_order` is not supported on puppet < 5.x
* using a function name as `role::translate_role_callback` is not supported on puppet < 5.x

## Quickstart: Configure your namespace.

Include role in your (default) node.

`manifests/site.pp`:

```puppet
node 'default' {
  include role
}
```

Configure the namespace to use in hiera:

`hiera/common.yaml`:

```yaml
---
role::namespace: 'my_roles'
```

You can also define configuration parameters for the role module here. This will
disallow users to overwrite the configuration in hiera:

`manifests/site.pp`:

```puppet
node 'default' {
  class { 'role':
    namespace => 'my_roles'
  }
}
```

## Configuration

### resolve_order

Using the resolve order.

```yaml
---
role::namespace: 'my_roles'
role::resolve_order:
  - trusted
  - fact
  - param
  - default
```

Load a base profile directly as default role:

```yaml
---
role::default_namespace: ''
role::default_separator: ''
role::default_role: profile_base
```

Enforce setting up a role using trusted facts or fail the puppet run:

```yaml
role::resolve_order:
  - trusted
  - fail
```

### search_namespaces

It is possible to search for a role in multiple namespaces. To do this,
supply an (non-empty) array with namespaces to look in.

By example:

```yaml
role::separator: '::'
role::search_namespaces:
  - shared_roles
  - my_roles
  - {'': ''}
  - {customer: '_'}
```

The module will attempt to find the following classes (in order) for
role `foobar` and use the first one that exists.

- shared_roles::foobar
- my_roles::foobar
- foobar
- customer_foobar


**Note**: A namespace parameter will always take precedence. In hiera,
you can force a `undef` or `nil` value using `~`.

```yaml
role::namespace: ~
role::search_namespaces:
 - ''
 - {'my_roles': '::'}

```

## Notes

### Windows Users

When you have (puppet) developers that work on Windows workstations, you
should prevent using `::` (double colons) in your role names. Using such
a role (`foo::bar`) in combination with hiera could result in filenames
with `::` in them. This will effectively prevent any Windows user from
checking out the repository.

In stead, you can choose any other separator (`__` for example) and
remap the role to a class name using `translate_role_callback`. For role
`foo__bar`, the following example would result in `myspace::foo::bar`
being included.

```yaml
role::namespace: 'myspace'
role::translate_role_callback: 'role::translate_double_underscores'
```

### Trusted facts

If you intend to use trusted facts as classification for your roles,
take the following remarks into account:

* Do not use `trusted` in combination with facts in the `resolve_order`:
  Facts can easily be overridden on the agent side.
* Your hiera hierarchy should not use anything besides trusted facts.
  Same reason applies.

## Development

