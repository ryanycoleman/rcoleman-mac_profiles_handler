Facter.add(:profiles) do
  confine :kernel => "Darwin"
  confine :macosx_productversion_major => %w{10.7 10.8 10.9 10.10 10.11 10.12}
  setcode do
	profiles = []

	output = %x{/usr/bin/profiles -P}

	output.each_line do |line|
		if line.include? 'profileIdentifier'
			profiles << line.split(' ')[3]
		end
	end

	profiles.join(',')
  end
end
