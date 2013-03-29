require 'osx/cocoa'
require 'mac-network'

OSX.require_framework('SystemConfiguration')

class Mac::Network::Interface
  attr_reader :sc_interface_ref

  def self.dynamic_store
    OSX::SCDynamicStoreCreate(nil, "mac-network", nil, nil)
  end

  def self.all
    OSX::SCNetworkInterfaceCopyAll().map {|l| self.create(l) }.reject {|i| i.name.to_s =~ /BlueTooth/i }
  end

  def self.all_with_link
    self.all.select {|i| i.has_link? }
  end

  def self.all_wired
    self.all.select {|i| i.wired? }
  end

  def self.all_wireless
    self.all.select {|i| !i.wired? }
  end

  def self.first
    all.first
  end

  def self.for_default_gateway
    # get the global IPv4 state dictionary from the dynamic store
    global_ipv4_state = OSX::SCDynamicStoreCopyValue(dynamic_store, "State:/Network/Global/IPv4")

    # if we got a dictionary, use the PrimaryInterface to instantiate our object
    # otherwise return nil
    if global_ipv4_state.respond_to? :fetch
      find_by_bsd_name(global_ipv4_state.fetch("PrimaryInterface", ""))
    else
      nil
    end
  end

  def self.find_by_name(interface_name)
    all.select {|i| i.name == interface_name }.first
  end

  def self.find_by_bsd_name(bsd_name)
    all.select {|i| i.bsd_name == bsd_name }.first
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
    link_state = OSX::SCDynamicStoreCopyValue(self.class.dynamic_store, "State:/Network/Interface/#{bsd_name}/Link")
    if link_state.nil?
      false
    else
      link_state.fetch("Active") == 1
    end
  end

  def has_ip?
    !!(OSX::SCDynamicStoreCopyValue(self.class.dynamic_store, "State:/Network/Interface/#{bsd_name}/IPv4"))
  end

  def ip
    OSX::SCDynamicStoreCopyValue(self.class.dynamic_store, "State:/Network/Interface/#{bsd_name}/IPv4").fetch("Addresses",[]).first if has_ip?
  end

end
