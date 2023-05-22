# frozen_string_literal: true

require 'mobility'

require './spec/support/helpers'

I18n.enforce_available_locales = true
I18n.available_locales = %i[en fr de]
I18n.default_locale = :en

RSpec.configure do |config|
  config.include Helpers
  config.include Mobility::Util

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.include Helpers::Plugins, type: :plugin
  config.include Helpers::PluginSetup, type: :plugin

  config.before :each do
    reset_i18n_fallbacks
    Mobility.locale = :en
    Mobility.reset_translations_class
  end

  config.order = 'random'
end
