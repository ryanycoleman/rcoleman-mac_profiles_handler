require 'puppet/util/plist'
require 'time'
require 'tmpdir'

Facter.add(:profiles) do
  confine kernel: 'Darwin'
  setcode do
    profiles = {}

    if Facter.value(:os)['release']['major'].to_i >= 12

      path = Dir.mktmpdir + '/profiles.plist'

      # why????
      Facter::Util::Resolution.exec(['/usr/bin/profiles', '-C', '-o', path].join(' '))

      plist = Puppet::Util::Plist.read_plist_file(path)

      data = plist['_computerlevel']

      unless data.empty?
        for item in data
          profiles[item['ProfileIdentifier']] = {
            'display_name' => item['ProfileDisplayName'],
            'description' => item['ProfileDescription'],
            'verification_state' => item['ProfileVerificationState'],
            'uuid' => item['ProfileUUID'],
            'organization' => item['ProfileOrganization'],
            'type' => item['ProfileType'],
            'install_date' => DateTime.parse(item['ProfileInstallDate']),
            'payload' => []
          }

          for pl in item['ProfileItems']
            profiles[item['ProfileIdentifier']]['payload'] << {
              'type' => pl['PayloadType'],
              'identifier' => pl['PayloadIdentifier'],
              'uuid' => pl['PayloadUUID'],
              # commented out for now because its not super useful.
              # 'content' => pl['PayloadContent'],
            }
          end
        end
      end
    end

    profiles
  end
end
