# Filesystem-based project
#
# Analyze a folder on the filesystem for license information
class Licensee
  class FSProject < Project
    attr_reader :path

    def initialize(path, **args)
      @path = path
      super(**args)
    end

    private
    def find_file
      files = []

      Dir.foreach(path) do |file|
        next unless ::File.file?(::File.join(path, file))
        if (score = yield file) > 0
          files.push({ :name => file, :score => score })
        end
      end

      return if files.empty?
      files.sort! { |a, b| b[:score] <=> a[:score] }

      f = files.first
      [::File.read(::File.join(path, f[:name])), f[:name]]
    end
  end
end
