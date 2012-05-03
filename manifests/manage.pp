define mac_profiles_handler::manage(
  $file_source,
  $ensure,
                           ) {

  if $::operatingsystem != 'Darwin' {
    fail('The mobileconfig::manage resource type is only supported on OS X')
  }

  File {
      owner  => 'root',
      group  => 'wheel',
      mode   => '0700',
  }

  if ! defined(File['/var/lib/puppet/mobileconfigs']) {
    file { '/var/lib/puppet/mobileconfigs':
      ensure => directory,
    }
  }

  file { "/var/lib/puppet/mobileconfigs/${name}":
    ensure => file,
    source => $file_source,
  }

  profile_manager { $name:
    ensure  => $ensure,
    profile => "/var/lib/puppet/mobileconfigs/${name}",
    require => File["/var/lib/puppet/mobileconfigs/${name}"],
  }


}
