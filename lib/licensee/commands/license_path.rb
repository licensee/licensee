# frozen_string_literal: true

class LicenseeCLI < Thor
  desc 'license-path [PATH]', "Returns the path to the given project's license file"
  def license_path(_path)
    if project.license_file
      if remote?
        say project.license_file.path
      else
        say File.expand_path project.license_file.path
      end
    else
      exit 1
    end
  end
end
