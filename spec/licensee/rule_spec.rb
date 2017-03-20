RSpec.describe Licensee::Rule do
  let(:groups) { %w(permissions conditions limitations) }

  it 'stores the properties' do
    rule = described_class.new(
      tag:         'tag',
      label:       'label',
      description: 'description',
      group:       'group'
    )

    expect(rule.tag).to eql('tag')
    expect(rule.label).to eql('label')
    expect(rule.description).to eql('description')
    expect(rule.group).to eql('group')
  end

  it 'loads the groups' do
    expect(described_class.groups).to eql(groups)
  end

  it 'loads the raw rules' do
    groups.each do |key|
      expect(described_class.raw_rules).to have_key(key)
    end
  end

  it 'determines the file path' do
    path = described_class.file_path
    expect(File.exist?(path)).to eql(true)
  end

  it 'loads a rule by tag' do
    rule = described_class.find_by_tag('commercial-use')
    expect(rule).to be_a(described_class)
    expect(rule.tag).to eql('commercial-use')
  end

  it 'loads a rule by tag and group' do
    rule = described_class.find_by_tag_and_group('patent-use', 'limitations')
    expect(rule).to be_a(described_class)
    expect(rule.tag).to eql('patent-use')
    expect(rule.description).to include('does NOT grant')
  end

  it 'loads all rules' do
    expect(described_class.all.count).to eql(16)
    rule = described_class.all.first
    expect(rule).to be_a(described_class)
    expect(rule.tag).to eql('commercial-use')
  end
end
