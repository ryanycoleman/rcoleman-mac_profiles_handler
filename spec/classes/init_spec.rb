require 'spec_helper'
describe 'mac_profiles_handler', :type => :class do

  let :file_default do
    {:owner => 'root', :group => 'wheel'}
  end
      it { should contain_file("/usr/local").with({
          'ensure' => 'directory',
          'mode'   => '0700',
        }.merge(file_default))
      }

      it { should contain_file("/usr/local/bin").with({
          'ensure' => 'directory',
          'mode'   => '0700',
        }.merge(file_default))
      }

      it { should contain_file("/usr/local/comp_profiles").with({
          'ensure'  => 'directory',
          'mode'    => '0700',
          'recurse' => true,
          'purge'   => true,
        }.merge(file_default))
      }

      it { should contain_file("handlers-script").with({
          'ensure' => 'file',
          'mode'   => '0744',
          'path'   => '/usr/local/bin/comp_profiles_handler.py',
          'source' => "puppet:///modules/mac_profiles_handler/comp_profiles_handler.py",
        }.merge(file_default))
      }

      it { should contain_file("handlers-service-plist").with({
          'ensure' => 'file',
          'mode'   => '0644',
          'path'   => '/Library/LaunchDaemons/se.hger.comp_profiles_handler.plist',
          'source' => "puppet:///modules/mac_profiles_handler/se.hger.comp_profiles_handler.plist",
        }.merge(file_default))
      }

      it { should contain_service("se.hger.comp_profiles_handler").with({
          'ensure'  => 'running',
          'enable'  => true,
          'require' => "File[handlers-service-plist]",
        })
      }

end
