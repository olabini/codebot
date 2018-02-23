# frozen_string_literal: true

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
    # @return [Array] the deserialized array
    def self.load_all!(data)
      return [] unless data.is_a?(hash_format? ? Hash : Array)
      data.map do |entry|
        load_entry entry
      end
    end

    # Serializes an array of objects into an array or a hash, depending on
    # whether the +::serial_key+ method exists.
    #
    # @param data [Array] the array to be serialized
    # @return [Array, Hash] the serialized array or hash
    def self.save_all!(data)
      result = data.map do |entry|
        save_entry entry
      end
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
      params = serial_values.map { |sym| [sym.to_s, entry.send(sym)] }.to_h
      params = [entry.send(serial_key), params] if hash_format?
      params
    end

    private_class_method def self.hash_format?
      respond_to?(:serial_key, true)
    end
  end
end
