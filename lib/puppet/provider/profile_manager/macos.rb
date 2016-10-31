require 'puppet/util/plist'

Puppet::Type.type(:profile_manager).provide :macos do
  desc 'Provides management of mobileconfig profiles on macOS.'

  confine operatingsystem: :darwin

  defaultfor operatingsystem: :darwin

  commands profilescmd: '/usr/bin/profiles'

  def create
    profilescmd('-I', '-F', resource[:profile])
    writereceipt
  end

  def destroy
    profilescmd('-R', '-p', resource[:name])
  end

  def exists?
    # if already installed, check if it is the right one.
    # if not installed, return false.
    # if we are removing, don't care if it is the right one.
    state = getinstalledstate
    if state != false
      if resource[:ensure] == :absent
        return true
      else
        begin
          return state['install_date'].to_time == getreceipts[resource[:name]]['install_date']
        rescue NoMethodError
          # no matching receipt
          return false
        end
      end
    else
      return false
    end
  end

  def getreceipts
    begin
      receipts = Puppet::Util::Plist.read_plist_file(Puppet[:vardir] + '/mobileconfigs/receipts.plist')
    rescue IOError, Errno::ENOENT
      receipts = {}
    end
    receipts
  end

  def writereceipt
    # get install time from profile, write to disk so we know if the
    # currently installed profile is the one we installed, this uses
    # code from the fact but needs to re-run immediately.
    receipts = getreceipts

    receipts[resource[:name]] = { 'install_date' => getinstalledstate['install_date'] }

    Puppet::Util::Plist.write_plist_file(receipts, Puppet[:vardir] + '/mobileconfigs/receipts.plist')
  end

  def getinstalledstate
    output = Puppet::Util::Execution.execute('/usr/sbin/system_profiler SPConfigurationProfileDataType -xml')

    data = Puppet::Util::Plist.parse_plist(output)[0]['_items']

    unless data.empty?
      for item in data[0]['_items']
        if item['spconfigprofile_profile_identifier'] == resource[:name]
          return {
            'identifier' => item['spconfigprofile_profile_identifier'],
            'display_name' => item['_name'],
            'uuid' => item['spconfigprofile_profile_uuid'],
            'install_date' => DateTime.parse(item['spconfigprofile_install_date'].scan(/\(([^\)]+)\)/).last.first)
          }
        end
      end
    end
    return false
  end
end
