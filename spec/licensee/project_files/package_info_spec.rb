RSpec.describe Licensee::Project::PackageInfo do
  let(:content) { '' }
  let(:filename) { '' }
  subject { described_class.new(content, filename) }

  context 'name scoring' do
    {
      'licensee.gemspec' => 1.0,
      'package.json'     => 1.0,
      'bower.json'       => 0.75,
      'README.md'        => 0.0
    }.each do |filename, expected_score|
      context "a file named #{filename}" do
        let(:score) { described_class.name_score(filename) }
        it 'scores the file' do
          expect(score).to eql(expected_score)
        end
      end
    end
  end

  context 'matchers' do
    let(:possible_matchers) { subject.possible_matchers }

    context 'with a gemspec ' do
      let(:filename) { 'project.gemspec' }

      it 'returns the gemspec matcher' do
        expect(possible_matchers).to eql([Licensee::Matchers::Gemspec])
      end
    end

    context 'with package.json' do
      let(:filename) { 'package.json' }

      it 'returns the gemspec matcher' do
        expect(possible_matchers).to eql([Licensee::Matchers::NpmBower])
      end
    end
  end
end
