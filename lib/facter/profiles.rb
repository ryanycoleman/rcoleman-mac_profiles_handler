Facter.add(:profiles) do
  confine :kernel => "Darwin"
  setcode do
    profiles = %x{/usr/bin/profiles -P | /usr/bin/grep profileIdentifier | awk '{ print $4 }'}.split("\n")
    profiles.join(',')
  end
end
