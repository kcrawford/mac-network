require 'mac-network'
include Mac::Network

class Mac::Network::Protocol

  attr_accessor :sc_protocol_ref

  PROTOCOL_TYPES = [
    OSX::KSCNetworkProtocolTypeAppleTalk,
    OSX::KSCNetworkProtocolTypeDNS,
    OSX::KSCNetworkProtocolTypeIPv4,
    OSX::KSCNetworkProtocolTypeIPv6,
    OSX::KSCNetworkProtocolTypeProxies,
    OSX::KSCNetworkProtocolTypeSMB
  ]

  def initialize(sc_protocol_ref)
    @sc_protocol_ref = sc_protocol_ref
  end

  def configuration
    OSX::SCNetworkProtocolGetConfiguration(self.sc_protocol_ref)
  end
  
  def configuration=(config)
    OSX::SCNetworkProtocolSetConfiguration(self.sc_protocol_ref, config)
  end

  def protocol_type
    OSX::SCNetworkProtocolGetProtocolType(self.sc_protocol_ref)
  end

  alias :name :protocol_type
end
