# frozen_string_literal: true

# ContentFile is a file within the Project that contain Content
# It allows the minimum initialization, path, encoding normalization logic
# to be shared between ProjectFiles and ConfigFiles
#
# ContentFiles will have @content and (meta) @data attributes set upon initialization
module Licensee
  class ContentFile
    attr_reader :content

    ENCODING = Encoding::UTF_8
    ENCODING_OPTIONS = {
      invalid: :replace,
      undef:   :replace,
      replace: ''
    }.freeze

    # Create a new Licensee::ContentFile with content and metadata
    #
    # content - file content
    # metadata - can be either the string filename, or a hash containing
    #            metadata about the file content. If a hash is given, the
    #            filename should be given using the :name key. See individual
    #            project types for additional available metadata
    #
    # Returns a new Licensee::ContentFile
    def initialize(content, metadata = {})
      @content = content.dup
      @content.force_encoding(ENCODING)
      @content.encode!(ENCODING, **ENCODING_OPTIONS) unless @content.valid_encoding?
      @content.encode!(ENCODING, universal_newline: true)

      metadata = { name: metadata } if metadata.is_a? String
      @data = metadata || {}
    end

    # TODO: In the next major release, filename should be the basename
    # and path should be either the absolute path or the relative path to
    # the project root, but maintaining the alias for backward compatability
    def filename
      @data[:name]
    end
    alias path filename

    def directory
      @data[:dir] || '.'
    end
    alias dir directory

    def path_relative_to_root
      File.join(directory, filename)
    end
    alias relative_path path_relative_to_root

    def ==(other)
      %i[content filename directory].all? { |a| public_send(a) == other.public_send(a) }
    end
    alias eql? ==
  end
end
