# mac_profiles_handler module for Puppet

## Description
This module provides two resource types for interacting with OS X configuration profiles.

The profile_manager resource type is the back-end type that interacts with /usr/bin/profiles for creating, destroying and verifying a resource type. The mac_profiles_handler::manage resource type is user-facing and handles the management of the actual files.

A basic fact is also provided to list installed profiles.

## Usage

<pre>
mac_profiles_handler::manage { 'com.puppetlabs.myprofile':  
  ensure  => present,  
  file_source => 'puppet:///modules/mymodule/com.puppetlabs.myprofile.mobileconfig',  
}
</pre>

You can use an ERB template instead of a mobileconfig:  
<pre>
mac_profiles_handler::manage { 'com.puppetlabs.myprofile':  
  ensure  => present,  
  file_source => template('mymodule/com.puppetlabs.myprofile.erb'),  
  type => 'template',  
}
</pre>


You must pass the profilers identifier as your namevar, ensure accepts present or absent and file_source behaves the same way source behaves for file.

## Dependencies

* [puppetlabs/stdlib >= 2.3.1](https://forge.puppetlabs.com/puppetlabs/stdlib)

## To-Do
Improve provider parsing.  
Handle more types of configuration profiles.  
The fact should create a fact for each profile, bonus points for using system_profiler.  
Improve documentation when author isn't presenting the next morning.  

## Contributing
Please do!  
Create issues in GitHub, Make Pull Requests, Have Fun!
