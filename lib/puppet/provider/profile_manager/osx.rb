Puppet::Type.type(:profile_manager).provide :osx do
  desc "Provides management of mobileconfig profiles on OS X."

  confine :operatingsystem => :darwin

  defaultfor :operatingsystem => :darwin

  commands :profiles => "/usr/bin/profiles"

  def create
    profiles('-I', '-F', resource[:profile])
  end

  def destroy
    profiles('-R', '-p', resource[:name])
  end

  def exists?
    `/usr/bin/profiles -P | /usr/bin/awk '{ print $4 }' | /usr/bin/grep -x '#{resource[:name]}'`
    if $? == 0
      return true
    else
      return false
    end
  end
end
