module Licensee
  class Rule
    attr_reader :tag, :label, :description, :group

    def initialize(tag: nil, label: nil, description: nil, group: nil)
      @tag = tag
      @label = label
      @description = description
      @group = group
    end

    def inspect
      "#<Licensee::Rule @tag=\"#{tag}\">"
    end

    class << self
      def all
        @all ||= raw_rules.map do |group, rules|
          rules.map do |rule|
            Rule.new(
              tag:         rule['tag'],
              label:       rule['label'],
              description: rule['description'],
              group:       group
            )
          end
        end.flatten
      end

      def find_by_tag(tag)
        Rule.all.find { |r| r.tag == tag }
      end

      def file_path
        dir = File.dirname(__FILE__)
        File.expand_path '../../vendor/choosealicense.com/_data/rules.yml', dir
      end

      def raw_rules
        YAML.load File.read(Rule.file_path)
      end

      def groups
        Rule.raw_rules.keys
      end
    end
  end
end
