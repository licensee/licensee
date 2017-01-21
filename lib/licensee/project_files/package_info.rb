module Licensee
  class Project
    class PackageInfo < Licensee::Project::File
      def possible_matchers
        case ::File.extname(filename)
        when '.gemspec'
          [Matchers::Gemspec]
        when '.json'
          [Matchers::NpmBower]
        else
          if filename == 'DESCRIPTION' && content.start_with?('Package:')
            [Matchers::Cran]
          elsif filename == 'dist.ini'
            [Matchers::DistZilla]
          else
            []
          end
        end
      end

      def self.name_score(filename)
        return 1.0  if ::File.extname(filename) == '.gemspec'
        return 1.0  if filename == 'package.json'
        return 0.9  if filename == 'DESCRIPTION'
        return 0.8  if filename == 'dist.ini'
        return 0.75 if filename == 'bower.json'
        0.0
      end
    end
  end
end
