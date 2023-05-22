# frozen_string_literal: true

require 'spec_helper'
require 'mobility_typed/writer'

RSpec.describe MobilityTyped::Writer, type: :plugin do
  plugins :typed_writer
  plugin_setup :title

  describe 'getters' do
    let(:instance) { model_class.new }

    it 'correctly maps setter method for translated attribute to backend' do
      expect(Mobility).to receive(:locale).and_return(:de)
      expect(listener).to receive(:write).with(:de, 'foo', any_args)
      expect(instance.title = 'foo').to eq('foo')
    end

    it 'correctly maps locale through setter options and converts to boolean' do
      expect(listener).to receive(:write).with(:fr, 'foo', any_args).and_return('foo')
      expect(instance.send(:title=, 'foo', locale: :fr)).to eq('foo')
    end

    it 'correctly maps other options to getter' do
      expect(Mobility).to receive(:locale).and_return(:de)
      expect(listener).to receive(:write).with(:de, 'foo', someopt: 'someval').and_return('foo')
      instance.send(:title=, 'foo', someopt: 'someval')
    end

    it 'raises Mobility::InvalidLocale if write is called with locale not in available locales' do
      expect do
        instance.send(:title=, 'foo', locale: :ru)
      end.to raise_error(Mobility::InvalidLocale)
    end
  end

  describe 'super option' do
    let(:instance) { model_class.new }
    let(:model_class) do
      Class.new.tap do |klass|
        mod = Module.new do
          def title=(title)
            "set title to #{title}"
          end
        end
        klass.include translations, mod
      end
    end

    it 'calls original getter when super: true passed as option' do
      expect(instance.send(:title=, 'foo', super: true)).to eq('set title to foo')
    end
  end

  describe 'type checking' do
    plugin_setup :title, typed_writer: { type: :integer }

    let(:instance) { model_class.new }

    it 'correctly maps setter method for translated attribute to backend if correct type given' do
      expect(Mobility).to receive(:locale).and_return(:de)
      expect(listener).to receive(:write).with(:de, 1, any_args)
      expect(instance.title = 1).to eq(1)
    end

    it 'correctly maps setter method for translated attribute to backend if nil given' do
      expect(Mobility).to receive(:locale).and_return(:de)
      expect(listener).to receive(:write).with(:de, nil, any_args)
      expect(instance.title = nil).to eq(nil)
    end

    it 'raises MobilityTyped::Writer::TypeError if wrong type given' do
      expect do
        instance.send(:title=, 'foo', locale: :ru)
      end.to raise_error(MobilityTyped::Writer::TypeError, 'title= called with string, integer expected')
    end

    it 'raises MobilityTyped::Writer::TypeError if unknown type given' do
      class SampleClass; end

      expect do
        instance.send(:title=, SampleClass.new, locale: :ru)
      end.to raise_error(MobilityTyped::Writer::TypeError, 'title= called with SampleClass, integer expected')
    end
  end
end
