require 'mac-network'

# registers as a valid type for corefoundation gem to use in arrays, etc
class SystemConfig::SCNetworkInterface < CF::Base
  SystemConfig.attach_function "SCNetworkInterfaceGetTypeID", [], CF.find_type(:cftypeid)
  @@type_map[SystemConfig.send("SCNetworkInterfaceGetTypeID")] = self
end


class Mac::Network::Interface
  attr_reader :sc_interface_ref

  def self.dynamic_store
    SystemConfig::SCDynamicStoreCreate(nil, "mac-network".to_cf, nil, nil)
  end

  def self.all
    interface_refs = SystemConfig::SCNetworkInterfaceCopyAll()
    CF::Array.new(interface_refs).map {|l| self.create(l) }.reject {|i| i.name.to_s =~ /BlueTooth/i }
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
    global_ipv4_state = SystemConfig::SCDynamicStoreCopyValue(dynamic_store, "State:/Network/Global/IPv4".to_cf)

    # if we got a dictionary, use the PrimaryInterface to instantiate our object
    # otherwise return nil
    if global_ipv4_state
      bsd_name_for_IPv4 = CF::Dictionary.new(global_ipv4_state).to_ruby.fetch("PrimaryInterface", "")
      find_by_bsd_name(bsd_name_for_IPv4)
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
    CF::String.new(SystemConfig::SCNetworkInterfaceGetBSDName(self.sc_interface_ref)).to_ruby
  end

  def name
    CF::String.new(SystemConfig::SCNetworkInterfaceGetLocalizedDisplayName(self.sc_interface_ref)).to_ruby.to_s
  end

  def wired?
    !!(name =~ /Ethernet/)
  end

  def inspect
    "#{self.class.name}: name => #{name}, bsd_name => #{bsd_name}"
  end

  def has_link?
    link_state = SystemConfig::SCDynamicStoreCopyValue(self.class.dynamic_store, "State:/Network/Interface/#{bsd_name}/Link".to_cf)
    if link_state.null?
      false
    else
      CF::Dictionary.new(link_state)["Active"].to_ruby == 1
    end
  end

  def has_ip?
    !!(SystemConfig::SCDynamicStoreCopyValue(self.class.dynamic_store, "State:/Network/Interface/#{bsd_name}/IPv4".to_cf))
  end

  def ip
    SystemConfig::SCDynamicStoreCopyValue(self.class.dynamic_store, "State:/Network/Interface/#{bsd_name}/IPv4".to_cf).fetch("Addresses",[]).first if has_ip?
  end

end
