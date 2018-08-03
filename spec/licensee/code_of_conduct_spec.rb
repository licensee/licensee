RSpec.describe Licensee::CodeOfConduct do
  let(:code_of_conduct_count) { 44 }

  context 'class methods' do
    it 'loads all codes of conduct' do
      expect(described_class.all.count).to eql(code_of_conduct_count)
      expect(described_class.all.first).to be_a(described_class)
    end

    context 'find' do
      %w[
        citizen-code-of-conduct
        contributor-covenant/version/1/3/0
        contributor-covenant/version/1/3/0/de
        contributor-covenant/version/1/4
        contributor-covenant/version/1/4/es
      ].each do |key|
        context key do
          it 'returns the requested code of conduct' do
            found = described_class.find(key)
            expect(found).to be_a(described_class)
            expect(found.key).to eql(key)
          end
        end
      end
    end

    it 'returns keys' do
      expect(described_class.keys.count).to eql(code_of_conduct_count)
    end
  end

  Licensee::CodeOfConduct.all.each do |coc|
    context coc.name do
      subject { coc }

      if coc.key.start_with? 'contributor-covenant'
        it 'returns the version' do
          expect(subject.version).to match(/\d\.\d/)
        end

        it 'returns the language' do
          unless subject.key.split('/').last =~ /\d/
            expect(subject.language).to match(/[a-z-]{2,5}/)
          end
        end
      end

      it 'returns the name without version' do
        expect(subject.name_without_version).to match(/^[a-z ]+$/i)
      end

      it 'returns the name' do
        expect(subject.name).to match(/^[a-z ]+(\([a-z-]+\))?( v\d\.\d)?$/i)
      end

      it 'returns the content' do
        expect(subject.content).to be_a(String)
      end

      it 'returns the normalized content' do
        expect(subject.content_normalized).to be_a(String)
      end
    end
  end
end
