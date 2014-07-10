require 'ffi'
require 'ffi_objc'
require 'corefoundation'

module SystemConfig
  extend FFI::Library
  ffi_lib '/System/Library/Frameworks/SystemConfiguration.framework/Versions/Current/SystemConfiguration'

  attach_function :SCPreferencesCreate, [:pointer, :pointer, :pointer], :pointer

  # Dynamic Preferences Store
  attach_function :SCDynamicStoreCreate, [:pointer, :pointer, :pointer, :pointer], :pointer
  attach_function :SCDynamicStoreCopyValue, [:pointer, :pointer], :pointer

  # Locations (Sets)
  attach_function :SCNetworkSetCopyAll, [:pointer], :pointer
  attach_function :SCNetworkSetCopyCurrent, [:pointer], :pointer
  attach_function :SCNetworkSetSetCurrent, [:pointer], :bool
  attach_function :SCNetworkSetGetName, [:pointer], :pointer
  attach_function :SCNetworkSetCreate, [:pointer], :pointer
  attach_function :SCNetworkSetRemove, [:pointer], :bool
  attach_function :SCNetworkSetSetName, [:pointer, :pointer], :bool
  attach_function :SCNetworkSetAddService, [:pointer, :pointer], :bool
  attach_function :SCNetworkSetCopyServices, [:pointer], :pointer
  attach_function :SCNetworkSetContainsInterface, [:pointer, :pointer], :bool

  # Services
  attach_function :SCNetworkServiceCreate, [:pointer, :pointer], :pointer
  attach_function :SCNetworkServiceCopyAll, [:pointer], :pointer
  attach_function :SCNetworkServiceGetName, [:pointer], :pointer
  attach_function :SCNetworkServiceSetName, [:pointer, :pointer], :bool
  attach_function :SCNetworkServiceGetInterface, [:pointer], :pointer
  attach_function :SCNetworkServiceCopyProtocols, [:pointer], :pointer
  attach_function :SCNetworkServiceEstablishDefaultConfiguration, [:pointer], :void
  attach_function :SCNetworkServiceGetServiceID, [:pointer], :pointer

  # Interfaces
  attach_function :SCNetworkInterfaceCopyAll, [], :pointer
  attach_function :SCNetworkInterfaceGetBSDName, [:pointer], :pointer
  attach_function :SCNetworkInterfaceGetLocalizedDisplayName, [:pointer], :pointer

  # Protocols
  attach_function :SCNetworkProtocolGetConfiguration, [:pointer], :pointer
  attach_function :SCNetworkProtocolSetConfiguration, [:pointer, :pointer], :bool
  attach_function :SCNetworkProtocolGetProtocolType, [:pointer], :pointer
  attach_function :SCNetworkProtocolGetEnabled, [:pointer], :bool
  attach_function :SCNetworkProtocolSetEnabled, [:pointer, :bool], :bool

end

module Mac
  module Network
    require 'yaml'

    SC_SCHEMA = YAML.load_file(File.join(File.dirname(__FILE__), '../support','SCSchemaMapping.yaml'))

    def self.get_sc_prefs
      client_ptr = FFI::MemoryPointer.new(:pointer, 100)
      SystemConfig.SCPreferencesCreate(nil, client_ptr, nil)
    end

    @@sc_prefs = get_sc_prefs

    def self.reload_prefs
      @@sc_prefs = get_sc_prefs
    end
    def self.sc_prefs
      @@sc_prefs ||= get_sc_prefs
    end

    def self.save_configuration!
      OSX::SCPreferencesCommitChanges(sc_prefs)
      OSX::SCPreferencesApplyChanges(sc_prefs)
    end

  end
end
