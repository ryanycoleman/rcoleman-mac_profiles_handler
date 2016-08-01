Facter.add(:profiles) do
  confine :kernel => "Darwin"
  confine :macosx_productversion_major => %w{10.7 10.8 10.9 10.10 10.11 10.12}
  setcode do
    profiles = %x{/usr/bin/profiles -P | /usr/bin/grep profileIdentifier | /usr/bin/awk '{ print $4 }'}.split("\n")
    profiles.join(',')
  end
end
