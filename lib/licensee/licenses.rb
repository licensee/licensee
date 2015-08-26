class Licensee
  class Licenses
    class << self

      # Returns an array of Licensee::License instances
      def list
        @licenses ||= begin
          licenses = []
          keys.each { |key| licenses.push License.new(key) }
          licenses
        end
      end

      # Given a license key, attempt to return a matching Licensee::License instance
      def find(key)
        list.find { |l| l.key.downcase == key.downcase }
      end
      alias_method :[], :find

      # Path to vendored licenses
      def base
        @base ||= ::File.expand_path "../../vendor/choosealicense.com/_licenses", ::File.dirname(__FILE__)
      end

      # Returns a list of potential license keys, as vendored
      def keys
        @keys ||= begin
          keyes = Dir.entries(base)
          keyes.map! { |l| ::File.basename(l, ".txt").downcase }
          keyes.reject! { |l| l =~ /^\./ || l.nil? }
          keyes
        end
      end
    end
  end
end
