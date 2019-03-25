# Add the user $name to /etc/cron.allow
#
# @param name
#   The user to add to /etc/cron.allow
#
define cron::user (
  Boolean $pam = simplib::lookup('simp_options::pam', { 'default_value' => false }),
) {
  include 'cron'

  $_name = inline_template("<%= @name.strip %>")
  $l_name = regsubst($_name,'/','__')

  concat_fragment { "cron+${l_name}.user":
    target  => '/etc/cron.allow',
    content => $_name
  }

  if $pam {
    pam::access::rule { "cron_user_${l_name}":
      users   => [$l_name],
      origins => ['cron', 'crond']
    }
  }

}
