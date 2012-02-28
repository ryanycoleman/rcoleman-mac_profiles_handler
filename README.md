# mac_profiles_handler module for Puppet

## Description
Puppet Module for managing the lion-computer-profiles-handler service @ code.google.com
This module manages the profile_handler service written by folks at Google and replaces 
the need for a profile manager server on your network. It provides a way to easily 
distribute mobileconfig profiles to an agent system where they'll be handled by the profile_handler service.


## Usage
Assuming one has the file mypolicy.mobileconfig in the files/comp_profiles directory of their module:

  mac::profile_handler::manage { 'mypolicy.mobileconfig':
    state      => 'enabled',
    filesource => 'puppet:///modules/mac_profiles_handler/comp_profiles/mypolicy.mobileconfig',
  }

This usage will deploy the profiles_handler script and service if not present along with the
directories they need to funtion. It will then deploy mypolicy.mobileconfig to /usr/local/comp_profiles
where the service expects to find mobileconfig profiles and will manage them.

Mobileconfig profiles used with this module need to end their identifier string with _handler

More information can be found at the projects [website](http://code.google.com/p/lion-computer-profiles-handler/).
