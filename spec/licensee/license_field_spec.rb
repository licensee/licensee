RSpec.describe Licensee::LicenseField do
  context 'class' do
    it 'returns all license fields' do
      expect(described_class.all.count).to eql(6)
      expect(described_class.all.first).to be_a(Licensee::LicenseField)
    end

    it 'returns all license field keys' do
      expect(described_class.keys.count).to eql(6)
      expect(described_class.keys.first).to be_a(String)
      expect(described_class.keys.first).to eql('fullname')
    end

    context 'from a hash' do
      let(:hash) { { 'name' => 'foo', 'description' => 'bar' } }

      it 'builds from a hash' do
        field = described_class.from_hash(hash)
        expect(field.name).to eql('foo')
        expect(field.description).to eql('bar')
      end
    end

    it 'retrieves a specific field' do
      field = described_class.find('year')
      expect(field.description).to eql('The current year')
    end

    context 'from an array' do
      let(:array) { %w[year fullname] }
      let(:fields) { described_class.from_array(array) }

      it 'returns an array of LicenseFields' do
        expect(fields.count).to eql(2)
        expect(fields.first).to be_a(described_class)
        expect(fields.first.name).to eql('year')
        expect(fields.last.name).to eql('fullname')
      end
    end

    context 'from content' do
      let(:content) { 'Foo [year] bar [baz] [fullname]' }
      let(:fields) { described_class.from_content(content) }

      it 'pulls fields from content' do
        expect(fields.count).to eql(2)
        expect(fields.first.key).to eql('year')
        expect(fields[1].key).to eql('fullname')
      end
    end
  end

  it 'stores and exposes values' do
    field = described_class.new('foo', 'bar')
    expect(field.name).to eql('foo')
    expect(field.description).to eql('bar')
  end

  it "doesn't error for licenses without bodies" do
    other = Licensee::License.find('other')
    expect(other.fields).to be_empty
  end
end
