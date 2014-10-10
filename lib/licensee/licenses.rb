class Licensee
  class Licenses
    class << self

      # Returns an array of Licensee::License instances
      def list
        @licenses ||= begin
          licenses = []
          names.each { |name| licenses.push License.new(name) }
          licenses
        end
      end

      # Given a license name, attempt to return a matching Licensee::License instance
      def find(name)
        list.find { |l| l.name.downcase == name.downcase }
      end

      # Path to vendored licenses
      def base
        @base ||= File.expand_path "../../vendor/choosealicense.com/_licenses", File.dirname(__FILE__)
      end

      private

      # Returns a list of potential license names, as vendored
      def names
        @names ||= begin
          names = Dir.entries(base)
          names.map! { |l| File.basename(l, ".txt").downcase }
          names.reject! { |l| l =~ /^\./ || l.nil? }
          names
        end
      end

    end
  end
end
