Facter.add(:profiles) do
  setcode do
    confine :kernel => "Darwin"
    profiles = %x{/usr/bin/profiles -P | /usr/bin/grep profileIdentifier | awk '{ print $4 }'}.split("\n")
    profiles.join(',')
  end
end
