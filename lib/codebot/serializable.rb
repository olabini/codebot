# frozen_string_literal: true

require 'codebot/configuration_error'

module Codebot
  # A class that can be serialized. Child classes should override the
  # {#serialize} and {::deserialize} methods, and change {::serialize_as_hash?}
  # to return +true+ if the {#serialize} method returns an +Array+ containing
  # two elements representing key and value of a +Hash+.
  class Serializable
    # Serializes an array into an array or a hash.
    #
    # @param ary [Array] the data to serialize
    # @param conf [Hash] the deserialized configuration
    # @return [Array, Hash] the serialized data
    def self.serialize_all(ary, conf)
      data = ary.map { |entry| entry.serialize(conf) }
      return data.to_h if serialize_as_hash?
      data
    end

    # Deserializes an array or a hash into an array.
    #
    # @param data [Array, Hash] the data to deserialize
    # @param conf [Hash] the previously deserialized configuration
    # @return [Array] the deserialized data
    def self.deserialize_all(data, conf)
      return [] if data.nil?
      if serialize_as_hash?
        deserialize_all_from_hash(data, conf)
      else
        deserialize_all_from_array(data, conf)
      end
    end

    # Serializes this object.
    #
    # @note Child classes should override this method.
    # @param _conf [Hash] the deserialized configuration
    # @return [Array, Hash] the serialized object
    def serialize(_conf)
      []
    end

    # Deserializes an object.
    #
    # @note Child classes should override this method.
    # @param _key [Object] the hash key if the value was serialized into a hash
    # @param _val [Hash] the serialized data
    # @return [Hash] the parameters to pass to the initializer
    def self.deserialize(_key = nil, _val)
      {}
    end

    # Returns whether data is serialized into a hash rather than an array.
    #
    # @note Child classes might want to override this method.
    # @return [Boolean] whether data is serialized into an array containing two
    #                   elements representing key and value of a +Hash+.
    def self.serialize_as_hash?
      false
    end

    # Deserializes an array into an array.
    #
    # @param data [Array] the data to deserialize
    # @param conf [Hash] the previously deserialized configuration
    # @return [Array] the deserialized data
    def self.deserialize_all_from_array(data, conf)
      unless data.is_a? Array
        raise ConfigurationError, "#{name}: invalid array #{data.inspect}"
      end
      data.map { |item| new(deserialize(item).merge(config: conf)) }
    end

    # Deserializes a hash into an array.
    #
    # @param data [Hash] the data to deserialize
    # @param conf [Hash] the previously deserialized configuration
    # @return [Array] the deserialized data
    def self.deserialize_all_from_hash(data, conf)
      unless data.is_a? Hash
        raise ConfigurationError, "#{name}: invalid hash #{data.inspect}"
      end
      data.map do |item|
        unless item.length == 2
          raise ConfigurationError, "#{name}: invalid member #{item.inspect}"
        end
        new(deserialize(*item).merge(config: conf))
      end
    end

    private_class_method :deserialize_all_from_array
    private_class_method :deserialize_all_from_hash
  end
end
