require 'mac-network'
OSX.require_framework('CoreWLAN')

class Mac::Network::WiFi
  def self.preferred_network=(network_name)
    raise "Sorry #{network_name} is not in the network list" unless self.network_names.include? network_name
    config_copy = self.configuration
    config_copy.networkProfiles = OSX::NSOrderedSet.orderedSetWithArray(config_copy.networkProfiles.allObjects.sort_by {|item| item.ssid != network_name })
    self.interface.commitConfiguration_authorization_error(config_copy,nil,nil)
  end

  def self.preferred_network
    self.networks.allObjects.first.ssid
  end

  def self.interface
    OSX::CWInterface.interfaceWithName(OSX::CWInterface.supportedInterfaces.first)
  end

  def self.configuration
    OSX::CWMutableConfiguration.configurationWithConfiguration(self.interface.configuration)
  end

  def self.networks
    self.configuration.networkProfiles
  end

  def self.network_names
    self.networks.allObjects.map {|n| n.ssid }
  end
end
