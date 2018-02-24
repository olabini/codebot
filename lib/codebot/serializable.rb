# frozen_string_literal: true

require 'codebot/configuration_error'

module Codebot
  # This class provides shared methods for classes that can be serialized
  # into YAML documents.
  #
  # Arrays of objects are serialized into either arrays or hashes, depending
  # on whether the +::serial_key+ method exists. If it does exist, it must
  # return a symbol identifying the property the values of which are to be
  # used as hash keys.
  class Serializable
    # Deserializes multiple objects into an array. The parameter must be either
    # an array or a hash, depending on whether the +::serial_key+ method exists.
    #
    # Only the keys contained in the array returned by the +::serial_values+
    # method are converted to symbols. Any other keys are discarded.
    # Deserialized parameters are passed to the class constructor.
    #
    # @param data [Array, Hash] the array or hash to be deserialized
    # @raise [ConfigurationError] if the data has an unexpected type
    # @return [Array] the deserialized array
    def self.load_all!(data)
      return if data.nil?
      unless data.is_a?(hash_format? ? Hash : Array)
        raise ConfigurationError, "invalid data #{data.inspect} for " \
                                  "#{name}"
      end
      data.map { |entry| load_entry entry }
    end

    # Serializes an array of objects into an array or a hash, depending on
    # whether the +::serial_key+ method exists.
    #
    # @param data [Array] the array to be serialized
    # @return [Array, Hash] the serialized array or hash
    def self.save_all!(data)
      result = data.map { |entry| save_entry entry }
      hash_format? ? result.to_h : result
    end

    private_class_method def self.load_entry(entry)
      params = {}
      params[serial_key], entry = entry if hash_format?
      values = entry.map do |key, val|
        [key.to_sym, val] if serial_values.map(&:to_s).include? key
      end
      new(params.merge(values.to_h.compact))
    end

    private_class_method def self.save_entry(entry)
      params = serial_values.map do |sym|
        [sym.to_s, serial_value_for(entry, sym)]
      end.to_h
      params = [serial_value_for(entry, serial_key), params] if hash_format?
      params
    end

    private_class_method def self.hash_format?
      respond_to?(:serial_key, true)
    end

    private_class_method def self.serial_value_for(entry, sym)
      type = serial_value_types[sym]
      data = entry.send(sym)
      data = type.save_all!(data) unless type.nil?
      data
    end

    private_class_method def self.serial_value_types
      {}
    end
  end
end
