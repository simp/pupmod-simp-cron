# Add the user $name to /etc/cron.allow
#
# @param name
#   The user to add to /etc/cron.allow
#
define cron::user (
  Boolean $pam = simplib::lookup('simp_options::pam', { 'default_value' => false })
) {
  include 'cron'

  $_name = strip($name)
  $safe_name = regsubst($_name,'/','__')

  concat_fragment { "cron+${safe_name}.user":
    target  => '/etc/cron.allow',
    content => $_name
  }

  if $pam {
    pam::access::rule { "cron_user_${safe_name}":
      users   => [$_name],
      origins => ['cron', 'crond']
    }
  }
}
