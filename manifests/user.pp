# Add the user $name to /etc/cron.allow
#
# @param name
#   The user to add to /etc/cron.allow
#
define cron::user {
  include '::cron'

  $l_name = regsubst($name,'/','__')

  simpcat_fragment { "cron+${l_name}.user":
    content =>  "${name}\n"
  }

  pam::access::rule { "cron_user_${l_name}":
    users   => [$l_name],
    origins => ['cron', 'crond']
  }

}
