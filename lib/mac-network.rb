module Mac
  module Network
    require 'osx/cocoa'
    OSX::require_framework('SystemConfiguration')

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
