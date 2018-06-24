mac_profiles_handler::manage { 'com.puppetlabs.myprofile':
  ensure      => present,
  file_source => 'puppet:///modules/mymodule/com.puppetlabs.myprofile.mobileconfig',
}
