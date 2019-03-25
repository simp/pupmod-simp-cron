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
