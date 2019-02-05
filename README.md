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

## Development