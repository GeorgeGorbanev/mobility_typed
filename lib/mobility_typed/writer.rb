# frozen-string-literal: true

require 'mobility'

module MobilityTyped
  module Writer
    TYPES_MAP = {
      String => :string,
      Integer => :integer,
      Float => :float,
      TrueClass => :bool,
      FalseClass => :bool,
      Array => :array,
      Hash => :hash
    }.freeze

    class TypeError < StandardError; end

    extend Mobility::Plugin

    default true
    requires :backend

    initialize_hook do |*names|
      if options[:typed_writer]
        type_option = options[:typed_writer][:type] if options[:typed_writer].is_a?(Hash)

        names.each do |name|
          class_eval <<-EOM, __FILE__, __LINE__ + 1
            def #{name}=(value, locale: nil, **options)
              #{MobilityTyped::Writer.check_type(name, type_option) if type_option}
              #{MobilityTyped::Writer.setup_source}
              mobility_backends[:#{name}].write(locale, value, **options)
            end
          EOM
        end
      end
    end

    def self.setup_source
      <<-EOL
        return super(value) if options[:super]
        if (locale &&= locale.to_sym)
          #{'Mobility.enforce_available_locales!(locale)' if I18n.enforce_available_locales}
          options[:locale] = true
        else
          locale = Mobility.locale
        end
      EOL
    end

    def self.check_type(name, type)
      <<-EOL
      if !value.nil? 
        value_type = MobilityTyped::Writer.value_type(value)
        if value_type != :#{type}        
          raise MobilityTyped::Writer::TypeError, "#{name}= called with \#{value_type}, #{type} expected"
        end
      end
      EOL
    end

    def self.value_type(value)
      TYPES_MAP[value.class] || value.class
    end

    Mobility::Plugins.register_plugin(:typed_writer, MobilityTyped::Writer)
  end
end
