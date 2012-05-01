require 'osx/cocoa'
require 'mac-network'
require 'mac-network/interface'

OSX.require_framework('SystemConfiguration')

class Mac::Network::Service
  attr_reader :sc_service_ref
  def self.all
    OSX::SCNetworkServiceCopyAll(Mac::Network.sc_prefs).map {|s| self.new({:sc_service_ref => s}) }
  end

  def self.first
    all.first
  end

  def self.current
    self.new(OSX::SCNetworkServiceCopyCurrent(Mac::Network.sc_prefs))
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

  def name
    OSX::SCNetworkServiceGetName(self.sc_service_ref)
  end

  def name=(new_name)
    OSX::SCNetworkServiceSetName(self.sc_service_ref, new_name)
  end

  def interface
    Mac::Network::Interface.new(OSX::SCNetworkServiceGetInterface(self.sc_service_ref))
  end
end
