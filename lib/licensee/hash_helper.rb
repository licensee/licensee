# frozen_string_literal: true

module Licensee
  # Mixin that provides a `to_h` based on a class's `HASH_METHODS`.
  module HashHelper
    def to_h
      hash = {}
      self.class::HASH_METHODS.each do |method|
        key = method.to_s.delete('?').to_sym
        value = public_send(method)
        hash[key] = serialize_hash_value(value)
      end

      hash
    end

    def serialize_hash_value(value)
      return value.map { |v| v.respond_to?(:to_h) ? v.to_h : v } if value.is_a?(Array)
      return value.to_h if value.respond_to?(:to_h) && !value.nil?

      value
    end
  end
end
