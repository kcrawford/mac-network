require 'mac-network'

module Objc
  ffi_lib '/System/Library/Frameworks/CoreWLAN.framework/Versions/Current/CoreWLAN'
end

class Mac::Network::WiFi
  def self.preferred_network=(network_name)
    raise "Sorry #{network_name} is not in the network list" unless self.network_names.include? network_name
    config_copy = self.configuration
    ruby_array = self.ruby_array_of(config_copy.networkProfiles.allObjects).dup
    ruby_array.sort_by! {|item| (CF::String.new(item.ssid).to_s != network_name) ? 1 : 0 }
    new_array = cf_array_of(ruby_array)
    config_copy.setNetworkProfiles(Objc::NSOrderedSet.orderedSetWithArray(new_array))

    # ########## !!!!!!!!!!!!
    puts "here comes the crash..."
    self.interface.commitConfiguration(config_copy, { authorization: FFI::Pointer.new(0), error: FFI::Pointer.new(0) } )
    # ########## !!!!!!!!!!!!
  end

  def self.preferred_network
    CF::String.new(first).to_s
  end

  def self.first
    networks.firstObject
  end

  def self.interface
    Objc::CWInterface.interfaceWithName(Objc::CWInterface.supportedInterfaces.firstObject)
  end

  def self.configuration
    Objc::CWMutableConfiguration.configurationWithConfiguration(self.interface.configuration)
  end

  def self.networks
    self.configuration.networkProfiles.allObjects
  end

  def self.cf_array_of(ruby_array)
    cfarray = Objc::NSMutableArray.array
    ruby_array.each do |object|
     cfarray.addObject(object)
    end
    cfarray
  end

  def self.ruby_array_of(cfarray)
    (0...cfarray.count).map do |i|
     cfarray.objectAtIndex(i)
    end
  end

  def self.network_names
    all_networks = self.networks
    (0...all_networks.count).map do |i|
     CF::String.new(all_networks.objectAtIndex(i).ssid).to_s
    end
  end
end
