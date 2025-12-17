# frozen_string_literal: true

# `licensee version` command implementation.
class LicenseeCLI < Thor
  desc 'version', 'Return the Licensee version'
  def version
    say Licensee::VERSION
  end
end
