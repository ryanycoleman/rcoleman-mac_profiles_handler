# Define: mac_profiles_handler::manage
#
# This module manages the profile_handler service written by folks at Google
# and replaces the need for a profile manager server on your network.
# http://code.google.com/p/lion-computer-profiles-handler/
#
# Parameters:
#   state -- Specifies whether a mobileconfig should be present or not.
#     defaults to enabled, accepts present or absent.
#   filesource -- Where to find the mobileconfig file to manage.
#     defaults to retrieving the mobileconfig from the modules files dir.
#     accepts puppet:/// or http:// uris.
#
# This define will:
#   Deploy file specified as the title to /usr/local/comp_profiles on the
#   agent system where it will be managed by the profile_handler service.
#   If state is assigned the value disabled, the mobileconfig profile will
#   be removed from the agent system.
#
# Requires:
#   Mac OS X Lion -- 10.7
#
# Sample Usage:
#   mac::profile_handler::manage { 'mypolicy.mobileconfig':
#     state      => 'enabled',
#     filesource => 'puppet:///modules/mac_profiles_handler/comp_profiles/mypolicy.mobileconfig',
#   }
#
define mac_profiles_handler::manage(
  $state='present',
  $filesource="puppet:///modules/${module_name}/comp_profiles/${name}") {

  # Ensure the class containing all the prep work is done first.
  require mac_profiles_handler

  file { "/usr/local/comp_profiles/${name}":
    ensure => $state,
    mode   => '0600',
    owner  => 'root',
    group  => 'wheel',
    source => $filesource,
  }

}
