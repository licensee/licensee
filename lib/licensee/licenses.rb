class Licensee
  class Licenses
    class << self
      def names
        @names ||= begin
          names = Dir.entries(base)
          names.map! { |l| File.basename(l, ".txt") }
          names.reject! { |l| l =~ /^\./ || l.nil? }
          names
        end
      end

      def list
        @licenses ||= begin
          licenses = []
          names.each { |name| licenses.push License.new(name) }
          licenses
        end
      end

      def base
        @base ||= File.expand_path "../../vendor/choosealicense.com/_licenses", File.dirname(__FILE__)
      end

      def find(name)
        list.find { |l| l.name == name }
      end
    end
  end
end
