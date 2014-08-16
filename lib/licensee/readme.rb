class Licensee
  class Readme < FileFinder

    FILENAMES = %w[
      README
      README.txt
      README.md
      readme.html
    ]

    def match
      Licensee::Licenses.list.find { |l| l.meta["source"] && content.include?(l.meta["source"]) }
    end

  end
end
