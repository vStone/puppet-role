# role

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with role](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with role](#beginning-with-role)
3. [Usage - Configuration options](#usage)
4. [Development - Guide to contributing to the module](#development)

## Description

This module aims to abstract resolving the correct role for your machine. It supports several ways to
figure out the role:

* Use trusted facts
* Use facts
* Use a parameter (allows configuration through hiera)
* Use a custom function
* Fallback to a default
* or Fail if there is no role found.

It also allows setting up a waterfall mechanism: no trusted fact? how about a regular one? a param?

You can supply the namespace using hiera or use the search_namespaces mechanism.

## Setup

### Setup Requirements

Depending on how you want to use this module, you will need to learn about:
* hiera
* trusted facts
* (custom) facts
* writing functions

On a puppet side: we depend on the stdlib module for additional functions.

### Beginning with role

Include this in your site.pp

```puppet
node 'default' {
  include ::role
}
```

Configure the namespace to use in hiera:

```yaml
---
role::namespace: '::my_roles'
```

## Usage

Using the resolve order.

```yaml
---
role::namespace: '::my_roles'
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

It is possible to search for a role in multiple namespaces. To do this, supply an (non-empty) array with namespaces to look in.

By example:
```yaml
role::separator: '::'
role::search_namespaces:
  - shared_roles
  - my_roles
  - {'': ''}
  - {customer: '_'}
```

The module will attempt to find the following classes (in order) for role `foobar` and use the first one that exists.

- shared_roles::foobar
- my_roles::foobar
- foobar
- customer_foobar


**Note**: A namespace parameter will always take precedence. In hiera, you can force a `undef` or `nil` value using `~`.

```yaml
role::namespace: ~
role::search_namespaces:
 - ''
 - {'my_roles': '::'}

```

## Development
