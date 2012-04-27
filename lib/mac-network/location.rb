require 'osx/cocoa'
OSX.require_framework('SystemConfiguration')

class Mac::Network::Location
  attr_reader :sc_location_ref
  def self.all
    OSX::SCNetworkSetCopyAll(self.sc_prefs).map {|l| self.new(l) }
  end

  def self.first
    all.first
  end

  def self.current
    self.new(OSX::SCNetworkSetCopyCurrent(self.sc_prefs))
  end

  def self.reload_prefs
    @@sc_prefs = OSX::SCPreferencesCreate(nil,'default',nil)
  end

  def self.sc_prefs
    @@sc_prefs ||= OSX::SCPreferencesCreate(nil,'default',nil)
  end

  def initialize(sc_location_ref = nil)
    sc_location_ref = OSX::SCNetworkSetCreate(self.class.sc_prefs) if sc_location_ref.nil?
    @sc_location_ref = sc_location_ref
  end

  def name
    OSX::SCNetworkSetGetName(self.sc_location_ref)
  end

  def name=(new_name)
    OSX::SCNetworkSetSetName(self.sc_location_ref, new_name)
  end
end
