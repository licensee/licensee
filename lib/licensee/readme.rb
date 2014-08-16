class Licensee
  class Readme < FileFinder

    FILENAMES = %w[
      README
      README.txt
      README.md
    ]

    def match
      Licensee::Licenses.list.find { |l| content.include? l.meta["source"] } 
    end

  end
end
