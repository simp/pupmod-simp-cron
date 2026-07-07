# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What this module does

`pupmod-simp-cron` is a SIMP Puppet module that manages the **cron subsystem** on
Enterprise Linux systems: the cron packages, the `crond` service, and — most
importantly — the cron **access-control policy** via `/etc/cron.allow` and
`/etc/cron.deny`.

Its defining behavior is a **deny-by-default (allow-list) security posture**: the
module writes an `/etc/cron.allow` file and ensures `/etc/cron.deny` is *absent*.
On Linux, when `cron.allow` exists only the users listed in it (plus, by
convention, root) may install crontabs; everyone else is denied. So the set of
users the module places in `cron.allow` is the complete set of accounts permitted
to use cron. `root` is added to that list by default.

### Business logic

**`cron` (`manifests/init.pp`)** — the public entry point.

- Parameters: `install_tmpwatch` (sourced from module data — see below),
  `manage_packages` (default `true`), `users` (`Array[String[1]]`, default `[]`),
  and `add_root_user` (default `true`).
- Always `include`s `cron::service`. When `manage_packages` is true, also
  `include`s `cron::install` and orders `Class['cron::install'] -> Class['cron::service']`.
- Builds the effective allow-list `$_users`: when `add_root_user` is true it is
  `unique($users + ['root'])`, otherwise just `$users`. **This is why root can
  always run cron unless you explicitly set `add_root_user => false`.**
- Declares one `cron::user` resource per entry in `$_users`.
- Declares the `concat { '/etc/cron.allow': }` target — `owner`/`group` `root`,
  mode **`0600`**, `order => 'alpha'`, `ensure_newline => true`. The `cron::user`
  defines contribute the fragments.
- Declares `file { '/etc/cron.deny': ensure => 'absent' }` — removing the
  deny-list is what makes `cron.allow` authoritative.

**`cron::install` (`manifests/install.pp`, private — `assert_private()`)** —
installs the cron packages.

- `cron_packages` defaults to `['cronie']`; `package_ensure` defaults to
  `simplib::lookup('simp_options::package_ensure', {'default_value' => 'installed'})`,
  the standard SIMP site-policy seam.
- When `install_tmpwatch` is true, `tmpwatch` is appended to the package list
  (`unique(...)`). Installs via `ensure_packages()`.

**`cron::service` (`manifests/service.pp`)** — manages the `crond` service.

- `service_name` defaults to `'crond'`; `enable` (default `true`) drives both
  `enable` and `ensure` (`running` when enabled, `stopped` otherwise).
  `hasstatus`/`hasrestart` are true.

**`cron::user` (`manifests/user.pp`, define)** — adds one user to the allow-list.

- Sanitizes the title: `$_name = strip($name)`, `$safe_name = regsubst($_name, '/', '__')`
  to form a safe fragment name.
- `include 'cron'` so the `concat` target always exists, then emits a
  `concat_fragment { "cron+${safe_name}.user": target => '/etc/cron.allow', content => $_name }`.
- `pam` parameter defaults to `simplib::lookup('simp_options::pam', {'default_value' => false})`.
  When true, it asserts the **optional** `simp/pam` dependency
  (`simplib::assert_optional_dependency`) and declares a
  `pam::access::rule { "cron_user_${safe_name}": ... }` allowing that user shell
  access from the `cron`/`crond` origins. This is the seam that couples cron
  access with PAM access control when SIMP-wide PAM management is on.

### Module data / backwards compatibility

`data/common.yaml` (bound via the module's `hiera.yaml`, Hiera 5) sets
`cron::install_tmpwatch: false` and aliases
`cron::install::install_tmpwatch: "%{alias('cron::install_tmpwatch')}"`. This
keeps the older top-level `cron::install_tmpwatch` key working as the source of
truth for the `cron::install` class parameter of the same name. Both `cron` and
`cron::install` declare `install_tmpwatch` with no default, so the value must come
from Hiera (for `include cron`) or be provided explicitly when declaring the class.

## Dependencies

- `simp/simplib` (`>= 4.9.0 < 5.0.0`) — `simplib::lookup`,
  `simplib::assert_optional_dependency`.
- `puppetlabs/concat` (`>= 6.4.0 < 10.0.0`) — builds `/etc/cron.allow` from
  fragments.
- `puppetlabs/stdlib` (`>= 8.0.0 < 10.0.0`).
- `simp/pam` (`>= 6.8.3 < 8.0.0`) — **optional**; only needed when `cron::user`
  is used with `pam => true`.
- Runtime: `puppet >= 7.0.0 < 9.0.0` (see `metadata.json` `requirements`).
- Supported OS: Amazon 2, EL7/8/9 across RedHat/CentOS/OracleLinux, and EL8/9 for
  Rocky/AlmaLinux (see `metadata.json`).

## Repository layout

- `manifests/init.pp` — public `cron` class (allow-list policy + orchestration).
- `manifests/install.pp` — private package-install class.
- `manifests/service.pp` — `crond` service management.
- `manifests/user.pp` — `cron::user` define (allow-list entry + optional PAM rule).
- `data/common.yaml`, `hiera.yaml` — module data (the `install_tmpwatch` alias).
- `spec/classes/`, `spec/defines/` — rspec-puppet unit tests.
- `spec/acceptance/suites/default/` — beaker acceptance suite;
  `spec/acceptance/nodesets/` holds the per-OS node definitions.
- `REFERENCE.md` — generated Puppet Strings reference (do not hand-edit; regenerate).
- `metadata.json` — module metadata, dependencies, and supported OS matrix.

## Common commands

This module uses `puppetlabs_spec_helper (~> 8)` + `simp-rake-helpers (~> 5)` +
`simp-beaker-helpers (~> 2)`; rake tasks come from `Simp::Rake::Pupmod::Helpers`
(see `Rakefile`).

```sh
bundle install

# Unit tests (rspec-puppet)
bundle exec rake spec

# A single spec file
bundle exec rspec spec/defines/user_spec.rb

# Lint / style
bundle exec rake lint
bundle exec rake rubocop

# Regenerate REFERENCE.md after changing manifest docstrings
bundle exec puppet strings generate --format markdown --out REFERENCE.md

# Acceptance tests (beaker; needs a hypervisor — CI uses vagrant_libvirt)
bundle exec rake beaker:suites[default]
```

## Conventions

- This is a component of the SIMP ecosystem. Follow SIMP module conventions:
  parameters that reflect site-wide policy are resolved through `simp_options::*`
  hiera keys via `simplib::lookup`, defaulting to safe values so the module works
  standalone (`simp_options::package_ensure`, `simp_options::pam`).
- Preserve the allow-list security posture: `/etc/cron.allow` is managed at mode
  `0600` and `/etc/cron.deny` is kept `absent`. Do not add users to the allow
  list except through `cron::user` / the `users` parameter, and be deliberate
  about `add_root_user` — turning it off removes root's guaranteed cron access.
- `simp/pam` is an **optional** dependency: any code path that touches PAM must
  stay behind `simplib::assert_optional_dependency` + the `pam` toggle, so the
  module still works when `simp/pam` is not installed.
- Keep the `install_tmpwatch` Hiera alias in `data/common.yaml` intact — the
  class parameters have no defaults and rely on it.
- Keep manifest parameter `@param` docstrings current — `REFERENCE.md` is
  generated from them.
