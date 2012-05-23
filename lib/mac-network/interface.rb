require 'osx/cocoa'
require 'mac-network'

OSX.require_framework('SystemConfiguration')

class Mac::Network::Interface
  attr_reader :sc_interface_ref

  def self.store
    @@store ||= OSX::SCDynamicStoreCreate(nil, "mac-network", nil, nil)
  end

  def self.all
    OSX::SCNetworkInterfaceCopyAll().map {|l| self.create(l) }.reject {|i| i.name.to_s =~ /BlueTooth/i }
  end

  def self.all_with_link
    self.all.select {|i| i.has_link? }
  end

  def self.first
    all.first
  end

  def self.find_by_name(interface_name)
    all.select {|i| i.name == interface_name }.first
  end

  def initialize(sc_interface_ref)
    @sc_interface_ref = sc_interface_ref
  end

  def self.create(*args)
    self.new(*args)
  end

  def bsd_name
    OSX::SCNetworkInterfaceGetBSDName(self.sc_interface_ref)
  end

  def name
    OSX::SCNetworkInterfaceGetLocalizedDisplayName(self.sc_interface_ref).to_s
  end

  def wired?
    !!(name =~ /Ethernet/)
  end

  def inspect
    "#{self.class.name}: name => #{name}, bsd_name => #{bsd_name}"
  end

  def has_link?
    !!(OSX::SCDynamicStoreCopyValue(self.class.store, "State:/Network/Interface/#{bsd_name}/Link").fetch("Active") == 1)
  end

end
