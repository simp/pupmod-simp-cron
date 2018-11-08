[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/cron.svg)](https://forge.puppetlabs.com/simp/cron)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/cron.svg)](https://forge.puppetlabs.com/simp/cron)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-cron.svg)](https://travis-ci.org/simp/pupmod-simp-cron)

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with cron](#setup)
    * [What cron affects](#what-cron-affects)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)


## Description

This module manages the cron packages, service, and /etc/cron.allow.


### This is a SIMP module

This module is a component of the [System Integrity Management Platform](https://simp-project.com),
a compliance-management framework built on Puppet.

If you find any issues, they can be submitted to our [JIRA](https://simp-project.atlassian.net/).

This module is optimally designed for use within a larger SIMP ecosystem, but it can be used independently:

 * When included within the SIMP ecosystem, security compliance settings will be managed from the Puppet server.


## Setup


### What cron affects

  * crond service
  * `/etc/cron.deny`
  * `/etc/cron.allow`
  * tmpwatch package (if EL6)

## Usage

To use this module, just call the class. This example adds it to a class list in hiera:

```yaml
---
classes:
  - cron
```

Users can also be added to `/etc/cron.allow` with the `cron::user` defined type, or
the `cron::users` array in hiera. The following example adds a few users to `/etc/cron.allow`:

```yaml
cron::users:
  - foo
  - bar
```


## Reference

Please refer to the inline documentation within each source file, or to the module's generated YARD documentation for reference material.


## Limitations

SIMP Puppet modules are generally intended for use on Red Hat Enterprise Linux and compatible distributions, such as CentOS. Please see the [`metadata.json` file](./metadata.json) for the most up-to-date list of supported operating systems, Puppet versions, and module dependencies.


## Development

Please read our [Contribution Guide] (http://simp-doc.readthedocs.io/en/stable/contributors_guide/index.html).
