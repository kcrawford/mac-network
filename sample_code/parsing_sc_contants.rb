#!/usr/bin/ruby

require 'yaml'
require 'pp'

# File activesupport/lib/active_support/inflector/methods.rb, line 76

def underscore(camel_cased_word)
  word = camel_cased_word.to_s.dup
  word.gsub!(/::/, '/')
  #word.gsub!(/(?:([A-Za-z\d])|^)(?=\b|[^a-z])/) { "#{$1}#{$1 && '_'}#{$2.downcase}" }
  word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
  word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
  word.tr!("-", "_")
  word.downcase!
  word
end


h = File.read '/System/Library/Frameworks/SystemConfiguration.framework/Headers/SCSchemaDefinitions.h'

constants_hash = {}

h.split(/\/\*/).select {|group| group =~ / \* kSCEntNetDNS Entity Keys/ }.first.grep(/ *   *kSC/).map do |line|
  clean_line = line.sub(/ \* */, '').gsub('"','')
  name, value, type = clean_line.split
  constants_hash.merge!({name => {:value => value, :type => type}})
end

const_map = {}
entities = constants_hash.keys.select {|k| k.start_with? "kSCEntNet"}.map {|k| k.sub('kSCEntNet','')}
entities.each {|e|
  const_map[e] = {} # empty set of properties
  constants_hash.each {|k,v|
    if k.start_with? "kSCPropNet#{e}"
      property_name = constants_hash[k][:value]
      values = []
      constants_hash.each {|kv,vv|
        values << vv[:value] if kv.start_with? "kSCValNet#{e}#{property_name}"
      }
      const_map[e][underscore(constants_hash[k][:value])] = {:name => property_name, :type => constants_hash[k][:type], :values => values }
    end
  }
}

File.open('SCSchemaMapping.yaml', 'w') do |file|
  YAML.dump(const_map, file)
end

puts 'done writing ./SCSchemaMapping.yaml'
