require 'mac-network'
require 'mac-network/service'

#    * TDD *    #
# for Objc, what we want is...
#   We load a framework
#   We find out what types exist in the framework <cftype> and create those classes
#   These classes will inherit from CF::Base
#   The functions are attached with correct number and types of arguments
#   The return type of the function is determined and is somehow cast into the correct ruby type when returned
#     see how it is done in the CF::Array in corefoundation
#     and also see where we can hook in in ffi_objc
#     we may need a layer on top of attach_function so that we can call that and then typecast the result
#   The constants are registered under the framework using BridgeSupport data if it is available
#     not sure how to access constants yet
#   
#
#
# registers as a valid type for corefoundation gem to use in arrays, etc
# This allows corefoundation gem to wrap a cocoa object instance in a ruby object instance of this class
class SystemConfig::SCNetworkSet < CF::Base
  SystemConfig.attach_function "SCNetworkSetGetTypeID", [], CF.find_type(:cftypeid)
  @@type_map[SystemConfig.send("SCNetworkSetGetTypeID")] = self
end

class Mac::Network::Location
  attr_reader :sc_location_ref

  def self.all
    network_set_refs = SystemConfig::SCNetworkSetCopyAll(Mac::Network::sc_prefs)
    CF::Array.new(network_set_refs).map {|l| create({:sc_location_ref => l}) }
  end

  def self.first
    all.first
  end

  def self.current
    self.create(:sc_location_ref => SystemConfig::SCNetworkSetCopyCurrent(Mac::Network::sc_prefs))
  end

  def self.switch_to_location(location_name)
    location = find_by_name(location_name)
    return false unless location
    location.select
  end

  def self.exists?(location_name)
    all.each do |location|
      return true if location.name == location_name
    end
    return false
  end

  def self.find_by_name(location_name)
    all.select {|l| l.name.to_s == location_name }.first
  end

  def initialize(*args)
    options = {:sc_location_ref => nil, :name => nil}
    options.merge!(args.pop) unless args.empty?
    if options[:sc_location_ref].nil?
      @sc_location_ref = SystemConfig::SCNetworkSetCreate(Mac::Network::sc_prefs)
    else
      @sc_location_ref = options[:sc_location_ref]
    end
    self.name = options[:name] unless options[:name].nil?
  end

  def self.create(*args)
    self.new(*args)
  end

  def select
    SystemConfig::SCNetworkSetSetCurrent(self.sc_location_ref)
  end

  def name
    name_ref = SystemConfig::SCNetworkSetGetName(self.sc_location_ref)
    CF::String.new(name_ref).to_s unless name_ref.null?
  end

  def name=(new_name)
    SystemConfig::SCNetworkSetSetName(self.sc_location_ref, new_name.to_cf)
  end

  def add_service(service)
    SystemConfig::SCNetworkSetAddService(self.sc_location_ref, service.sc_service_ref)
    service
  end

  def services
    CF::Array.new(SystemConfig::SCNetworkSetCopyServices(self.sc_location_ref)).map do |service_ref|
      Service.create(:sc_service_ref => service_ref)
    end.to_a
  end

  def has_service?(service_name)
    services.each do |service|
      return true if service.name == service_name
    end
    false
  end
  
  def contains_interface?(interface)
    SystemConfig::SCNetworkSetContainsInterface(sc_location_ref, interface.sc_interface_ref)
  end

  def set_id
    CF::String.new(SystemConfig::SCNetworkSetGetSetID(sc_location_ref)).to_s
  end

  def destroy
    SystemConfig::SCNetworkSetRemove(sc_location_ref)
  end

  def inspect
    "#{self.class.name}: name => #{name}, set_id => #{set_id}"
  end
end
