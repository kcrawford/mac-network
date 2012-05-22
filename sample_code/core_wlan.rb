#!/usr/bin/ruby

require 'osx/cocoa'
OSX.require_framework('CoreWLAN')


security_modes = [OSX::KCWSecurityModeOpen,
  OSX::KCWSecurityModeWEP,
  OSX::KCWSecurityModeWPA_PSK,
  OSX::KCWSecurityModeWPA2_PSK,
  OSX::KCWSecurityModeWPA_Enterprise,
  OSX::KCWSecurityModeWPA2_Enterprise,
  OSX::KCWSecurityModeWPS,
  OSX::KCWSecurityModeDynamicWEP]

# Get an interface from the supported interfaces
i = OSX::CWInterface.interfaceWithName(OSX::CWInterface.supportedInterfaces.first)

# get the preferred (first) network's ssid (name)
i.configuration.preferredNetworks.first.ssid

# get a mutable copy of this configuration
mc = OSX::CWMutableConfiguration.configurationWithConfiguration(i.configuration)

# DEPRECATED sort the mutable copy's preferred networks to the desired order
mc.preferredNetworks = mc.preferredNetworks.sort_by {|item| item.ssid != 'My Wi-Fi NETWORK' }

# or use new NSOrderedSet
mc.networkProfiles = OSX::NSOrderedSet.orderedSetWithArray(mc.networkProfiles.allObjects.sort_by {|item| item.ssid != 'My Wi-Fi NETWORK' })

# verify
mc.preferredNetworks.first.ssid

# compare to non-mutable version
i.configuration.preferredNetworks.first.ssid


# commit (save) the change
i.commitConfiguration_authorization_error(mc,nil,nil)

