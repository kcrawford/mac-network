#!/usr/bin/ruby

require 'osx/cocoa'

OSX.require_framework('SystemConfiguration')

# get a reference to the dynamic store
store = OSX::SCDynamicStoreCreate(nil, "mac-network", nil, nil)

# all key paths we can access
OSX::SCDynamicStoreCopyKeyList(store, ".*")

# just the ones that tell us Link state
OSX::SCDynamicStoreCopyKeyList(store, "State:/Network/Interface/en.*/Link")

# getting the value of current link state
OSX::SCDynamicStoreCopyValue(store, "State:/Network/Interface/en0/Link")
#=> {"Active"=>#<NSNumber true>}


