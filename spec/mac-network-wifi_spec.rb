require 'mac-network/wifi'
include Mac::Network

describe 'WiFi' do
  describe 'preferred_network' do
    it 'sets preferred network to first in the list' do
      new_preferred_network = CF::String.new(WiFi.networks.allObjects.lastObject.ssid).to_s
      WiFi.preferred_network = new_preferred_network
      # works if run as root
      if Process.euid == 0
        WiFi.preferred_network.should == new_preferred_network
      end
    end
  end
end
