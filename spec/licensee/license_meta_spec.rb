# frozen_string_literal: true

RSpec.describe Licensee::LicenseMeta do
  subject { Licensee::License.find('mit').meta }

  meta_fields.each do |field|
    next if field['name'] == 'redirect_from'

    context "with the #{field['name']} field" do
      let(:name) { field['name'].tr('-', '_') }
      let(:method) { name.to_sym }

      it 'responds to the field as a method' do
        expect(subject).to respond_to(method)
      end

      it 'responds to the field as a hash key' do
        expect(subject[name]).to(satisfy { |value| !field['required'] || !value.nil? })
      end
    end
  end

  context 'when using predicate methods' do
    described_class::PREDICATE_FIELDS.each do |field|
      context "with the #{field}? method" do
        it 'responds' do
          expect(subject).to respond_to(:"#{field}?")
        end

        it 'is boolean' do
          expect(subject.send(:"#{field}?")).to be(true).or be(false)
        end
      end
    end
  end

  describe '#from_hash' do
    subject { described_class.from_hash(hash) }

    let(:hash) do
      { 'title' => 'Test license', 'description' => 'A test license' }
    end

    it 'sets values' do
      expect(subject).to have_attributes(title: 'Test license', description: 'A test license')
    end

    context 'when setting defaults' do
      let(:hash) { {} }

      described_class::DEFAULTS.each do |key, value|
        it "sets the #{key} field to #{value}" do
          expect(subject[key]).to eql(value)
        end
      end
    end

    context 'with spdx-id' do
      let(:hash) { { 'spdx-id' => 'foo' } }

      it 'renames spdx-id to spdx_id' do
        expect(subject['spdx_id']).to eql('foo')
      end

      it 'exposes spdx-id via #[]' do
        expect(subject['spdx-id']).to eql('foo')
      end
    end
  end

  describe '#from_yaml' do
    subject { described_class.from_yaml(yaml) }

    let(:yaml) { "title: Test license\ndescription: A test license" }

    it 'parses yaml' do
      expect(subject).to have_attributes(title: 'Test license', description: 'A test license')
    end

    it 'sets defaults' do
      expect([subject.hidden, subject.featured]).to eql([true, false])
    end

    context 'when yaml is nil' do
      let(:yaml) { nil }

      it 'returns defaults' do
        expect(subject.hidden).to be(true)
      end
    end

    context 'when yaml is empty' do
      let(:yaml) { '' }

      it 'returns defaults' do
        expect(subject.featured).to be(false)
      end
    end
  end

  it 'returns the list of helper methods' do
    expect(described_class.helper_methods).to satisfy do |methods|
      methods.length == 13 && methods.include?(:hidden?) && methods.include?(:title) && !methods.include?(:hidden)
    end
  end

  context 'when calling #to_h' do
    let(:hash) { subject.to_h }
    let(:using) do
      {
        'Babel' => 'https://github.com/babel/babel/blob/master/LICENSE',
        '.NET'  => 'https://github.com/dotnet/runtime/blob/main/LICENSE.TXT',
        'Rails' => 'https://github.com/rails/rails/blob/master/MIT-LICENSE'
      }
    end
    let(:expected) do
      {
        title:       'MIT License',
        source:      'https://spdx.org/licenses/MIT.html',
        description: subject.description.to_s,
        how:         subject.how.to_s,
        using:       using,
        featured:    true,
        hidden:      false,
        nickname:    nil,
        note:        nil
      }
    end

    it 'Converts to a hash' do
      expect(hash).to eql(expected)
    end
  end
end
