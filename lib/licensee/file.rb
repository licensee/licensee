class Licensee
  class File

    # Note: File can be a license file (e.g., `LICENSE.txt`)
    # or a package manager file (e.g, `package.json`)

    attr_reader :blob, :path
    alias_method :filename, :path

    def initialize(blob, path)
      @blob = blob
      @path = path
    end

    # Raw file contents
    def content
      @contents ||= blob.content.force_encoding("UTF-8")
    end
    alias_method :to_s, :content
    alias_method :contents, :content

    # File content with all whitespace replaced with a single space
    def content_normalized
      @content_normalized ||= content.downcase.gsub(/\s+/, " ").strip
    end

    # Determines which matching strategy to use, returns an instane of that matcher
    def matcher
      @matcher ||= Licensee.matchers.map { |m| m.new(self) }.find { |m| m.match }
    end

    # Returns an Licensee::License instance of the matches license
    def match
      @match ||= matcher.match if matcher
    end

    # Returns the percent confident with the match
    def confidence
      @condience ||= matcher.confidence if matcher
    end

    def similarity(other)
      blob.hashsig(Rugged::Blob::HashSignature::WHITESPACE_SMART)
      other.hashsig ? blob.similarity(other.hashsig) : 0
    rescue Rugged::InvalidError
      0
    end

    # Comptutes a diff between known license and project license
    def diff(options={})
      options = options.merge(:reverse => true)
      blob.diff(match.body, options).to_s if match
    end

    def license_score
      self.class.license_score(filename)
    end

    def license?
      license_score != 0.0
    end

    def package_score
      return 1.0  if filename =~ /[a-zA-Z0-9\-_]+\.gemspec/
      return 1.0  if filename =~ /package\.json/
      return 0.75 if filename =~ /bower.json/
      return 0.0
    end

    def package?
      Licensee.package_manager_files? && package_score != 0.0
    end

    class << self
      # Scores a given file as a potential license
      #
      # filename - (string) the name of the file to score
      #
      # Returns 1.0  if the file is definitely a license file
      # Returns 0.75 if the file is probably a license file
      # Returns 0.5  if the file is likely a license file
      # Returns 0.0  if the file is definitely not a license file
      def license_score(filename)
        return 1.0  if filename =~ /\A(un)?licen[sc]e(\.[^.]+)?\z/i
        return 0.75 if filename =~ /\Acopy(ing|right)(\.[^.]+)?\z/i
        return 0.5  if filename =~ /licen[sc]e/i
        return 0.0
      end
    end
  end
end
