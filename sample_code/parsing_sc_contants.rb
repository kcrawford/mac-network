#!/usr/bin/ruby

require 'yaml'



h = File.read '/System/Library/Frameworks/SystemConfiguration.framework/Headers/SCSchemaDefinitions.h'

constants_hash = {}

h.split(/\/\*/).select {|group| group =~ / \* kSCEntNetDNS Entity Keys/ }.first.grep(/ *   *kSC/).map do |line|
  clean_line = line.sub(/ \* */, '').gsub('"','')
  name, value, type = clean_line.split
  constants_hash.merge!({name => {:value => value, :type => type}})
end

nil
