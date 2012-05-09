require 'osx/cocoa'
require 'mac-network'
require 'mac-network/interface'
require 'mac-network/protocol'

OSX.require_framework('SystemConfiguration')

class Mac::Network::Service
  attr_reader :sc_service_ref
  def self.all
    OSX::SCNetworkServiceCopyAll(Mac::Network.sc_prefs).map {|s| self.create({:sc_service_ref => s}) }
  end

  def self.find_by_name(service_name)
    all.select {|s| s.name == service_name }.first
  end

  def self.first
    all.first
  end

  def self.current
    self.create(OSX::SCNetworkServiceCopyCurrent(Mac::Network.sc_prefs))
  end

  def self.create(*args)
    self.new(*args)
  end

  def initialize(*args)
    options = {:sc_service_ref => nil, :interface => nil}
    options.merge!(args.pop) unless args.empty?
    if options[:sc_service_ref].nil?
      raise "interface required for new service" unless options[:interface]
      options[:sc_service_ref] = OSX::SCNetworkServiceCreate(Mac::Network.sc_prefs, options[:interface].sc_interface_ref) if sc_service_ref.nil?
    end
    @sc_service_ref = options[:sc_service_ref]
  end

  OSX::constants.select {|k| k.start_with? "KSCNetworkProtocolType" }.each do |protocol_type|
    method_name = protocol_type.gsub('KSCNetworkProtocolType','').downcase
    define_method(method_name.to_sym) do
      protocols.select {|p| p.name == OSX::const_get(protocol_type) }.first
    end
  end

  def name
    OSX::SCNetworkServiceGetName(self.sc_service_ref)
  end

  def name=(new_name)
    OSX::SCNetworkServiceSetName(self.sc_service_ref, new_name)
  end

  def interface
    Mac::Network::Interface.new(OSX::SCNetworkServiceGetInterface(self.sc_service_ref))
  end

  def service_id
    OSX::SCNetworkServiceGetServiceID(sc_service_ref)
  end

  def inspect
    "#<#{self.class.name} name='#{name}' id='#{service_id}'>"
  end

  def refresh_protocols
    @protocols_cache = OSX::SCNetworkServiceCopyProtocols(sc_service_ref).map {|p_ref| Mac::Network::Protocol.new(p_ref)}
  end

  def protocols
    @protocols_cache ||= OSX::SCNetworkServiceCopyProtocols(sc_service_ref).map {|p_ref| Mac::Network::Protocol.new(p_ref)}
  end

  def configure_defaults
    OSX::SCNetworkServiceEstablishDefaultConfiguration(self.sc_service_ref)
    refresh_protocols
  end

  def disable_all_protocols
    protocols.each {|p| p.disable }
  end

end
