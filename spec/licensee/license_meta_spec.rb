RSpec.describe Licensee::LicenseMeta do
  subject { Licensee::License.find('mit').meta }

  meta_fields.each do |field|
    next if field['name'] == 'redirect_from'

    context "the #{field['name']} field" do
      let(:name) { field['name'].tr('-', '_') }
      let(:method) { name.to_sym }

      it 'responds to the field as a method' do
        expect(subject).to respond_to(method)
      end

      it 'responds to the field as a hash key' do
        if field['required']
          expect(subject[name]).to_not be_nil
        else
          expect { subject[name] }.not_to raise_error
        end
      end
    end
  end

  context 'predicate methods' do
    described_class::PREDICATE_FIELDS.each do |field|
      context "the #{field}? method" do
        it 'responds' do
          expect(subject).to respond_to("#{field}?".to_sym)
        end

        it 'is boolean' do
          expect(subject.send("#{field}?".to_sym)).to be(true).or be(false)
        end
      end
    end
  end

  context '#from_hash' do
    let(:hash) do
      { 'title' => 'Test license', 'description' => 'A test license' }
    end
    subject { described_class.from_hash(hash) }

    it 'sets values' do
      expect(subject.title).to eql('Test license')
      expect(subject.description).to eql('A test license')
    end

    context 'setting defaults' do
      let(:hash) { {} }

      described_class::DEFAULTS.each do |key, value|
        it "sets the #{key} field to #{value}" do
          expect(subject[key]).to eql(value)
        end
      end
    end

    context 'spdx-id' do
      let(:hash) { { 'spdx-id' => 'foo' } }

      it 'renames spdx-id to spdx_id' do
        expect(subject['spdx_id']).to eql('foo')
      end

      it 'exposes spdx-id via #[]' do
        expect(subject['spdx-id']).to eql('foo')
      end
    end
  end

  context '#from_yaml' do
    let(:yaml) { "title: Test license\ndescription: A test license" }
    subject { described_class.from_yaml(yaml) }

    it 'parses yaml' do
      expect(subject.title).to eql('Test license')
      expect(subject.description).to eql('A test license')
    end

    it 'sets defaults' do
      expect(subject.hidden).to eql(true)
      expect(subject.featured).to eql(false)
    end

    context 'nil yaml' do
      let(:yaml) { nil }

      it 'returns defaults' do
        expect(subject.hidden).to eql(true)
      end
    end

    context 'empty yaml' do
      let(:yaml) { '' }

      it 'returns defaults' do
        expect(subject.featured).to eql(false)
      end
    end
  end

  it 'returns the list of helper methods' do
    expect(described_class.helper_methods.length).to eql(13)
    expect(described_class.helper_methods).to include(:hidden?)
    expect(described_class.helper_methods).to_not include(:hidden)
    expect(described_class.helper_methods).to include(:title)
  end
end
