require 'osx/cocoa'
require 'mac-network'
require 'mac-network/service'

OSX.require_framework('SystemConfiguration')

class Mac::Network::Location
  attr_reader :sc_location_ref

  def self.all
    OSX::SCNetworkSetCopyAll(Mac::Network::sc_prefs).map {|l| create({:sc_location_ref => l}) }
  end

  def self.first
    all.first
  end

  def self.current
    self.new(OSX::SCNetworkSetCopyCurrent(Mac::Network::sc_prefs))
  end

  def self.exists?(location_name)
    all.each do |location|
      return true if location.name == location_name
    end
    return false
  end

  def self.find_by_name(location_name)
    all.select {|l| l.name == location_name }.first
  end

  def initialize(*args)
    options = {:sc_location_ref => nil, :name => nil}
    options.merge!(args.pop) unless args.empty?
    if options[:sc_location_ref].nil?
      @sc_location_ref = OSX::SCNetworkSetCreate(Mac::Network::sc_prefs)
    else
      @sc_location_ref = options[:sc_location_ref]
    end
    self.name = options[:name] unless options[:name].nil?
  end

  def self.create(*args)
    self.new(*args)
  end

  def name
    OSX::SCNetworkSetGetName(self.sc_location_ref)
  end

  def name=(new_name)
    OSX::SCNetworkSetSetName(self.sc_location_ref, new_name)
  end

  def add_service(service)
    OSX::SCNetworkSetAddService(self.sc_location_ref, service.sc_service_ref)
    service
  end

  def services
    OSX::SCNetworkSetCopyServices(self.sc_location_ref).map do |service_ref|
      Mac::Network::Service.new(:sc_service_ref => service_ref)
    end.to_a
  end

  def has_service?(service_name)
    services.each do |service|
      return true if service.name == service_name
    end
    false
  end
  
  def contains_interface?(interface)
    OSX::SCNetworkSetContainsInterface(sc_location_ref, interface.sc_interface_ref)
  end

  def set_id
    OSX::SCNetworkSetGetSetID(sc_location_ref)
  end
end
