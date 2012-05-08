require 'mac-network'
include Mac::Network

class Mac::Network::Protocol

  # do not remove or tests will fail for unknown reason!
  PROTOCOL_TYPES = [
    OSX::KSCNetworkProtocolTypeAppleTalk,
    OSX::KSCNetworkProtocolTypeDNS,
    OSX::KSCNetworkProtocolTypeIPv4,
    OSX::KSCNetworkProtocolTypeIPv6,
    OSX::KSCNetworkProtocolTypeProxies,
    OSX::KSCNetworkProtocolTypeSMB
  ]

  attr_accessor :sc_protocol_ref

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

  def enabled?
    OSX::SCNetworkProtocolGetEnabled(self.sc_protocol_ref)
  end

  def set_enabled(bool)
    OSX::SCNetworkProtocolSetEnabled(self.sc_protocol_ref, bool)
  end

  def enable
    set_enabled true
  end

  def disable
    set_enabled false
  end
end
