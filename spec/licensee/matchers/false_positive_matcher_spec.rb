RSpec.describe Licensee::Matchers::FalsePositive do
  let(:file) { Licensee::Project::LicenseFile.new(content, 'LICENSE') }
  let(:other) { Licensee::License.find('other') }
  subject { described_class.new(file) }

  context 'CC-ND' do
    let(:content) { 'Attribution-NoDerivatives 4.0 International' }

    it 'detects as other' do
      expect(subject.match).to eql(other)
    end
  end

  context 'CC-NC' do
    let(:content) { 'Attribution-NonCommercial 4.0 International' }

    it 'detects as other' do
      expect(subject.match).to eql(other)
    end
  end

  context 'with creative commons in the title' do
    let(:content) { 'Creative Commons Attribution-NonCommercial 4.0' }

    it 'detects as other' do
      expect(subject.match).to eql(other)
    end
  end

  context 'other licenses' do
    Licensee::License.all(hidden: true).each do |license|
      context license.name do
        let(:content) { license.content.to_s }

        it "doesn't match" do
          expect(subject.match).to be_nil
        end
      end
    end
  end
end
