module Licensee
  module ProjectFiles
    class PackageManagerFile < Licensee::ProjectFiles::ProjectFile
      # Hash of Extension => [possible matchers]
      MATCHERS_EXTENSIONS = {
        '.gemspec' => [Matchers::Gemspec],
        '.json'    => [Matchers::NpmBower],
        '.cabal'   => [Matchers::Cabal]
      }.freeze

      # Hash of Filename => [possible matchers]
      FILENAMES_EXTENSIONS = {
        'DESCRIPTION'  => [Matchers::Cran],
        'dist.ini'     => [Matchers::DistZilla],
        'LICENSE.spdx' => [Matchers::Spdx]
      }.freeze

      def possible_matchers
        MATCHERS_EXTENSIONS[extension] || FILENAMES_EXTENSIONS[filename] || []
      end

      def self.name_score(filename)
        return 1.0  if ['.gemspec', '.cabal'].include?(File.extname(filename))
        return 1.0  if filename == 'package.json'
        return 1.0  if filename == 'LICENSE.spdx'
        return 0.8  if filename == 'dist.ini'
        return 0.9  if filename == 'DESCRIPTION'
        return 0.75 if filename == 'bower.json'
        0.0
      end

      private

      def extension
        @extension ||= File.extname(filename)
      end
    end
  end
end
