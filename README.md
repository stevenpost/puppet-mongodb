# mongodb puppet module

[![Build Status](https://github.com/voxpupuli/puppet-mongodb/workflows/CI/badge.svg)](https://github.com/voxpupuli/puppet-mongodb/actions?query=workflow%3ACI)
[![Release](https://github.com/voxpupuli/puppet-mongodb/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-mongodb/actions/workflows/release.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/mongodb.svg)](https://forge.puppetlabs.com/puppet/mongodb)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/mongodb.svg)](https://forge.puppetlabs.com/puppet/mongodb)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/mongodb.svg)](https://forge.puppetlabs.com/puppet/mongodb)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/mongodb.svg)](https://forge.puppetlabs.com/puppet/mongodb)
[![License](https://img.shields.io/github/license/voxpupuli/puppet-mongodb.svg)](https://github.com/voxpupuli/puppet-mongodb/blob/master/LICENSE)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with mongodb](#setup)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Installs MongoDB on RHEL/Ubuntu/Debian/SLES from community/enterprise repositories
or alternatively from custom repositories.

## Module Description

The MongoDB module manages mongod server installation and configuration of the
mongod daemon.

The MongoDB module also manages mongos, Ops Manager and the mongdb-mms setup.

## Setup

### What MongoDB affects

* MongoDB packages.
* MongoDB configuration files.
* MongoDB services.
* MongoDB apt/yum/zypper repository.

### Beginning with MongoDB

If you want a server installation with the default options you can run
`include mongodb::server`. If you need to customize configuration
options you need to do the following:

```puppet
class {'mongodb::server':
  port    => 27018,
  verbose => true,
}
```

To install client with default options run `include mongodb::client`

To override the default mongodb repo version you need the following:

```puppet
class {'mongodb::globals':
  repo_version => '4.4',
}
-> class {'mongodb::server': }
-> class {'mongodb::client': }
```

If you have a custom Mongodb repository you can opt out of repo management:

```puppet
class {'mongodb::globals':
  manage_package_repo => false,
}
-> class {'mongodb::server': }
-> class {'mongodb::client': }
```

## Usage

Most of the interaction for the server is done via `mongodb::server`. For
more options please have a look at [mongodb::server](#class-mongodbserver).
There is also `mongodb::globals` to set some global settings, on its own this
class does nothing.

### Create MongoDB database

To install MongoDB server, create database "testdb" and user "user1" with password "pass1".

```puppet
class {'mongodb::server':
  auth => true,
}

mongodb::db { 'testdb':
  user          => 'user1',
  password_hash => 'a15fbfca5e3a758be80ceaf42458bcd8',
}
```
Parameter 'password_hash' is hex encoded md5 hash of "user1:mongo:pass1".
Unsafe plain text password could be used with 'password' parameter instead of 'password_hash'.

### Replica sets

When deciding to use replica setups (recommended for production environments)
there are a few things to keep in mind when using this module.

When setting up replicasets, prefer fully qualified domain names.

#### Basic usage with authentication

```puppet
class { 'mongodb::server':
  auth                 => true,
  create_admin         => true,
  admin_username       => 'admin',
  admin_password       => $admin_password,
  admin_auth_mechanism => 'scram_sha_256',
  store_creds          => true,
  handle_creds         => true,
  replset              => 'rs0',
  replset_members      => [
    'mongo1.example.com:27017',
    'mongo2.example.com:27017',
    'mongo3.example.com:27017'
   ],
}
class { 'mongodb::client' }
```

#### Basic usage without authentication

First set up a basic installation on all nodes:

```puppet
class { 'mongodb::server':
  auth    => false,
  replset => 'rs0',
}
class { 'mongodb::client' }
```

Modify manifest and run on a single node:

```puppet
class { 'mongodb::server':
  auth            => false,
  replset         => 'rs0',
  replset_members => [
    'mongo1.example.com:27017',
    'mongo2.example.com:27017',
    'mongo3.example.com:27017'
   ],
}
class { 'mongodb::client' }
```

This initiates the replicaset on the first node.
From now on, this can be run on any node without changes to the node.

#### Limitations

This module may **not** be able to update a replica set once it is created when
authentication is disabled.

### Sharding

If one plans to configure sharding for a Mongo deployment, the module offer
the `mongos` installation. `mongos` can be installed the following way :

```puppet
class {'mongodb::mongos' :
  configdb => ['configsvr1.example.com:27018'],
}
```

### Ops Manager

To install Ops Manager and have it run with a local MongoDB application server do the following:

```puppet
class {'mongodb::opsmanager':
  opsmanager_url        => 'http://opsmanager.yourdomain.com'
  mongo_uri             => 'mongodb://yourmongocluster:27017,
  from_email_addr       => 'opsmanager@yourdomain.com',
  reply_to_email_addr   => 'replyto@yourdomain.com',
  admin_email_addr      => 'admin@yourdomain.com',
  $smtp_server_hostname => 'email-relay.yourdomain.com'
}
```

The default settings will not set useful email addresses. You can also just run `include mongodb::opsmanager`
and then set the emails later.

## Ops Manager Usage

Most of the interaction for the server is done via `mongodb::opsmanager`. For
more options please have a look at [mongodb::opsmanager](#class-mongodbopsmanager).

## Limitations

This module has been tested on:

* Debian 10.* (Buster)
* Debian 11.* (Bookworm)
* Ubuntu 20.04.0 LTS (Focal Fossa)
* RHEL 7/8
* CentOS 7/8

For a full list of tested operating systems please have a look at the [.nodeset.xml](https://github.com/voxpupuli/puppet-mongodb/blob/master/.nodeset.yml) definition.

This module should support `service_ensure` separate from the `ensure` value on `Class[mongodb::server]` but it does not yet.

### Apt module support

While this module supports both 1.x and 2.x versions of the puppetlabs-apt module, it does not support puppetlabs-apt 2.0.0 or 2.0.1.

## Development

This module is maintained by [Vox Pupuli](https://voxpupuli.org/). Voxpupuli
welcomes new contributions to this module, especially those that include
documentation and rspec tests. We are happy to provide guidance if necessary.

Please see [CONTRIBUTING](.github/CONTRIBUTING.md) for more details.

### Authors

* Puppetlabs Module Team
* Voxpupuli Team

We would like to thank everyone who has contributed issues and pull requests to this module.
A complete list of contributors can be found on the
[GitHub Contributor Graph](https://github.com/voxpupuli/puppet-mongodb/graphs/contributors)
for the [puppet-mongodb module](https://github.com/voxpupuli/puppet-mongodb).
