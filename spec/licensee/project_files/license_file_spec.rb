RSpec.describe Licensee::Project::LicenseFile do
  let(:filename) { 'LICENSE.txt' }
  let(:mit) { Licensee::License.find('mit') }
  let(:content) { sub_copyright_info(mit.content) }

  subject { described_class.new(content, filename) }

  it 'parses the attribution' do
    expect(subject.attribution).to eql('Copyright (c) 2016 Ben Balter')
  end

  context 'with an non-UTF-8-encoded license' do
    let(:content) { "\x91License\x93".force_encoding('windows-1251') }

    it "doesn't blow up " do
      expect(subject.attribution).to be_nil
    end
  end

  it 'creates the wordset' do
    expect(subject.wordset.count).to eql(93)
    expect(subject.wordset.first).to eql('mit')
  end

  it 'creates the hash' do
    expect(subject.hash).to eql('750260c322080bab4c19fd55eb78bc73e1ae8f11')
  end

  context 'filename scoring' do
    {
      'license'            => 1.0,
      'LICENCE'            => 1.0,
      'unLICENSE'          => 1.0,
      'unlicence'          => 1.0,
      'license.md'         => 0.9,
      'LICENSE.md'         => 0.9,
      'license.txt'        => 0.9,
      'COPYING'            => 0.8,
      'copyRIGHT'          => 0.8,
      'COPYRIGHT.txt'      => 0.7,
      'copying.txt'        => 0.7,
      'LICENSE.php'        => 0.6,
      'LICENCE.docs'       => 0.6,
      'copying.image'      => 0.5,
      'COPYRIGHT.go'       => 0.5,
      'LICENSE-MIT'        => 0.4,
      'MIT-LICENSE.txt'    => 0.4,
      'mit-license-foo.md' => 0.4,
      'COPYING-GPL'        => 0.3,
      'COPYRIGHT-BSD'      => 0.3,
      'README.txt'         => 0.0
    }.each do |filename, expected|
      context "a file named #{filename}" do
        let(:score) { described_class.name_score(filename) }

        it 'scores the file' do
          expect(score).to eql(expected)
        end
      end
    end

    context 'LGPL scoring' do
      {
        'COPYING.lesser' => 1,
        'copying.lesser' => 1,
        'COPYING.LESSER' => 1,
        'license.lesser' => 0,
        'LICENSE.md'     => 0,
        'FOO.md'         => 0
      }.each do |filename, expected|
        context "a file named #{filename}" do
          let(:score) { described_class.lesser_gpl_score(filename) }

          it 'scores the file' do
            expect(score).to eql(expected)
          end
        end
      end
    end

    context 'preferred license regex' do
      %w(md markdown txt).each do |ext|
        it "matches .#{ext}" do
          expect(described_class::PREFERRED_EXT_REGEX).to match(".#{ext}")
        end
      end

      it 'does not match .md2' do
        expect(described_class::PREFERRED_EXT_REGEX).to_not match('.md2')
      end

      it 'does not match .md/foo' do
        expect(described_class::PREFERRED_EXT_REGEX).to_not match('.md/foo')
      end
    end

    context 'any extension regex' do
      it 'matches .foo' do
        expect(described_class::ANY_EXT_REGEX).to match('.foo')
      end

      it 'does not match .md/foo' do
        expect(described_class::ANY_EXT_REGEX).to_not match('.md/foo')
      end
    end

    context 'license regex' do
      %w(LICENSE licence unlicense LICENSE-MIT MIT-LICENSE).each do |license|
        it "matches #{license}" do
          expect(described_class::LICENSE_REGEX).to match(license)
        end
      end
    end

    context 'copying regex' do
      %w(COPYING copyright).each do |copying|
        it "matches #{copying}" do
          expect(described_class::COPYING_REGEX).to match(copying)
        end
      end
    end
  end
end
