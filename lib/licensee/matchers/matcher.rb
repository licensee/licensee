module Licensee
  module Matchers
    class Matcher
      attr_reader :file

      include Licensee::HashHelper
      HASH_METHODS = %i[name confidence].freeze

      def initialize(file)
        @file = file
      end

      def name
        @name ||= self.class.to_s.split('::').last.downcase.to_sym
      end

      def match
        raise 'Not implemented'
      end

      def confidence
        raise 'Not implemented'
      end

      private

      def potential_matches
        if file.is_a?(Licensee::ProjectFiles::LicenseFile)
          Licensee.licenses(hidden: true)
        elsif file.is_a?(Licensee::ProjectFiles::CodeOfConductFile)
          Licensee::CodeOfConduct.all
        else
          []
        end
      end
    end
  end
end
