require 'puppet/util/plist'

Puppet::Type.type(:profile_manager).provide :osx do
  desc 'Provides management of mobileconfig profiles on OS X.'

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
    installed
  end

  def installed
    # if already installed, check if it is the right one.
    # if not installed, return false.
    if Facter.value(:profiles).include? resource[:name]
      return current
    else
      return false
    end
  end

  def getinstalleddate
    # must be rerun as the output from Facter's earlier run is now
    # outdated, but this only runs on refresh so not horrible.
    output = Puppet::Util::Execution.execute('/usr/sbin/system_profiler SPConfigurationProfileDataType -xml')

    for item in Puppet::Util::Plist.parse_plist(output)[0]['_items'][0]['_items']
      if item['spconfigprofile_profile_identifier'] == resource[:name]
        return DateTime.parse(item['spconfigprofile_install_date'].scan(/\(([^\)]+)\)/).last.first)
      end
    end
  end

  def getreceipts
    begin
      receipts = Puppet::Util::Plist.read_plist_file(Facter.value(:puppet_vardir) + '/mobileconfigs/receipts.plist')
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

    receipts[resource[:name]] = { 'install_date' => getinstalleddate }

    Puppet::Util::Plist.write_plist_file(receipts, Facter.value(:puppet_vardir) + '/mobileconfigs/receipts.plist')
  end

  def current
    return getinstalleddate.to_time == getreceipts[resource[:name]]['install_date']
  rescue NoMethodError
    # no matching receipt
    return false
  end
end
