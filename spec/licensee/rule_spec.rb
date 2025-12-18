# frozen_string_literal: true

RSpec.describe Licensee::Rule do
  subject(:rule) do
    described_class.new(
      description: 'description',
      tag:         'tag',
      label:       'label',
      group:       'group'
    )
  end

  let(:groups) { %w[permissions conditions limitations] }

  it 'stores properties' do
    expect(rule).to have_attributes(tag: 'tag', label: 'label', description: 'description', group: 'group')
  end

  it 'loads the groups' do
    expect(described_class.groups).to eql(groups)
  end

  it 'loads the raw rules' do
    expect(described_class.raw_rules.keys).to include(*groups)
  end

  it 'determines the file path' do
    path = described_class.file_path
    expect(File.exist?(path)).to be(true)
  end

  it 'loads a rule by tag' do
    rule = described_class.find_by_tag('commercial-use')
    expect(rule).to(satisfy { |value| value.is_a?(described_class) && value.tag == 'commercial-use' })
  end

  it 'loads a rule by tag and group in limitations' do
    rule = described_class.find_by_tag_and_group('patent-use', 'limitations')
    expect(rule).to(satisfy { |value| value.tag == 'patent-use' && value.description.include?('does NOT grant') })
  end

  it 'loads a rule by tag and group in permissions' do
    rule = described_class.find_by_tag_and_group('patent-use', 'permissions')
    expect(rule).to satisfy do |value|
      value.tag == 'patent-use' && value.description.include?('an express grant of patent rights')
    end
  end

  it 'loads all rules' do
    expect(described_class.all).to satisfy do |rules|
      rules.count == 17 && rules.first.is_a?(described_class) && rules.first.tag == 'commercial-use'
    end
  end

  context 'when calling #to_h' do
    let(:hash) { described_class.all.first.to_h }
    let(:description) do
      'The licensed material and derivatives may be used for commercial purposes.'
    end
    let(:expected) do
      {
        tag:         'commercial-use',
        label:       'Commercial use',
        description: description
      }
    end

    it 'Converts to a hash' do
      expect(hash).to eql(expected)
    end
  end
end
