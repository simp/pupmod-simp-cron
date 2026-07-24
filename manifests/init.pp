# @summary Manages /etc/cron.allow and /etc/cron.deny, the cron packages, and the cron service.
#
# @param install_tmpwatch
#   Force installation of the tmpwatch package
#
#   * In module data
#
# @param manage_packages
#   Enable management of the cron-related packages
#
# @param users
#   An array additional cron users to be allowed, using the defined type
#   cron::user
#
# @param add_root_user
#   Ensure that the root user is added to the catalog by default
#
# @param cron_deny_ensure
#   The `ensure` value for `/etc/cron.deny`
#
#   * Unmanaged by default (`undef`), leaving the system default in place
#   * Set to `file` to manage the file or `absent` to remove it
#
# @param cron_deny_owner
#   The owner for `/etc/cron.deny`
#
#   * Unmanaged by default (`undef`)
#
# @param cron_deny_group
#   The group for `/etc/cron.deny`
#
#   * Unmanaged by default (`undef`)
#
# @param cron_deny_mode
#   The file mode for `/etc/cron.deny`
#
#   * Unmanaged by default (`undef`), leaving the system default in place
#   * Set (e.g. `'0600'`) to enforce a mode for compliance
#
#   `/etc/cron.deny` is left untouched unless one of the `cron_deny_*`
#   parameters is set, in which case only the specified attributes are managed.
#
class cron (
  Boolean          $install_tmpwatch,
  Boolean          $manage_packages = true,
  Array[String[1]] $users           = [],
  Boolean          $add_root_user   = true,
  Optional[Enum['absent', 'file']] $cron_deny_ensure = undef,
  Optional[String[1]]              $cron_deny_owner  = undef,
  Optional[String[1]]              $cron_deny_group  = undef,
  Optional[Stdlib::Filemode]       $cron_deny_mode   = undef
) {
  include cron::service

  if $manage_packages {
    include cron::install

    Class['cron::install'] -> Class['cron::service']
  }

  if $add_root_user {
    $_users = unique($users + ['root'])
  }
  else {
    $_users = $users
  }

  $_users.each |String $_user| {
    cron::user { $_user: }
  }

  concat { '/etc/cron.allow':
    order          => 'alpha',
    owner          => 'root',
    group          => 'root',
    mode           => '0600',
    ensure_newline => true
  }

  # Leave /etc/cron.deny untouched unless the site opts in via one of the
  # cron_deny_* parameters (e.g. to satisfy a compliance requirement). Only
  # the attributes that are explicitly set are managed.
  $_cron_deny = {
    'ensure' => $cron_deny_ensure,
    'owner'  => $cron_deny_owner,
    'group'  => $cron_deny_group,
    'mode'   => $cron_deny_mode,
  }.filter |$_key, $_value| { $_value =~ NotUndef }

  unless $_cron_deny.empty {
    file { '/etc/cron.deny':
      * => $_cron_deny,
    }
  }
}
