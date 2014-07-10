require 'mac-network'
include Mac::Network

class SystemConfig::SCNetworkProtocol < CF::Base
  SystemConfig.attach_function "SCNetworkProtocolGetTypeID", [], CF.find_type(:cftypeid)
  @@type_map[SystemConfig.send("SCNetworkProtocolGetTypeID")] = self
end

class Mac::Network::Protocol

  #PROTOCOL_TYPES = [
  #  OSX::KSCNetworkProtocolTypeDNS,
  #  OSX::KSCNetworkProtocolTypeIPv4,
  #  OSX::KSCNetworkProtocolTypeIPv6,
  #  OSX::KSCNetworkProtocolTypeProxies,
  #  OSX::KSCNetworkProtocolTypeSMB
  #]

  attr_accessor :sc_protocol_ref

  def initialize(sc_protocol_ref)
    @sc_protocol_ref = sc_protocol_ref
  end

  def configuration
    CF::Dictionary.new(SystemConfig::SCNetworkProtocolGetConfiguration(sc_protocol_ref)).to_ruby
  end

  def configuration=(config)
    SystemConfig::SCNetworkProtocolSetConfiguration(sc_protocol_ref, config.to_cf)
  end

  def protocol_type
    CF::String.new(SystemConfig::SCNetworkProtocolGetProtocolType(sc_protocol_ref)).to_ruby
  end

  alias :name :protocol_type

  def enabled?
    SystemConfig::SCNetworkProtocolGetEnabled(sc_protocol_ref)
  end

  def set_enabled(bool)
    SystemConfig::SCNetworkProtocolSetEnabled(sc_protocol_ref, bool)
  end

  def enable
    set_enabled true
  end

  def disable
    set_enabled false
  end

  def available_properties
    Hash[SC_CONSTANTS.select {|k,v| k =~ /kSCPropNet.*#{name}.*/ }]

    # TODO should return a PropertyObject that has ValueObjects?
      # think about how it will be used
      # location.service.ipv4.config_method = "DHCP"
      # location.service.dns.search_domains = ["blah.com", "bar.com"]
      # location.service.proxies.autoproxy_url = 'http://proxyconfiguration.domain.com'
      # 'IPv4' => :properties => [
      #   :config_method => {:name => 'ConfigMethod', :values => ['DHCP', 'Manual'], :type => String },
      #   :addresses => {:name => 'Addresses', :values => nil, :type => String }
      # ]
  end

end
