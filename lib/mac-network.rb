module Mac
  module Network
    require 'yaml'
    require 'osx/cocoa'
    OSX::require_framework('SystemConfiguration')

    SC_SCHEMA = YAML.load_file(File.join(File.dirname(__FILE__), '../support','SCSchemaMapping.yaml'))

    def self.get_sc_prefs
      OSX::SCPreferencesCreate(nil,'default',nil)
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
