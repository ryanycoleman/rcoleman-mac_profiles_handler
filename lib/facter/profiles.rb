Facter.add(:profiles) do
  confine :kernel => 'Darwin'
  setcode do
	profiles = []

	if Facter.value(:os)['release']['major'].to_i >= 12
		output = Facter::Util::Resolution.exec('/usr/bin/profiles -P')

		output.each_line do |line|
			if line.include? 'profileIdentifier'
				profiles << line.split(' ')[3]
			end
		end
	end

	profiles

  end
end
