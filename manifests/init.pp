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
class cron (
  Boolean          $install_tmpwatch,
  Boolean          $manage_packages = true,
  Array[String[1]] $users           = [],
  Boolean          $add_root_user   = true
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

  file { '/etc/cron.deny':
    ensure => 'absent'
  }
}
