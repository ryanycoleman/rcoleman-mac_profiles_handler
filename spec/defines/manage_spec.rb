require 'spec_helper'
describe 'mac_profiles_handler::manage', :type => :define do
  let :title do
    'my_profile.mobileconfig'
  end

  let :default_params do
    {
      :state      => 'present',
      :filesource => "puppet:///modules/mac_profiles_handler/comp_profiles/#{title}",
    }
  end

  [{},
   {
     :state => 'absent',
   }
  ].each do |param_set|
    describe "when #{param_set == {} ? "using default" : "specifying"} class parameters" do
      let :param_hash do
        default_params.merge(param_set)
      end

      let :params do
        param_set
      end

      it { should contain_file("/usr/local/comp_profiles/#{title}").with({
          'ensure'    => param_hash[:state],
          'owner'     => "root",
          'group'     => "wheel",
          'mode'      => '0600',
          'source'    => param_hash[:filesource]
        })
      }

    end
  end
end

