# Filesystem-based project
#
# Analyze a folder on the filesystem for license information
module Licensee
  class FSProject < Project
    attr_reader :path

    def initialize(path, **args)
      @path = path
      super(**args)
    end

    private

    def find_file
      files = []

      if ::File.file?(path)
        pattern = ::File.basename(path)
        @path = ::File.dirname(path)
      else
        pattern = '*'
      end

      Dir.glob(::File.join(path, pattern)) do |file|
        next unless ::File.file?(file)
        file = ::File.basename(file)
        if (score = yield file) > 0
          files.push(name: file, score: score)
        end
      end

      return if files.empty?
      files.sort! { |a, b| b[:score] <=> a[:score] }

      f = files.first
      [::File.read(::File.join(path, f[:name])), f[:name]]
    end
  end
end
