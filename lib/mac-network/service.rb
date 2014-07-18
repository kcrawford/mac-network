require 'mac-network'
require 'mac-network/interface'
require 'mac-network/protocol'

class SystemConfig::SCNetworkService < CF::Base
  SystemConfig.attach_function "SCNetworkServiceGetTypeID", [], CF.find_type(:cftypeid)
  @@type_map[SystemConfig.send("SCNetworkServiceGetTypeID")] = self
end

class Mac::Network::Service
  attr_reader :sc_service_ref
  def self.all
    service_refs = SystemConfig::SCNetworkServiceCopyAll(Mac::Network.sc_prefs)
    CF::Array.new(service_refs).map {|s| self.create({:sc_service_ref => s}) }
  end

  def self.find_by_name(service_name)
    all.select {|s| s.name == service_name }.first
  end

  def self.first
    all.first
  end

  def self.create(*args)
    self.new(*args)
  end

  def initialize(*args)
    options = {:sc_service_ref => nil, :interface => nil}
    options.merge!(args.pop) unless args.empty?
    if options[:sc_service_ref].nil?
      raise "interface required for new service" unless options[:interface]
      options[:sc_service_ref] = SystemConfig::SCNetworkServiceCreate(Mac::Network.sc_prefs, options[:interface].sc_interface_ref) if sc_service_ref.nil?
    end
    @sc_service_ref = options[:sc_service_ref]
  end

  # creates methods for each protocol type
  Mac::Network::Protocol::PROTOCOL_TYPES.each do |protocol_type|
    method_name = protocol_type.downcase
    define_method(method_name.to_sym) do
      protocols.select {|p| p.name == protocol_type }.first
    end
  end

  def protocol_by_name(protocol_name)
    protocols.select {|p| p.name.to_s.downcase == protocol_name.downcase }.first
  end

  def name
    CF::String.new(SystemConfig::SCNetworkServiceGetName(self.sc_service_ref)).to_s
  end

  def name=(new_name)
    SystemConfig::SCNetworkServiceSetName(self.sc_service_ref, new_name.to_cf)
  end

  def interface
    Mac::Network::Interface.new(SystemConfig::SCNetworkServiceGetInterface(self.sc_service_ref))
  end

  def service_id
    CF::String.new(SystemConfig::SCNetworkServiceGetServiceID(sc_service_ref)).to_s
  end

  def inspect
    "#<#{self.class.name} name='#{name}' id='#{service_id}'>"
  end

  def refresh_protocols
    protocol_refs = CF::Array.new(SystemConfig::SCNetworkServiceCopyProtocols(sc_service_ref))
    @protocols_cache = protocol_refs.map {|p_ref| Mac::Network::Protocol.new(p_ref)}
  end

  def protocols
    @protocols_cache ||= refresh_protocols
  end

  def configure_defaults
    SystemConfig::SCNetworkServiceEstablishDefaultConfiguration(self.sc_service_ref)
    refresh_protocols
  end

  def disable_all_protocols
    protocols.each {|p| p.disable }
  end

end
