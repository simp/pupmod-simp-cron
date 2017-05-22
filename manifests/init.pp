# This class manages /etc/cron.allow and /etc/cron.deny and the
# crond service.
#
# @param install_tmpwatch
#   Force installation of the tmpwatch package.
# @param users
#   An array of additional cron users, using the defiend type cron::user.
#
class cron (
  Boolean       $install_tmpwatch = false,
  Array[String] $users            = []
) {

  $users.each |String $user| {
    cron::user { $user: }
  }
  cron::user { 'root': }

  simpcat_build { 'cron':
    order            => ['*.user'],
    clean_whitespace => 'leading',
    target           => '/etc/cron.allow'
  }

  file { '/etc/cron.allow':
    ensure    => 'present',
    owner     => 'root',
    group     => 'root',
    mode      => '0600',
    audit     => 'content',
    subscribe => Simpcat_build['cron']
  }

  file { '/etc/cron.deny':
    ensure => 'absent'
  }

  # CCE-27070-2
  service { 'crond':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true
  }

  if $install_tmpwatch {
    package { 'tmpwatch': ensure => latest }
  }
}
