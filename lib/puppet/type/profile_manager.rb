Puppet::Type.newtype(:profile_manager) do
  @doc = <<-EOT
    Manage Apple Configuration Profiles
    http://help.apple.com/profilemanager/mac/10.7/#apd88330954-6FA0-4568-A88E-7F6828E763A7

    Example Usage:
      profile_manager { 'com.puppetlabs.foo':
        ensure   => present,
        profile  => '/path/to/profile.mobileconfig',
      }

    The namevar for this type is the identifier for the profile.
    Profile = path to the profile on the client system.


  EOT

  ensurable

  def refresh
    provider.create
  end

  newparam(:name, namevar: true)
  newparam(:profile)
end
