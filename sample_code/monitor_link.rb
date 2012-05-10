#!/usr/bin/ruby

# using built-in ruby and rubycocoa since that is a non-private framework
require 'osx/cocoa'

# load up the framework
OSX.require_framework('SystemConfiguration')

# need a class that inherits from NSObject to get callbacks when stuff happens
class MyGoodClass < OSX::NSObject
  # make an accessible attribute so we can assign our callback to whatever we want
  attr_accessor :my_proc
end

# make an object
me = MyGoodClass.new

# assign the callback proc to the object instance
me.my_proc = Proc.new {|one,two,three| puts one,two,three}

# boilerplate code for getting access to the system configuration dynamic store that we'll be monitoring
context = OSX::SCDynamicStoreContext.new(0, me, nil, nil, nil)
system_dynamic_store = OSX::SCDynamicStoreCreate(nil, "me", me.my_proc, context)

# the key path to watch in the dynamic store
key_to_watch = OSX::SCDynamicStoreKeyCreateNetworkInterfaceEntity(nil, "State:", "en0", "Link")

# setup the notifications
OSX::SCDynamicStoreSetNotificationKeys(system_dynamic_store, [key_to_watch], nil)

# boilerplate runloop source
store_runloop_source = OSX::SCDynamicStoreCreateRunLoopSource(nil, system_dynamic_store, 0)
OSX::CFRunLoopAddSource(OSX::CFRunLoopGetCurrent(), store_runloop_source, OSX::KCFRunLoopCommonModes)

# run the loop (this blocks infinitely, but calls our callback when the key we are watching changes)
OSX::CFRunLoopRun()
