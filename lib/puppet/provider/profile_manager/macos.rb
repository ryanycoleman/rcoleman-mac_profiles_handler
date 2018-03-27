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

    plist = Puppet::Util::Plist.parse_plist(Puppet::Util::Execution.execute(['/usr/bin/profiles', '-C', '-o', 'stdout-xml']))

    if plist.key?('_computerlevel')
      for item in plist['_computerlevel']
        if item['ProfileIdentifier'] == resource[:name]
          return {
            'identifier' => item['ProfileIdentifier'],
            'display_name' => item['ProfileDisplayName'],
            'uuid' => item['ProfileUUID'],
            'install_date' => DateTime.parse(item['ProfileInstallDate'])
          }
        end
      end
    end
    return false
  end
end
