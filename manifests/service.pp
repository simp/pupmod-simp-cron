# @summary Manages the cron service
#
# @param service_name
#   The name of the service
#
# @param enable
#   Enable the `$service_name` service
#
class cron::service (
  String[1]     $service_name = 'crond',
  Boolean       $enable = true
) {
  if $enable {
    $_ensure = 'running'
  }
  else {
    $_ensure = 'stopped'
  }

  service { $service_name:
    ensure     => $_ensure,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true
  }
}
