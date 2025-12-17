# frozen_string_literal: true

RSpec.describe Licensee::Matchers::Package do
  let(:mit) { Licensee::License.find('mit') }
  let(:content) { '' }
  let(:file) do
    Licensee::ProjectFiles::LicenseFile.new(content, 'project.gemspec')
  end
  let(:license_property) { 'mit' }
  let(:matcher_class) do
    Class.new(described_class) do
      attr_reader :license_property

      def initialize(file, license_property)
        super(file)
        @license_property = license_property
      end
    end
  end
  let(:matcher) { matcher_class.new(file, license_property) }

  it 'matches' do
    expect(matcher.match).to eql(mit)
  end

  it 'has confidence' do
    expect(matcher.confidence).to be(90)
  end

  context 'with a nil license property' do
    let(:license_property) { nil }

    it 'matches to nil' do
      expect(matcher.match).to be_nil
    end
  end

  context 'with an empty license property' do
    let(:license_property) { '' }

    it 'matches to nil' do
      expect(matcher.match).to be_nil
    end
  end

  context 'with an unmatched license proprerty' do
    let(:license_property) { 'foo' }

    it 'matches to other' do
      expect(matcher.match).to eql(Licensee::License.find('other'))
    end
  end
end
