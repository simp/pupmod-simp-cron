# @summary Installs cron
#
# @param install_tmpwatch
#   Whether or not to install the 'tmpwatch' package
#
#   * In module data
#
# @param cron_packages
#   The packages required for cron
#
# @param package_ensure
#   The `ensure` parameter for installed packages
#
class cron::install(
  Boolean          $install_tmpwatch,
  Array[String[1]] $cron_packages    = ['cronie'],
  String[1]        $package_ensure   = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })
) {
  assert_private()

  if $install_tmpwatch {
    $_cron_packages = unique($cron_packages + ['tmpwatch'])
  }
  else {
    $_cron_packages = $cron_packages
  }

  ensure_packages($_cron_packages, { 'ensure' => $package_ensure })
}
