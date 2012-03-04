Facter.add(:macosx_mobileconfig_profiles) do
  setcode do
    profiles = %x{/usr/bin/profiles -P | /usr/bin/grep _computerlevel | awk '{ print $4 }'}.split("\n")
    profiles.join(',')
  end
end
