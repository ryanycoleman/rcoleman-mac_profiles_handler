# Class: mac_profiles_handler
#
# This module manages the profile_handler service written by folks at Google
# and replaces the need for a profile manager server on your network.
# http://code.google.com/p/lion-computer-profiles-handler/
#
# Parameters:
#
# This class manages:
#   - comp_profiles_handler.py which manipulates .mobileconfig files.
#   - se.hger.comp_profiles_handler launchd service to watch for files in;
#   - /usr/local/comp_profiles is to contain files to be handled by the script.
#
# Requires:
#   Apple Mac OS X Lion -- 10.7
class mac_profiles_handler {

  File {
    owner => 'root',
    group => 'wheel',
  }

  file { [ '/usr/local', '/usr/local/bin' ]:
    ensure => directory,
    mode   => '0700',
  }

  file { '/usr/local/comp_profiles':
    ensure  => directory,
    mode    => '0700',
    recurse => true,
    purge   => true,
  }

  file { 'handlers-script':
    ensure => file,
    path   => '/usr/local/bin/comp_profiles_handler.py',
    source => "puppet:///modules/${module_name}/comp_profiles_handler.py",
    mode   => '0744',
  }

  file { 'handlers-service-plist':
    ensure => file,
    path   => '/Library/LaunchDaemons/se.hger.comp_profiles_handler.plist',
    source => "puppet:///modules/${module_name}/se.hger.comp_profiles_handler.plist",
    mode   => '0644',
  }

  service { 'se.hger.comp_profiles_handler':
    ensure  => running,
    enable  => true,
    require => File['handlers-service-plist'],
  }
}
