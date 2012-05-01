require 'osx/cocoa'
require 'mac-network'

OSX.require_framework('SystemConfiguration')

class Mac::Network::Interface
  attr_reader :sc_interface_ref
  def self.all
    OSX::SCNetworkInterfaceCopyAll().map {|l| self.new(l) }
  end

  def self.first
    all.first
  end

  def initialize(sc_interface_ref)
    @sc_interface_ref = sc_interface_ref
  end

  def bsd_name
    OSX::SCNetworkInterfaceGetBSDName(self.sc_interface_ref)
  end

  def name
    OSX::SCNetworkInterfaceGetLocalizedDisplayName(self.sc_interface_ref)
  end

  def inspect
    "#{self.class.name}: name => #{name}, bsd_name => #{bsd_name}"
  end
end
