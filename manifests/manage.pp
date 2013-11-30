# manage mac profiles
define mac_profiles_handler::manage(
  $file_source,
  $ensure,
  $type = 'mobileconfig',
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
  case $type {
    'template': {
      file { "/var/lib/puppet/mobileconfigs/${name}":
        ensure  => file,
        content => $file_source,
      }
    }
    default: {
      file { "/var/lib/puppet/mobileconfigs/${name}":
        ensure => file,
        source => $file_source,
      }
    }
  }

  if $ensure=='present'{
    exec { "remove-profile-${name}":
      subscribe   => File["/var/lib/puppet/mobileconfigs/${name}"],
      before      => Profile_manager[$name],
      refreshonly => true,
      command     => "/usr/bin/profiles -R -p ${name}",
      onlyif      => "/usr/bin/profiles -P | /usr/bin/grep -q ${name}",
    }
  }

  profile_manager { $name:
    ensure  => $ensure,
    profile => "/var/lib/puppet/mobileconfigs/${name}",
    require => File["/var/lib/puppet/mobileconfigs/${name}"],
  }


}

