# frozen_string_literal: true

RSpec.describe Licensee::ProjectFiles::LicenseFile do
  subject(:license_file) { described_class.new(content, filename) }

  let(:filename) { 'LICENSE.txt' }
  let(:content) { sub_copyright_info(mit) }
  let(:content_hash) { license_hashes['mit'] }

  def gpl = Licensee::License.find('gpl-3.0')
  def mit = Licensee::License.find('mit')

  it 'parses the attribution' do
    expect(license_file.attribution).to eql('Copyright (c) 2018 Ben Balter')
  end

  context "when there's a random copyright-like line" do
    let(:content) { "Foo\nCopyright 2016 Ben Balter\nBar" }

    it "doesn't match" do
      expect(license_file.attribution).to be_nil
    end
  end

  context 'with an non-UTF-8-encoded license' do
    let(:content) { (+"\x91License\x93").force_encoding('windows-1251') }

    it "doesn't blow up" do
      expect(license_file.attribution).to be_nil
    end
  end

  context 'with a non-templated license' do
    let(:content) { sub_copyright_info(gpl) }

    it "doesn't match" do
      expect(license_file.attribution).to be_nil
    end
  end

  context 'with a copyright file' do
    let(:filename) { 'COPYRIGHT' }
    let(:content) { 'Copyright (C) 2015 Ben Balter' }

    it "doesn't match" do
      expect(license_file.attribution).to eql(content)
    end
  end

  it 'creates the wordset' do
    expect([license_file.wordset.count, license_file.wordset.first]).to eql([93, 'permission'])
  end

  it 'creates the hash' do
    expect(license_file.content_hash).to eql(content_hash)
  end

  context 'when scoring filenames' do
    {
      'license'             => 1.00,
      'LICENCE'             => 1.00,
      'unLICENSE'           => 1.00,
      'unlicence'           => 1.00,
      'license.md'          => 0.95,
      'LICENSE.md'          => 0.95,
      'license.txt'         => 0.95,
      'COPYING'             => 0.90,
      'copyRIGHT'           => 0.35,
      'COPYRIGHT.txt'       => 0.30,
      'copying.txt'         => 0.85,
      'LICENSE.MPL-2.0'     => 0.80,
      'LICENSE.php'         => 0.80,
      'LICENCE.docs'        => 0.80,
      'license.xml'         => 0.80,
      'copying.image'       => 0.75,
      'LICENSE-MIT'         => 0.70,
      'LICENSE_1_0.txt'     => 0.70,
      'COPYING-GPL'         => 0.65,
      'COPYRIGHT-BSD'       => 0.20,
      'MIT-LICENSE.txt'     => 0.60,
      'mit-license-foo.md'  => 0.60,
      'OFL.md'              => 0.50,
      'ofl.textile'         => 0.45,
      'ofl'                 => 0.40,
      'not-the-ofl'         => 0.00,
      'README.txt'          => 0.00,
      '.pip-license-ignore' => 0.00,
      'license-checks.xml'  => 0.00,
      'license_test.go'     => 0.00,
      'licensee.gemspec'    => 0.00,
      'LICENSE.spdx'        => 0.00

    }.each do |filename, expected|
      context "with a file named #{filename}" do
        it 'scores the file' do
          score = described_class.name_score(filename)
          expect(score).to eql(expected)
        end
      end
    end

    {
      'COPYING.lesser' => 1,
      'copying.lesser' => 1,
      'license.lesser' => 0,
      'LICENSE.md'     => 0,
      'FOO.md'         => 0
    }.each do |filename, expected|
      it "LGPL scoring for #{filename}" do
        expect(described_class.lesser_gpl_score(filename)).to eql(expected)
      end
    end

    context 'when matching preferred license regex' do
      %w[md markdown txt].each do |ext|
        it "matches .#{ext}" do
          expect(described_class::PREFERRED_EXT_REGEX).to match(".#{ext}")
        end
      end

      it 'does not match .md2' do
        expect(described_class::PREFERRED_EXT_REGEX).not_to match('.md2')
      end

      it 'does not match .md/foo' do
        expect(described_class::PREFERRED_EXT_REGEX).not_to match('.md/foo')
      end
    end

    context 'when matching any extension regex' do
      it 'matches .foo' do
        expect(described_class::OTHER_EXT_REGEX).to match('.foo')
      end

      it 'does not match .md/foo' do
        expect(described_class::OTHER_EXT_REGEX).not_to match('.md/foo')
      end
    end

    context 'when matching license regex' do
      %w[LICENSE licence unlicense LICENSE-MIT MIT-LICENSE].each do |license|
        it "matches #{license}" do
          expect(described_class::LICENSE_REGEX).to match(license)
        end
      end
    end
  end

  context 'with CC false positives' do
    let(:regex) { Licensee::ProjectFiles::LicenseFile::CC_FALSE_POSITIVE_REGEX }

    it "knows MIT isn't a potential false positive" do
      detection = [
        license_file.content.match?(regex),
        be_a_potential_false_positive.matches?(license_file)
      ]
      expect(detection).to eql([false, false])
    end

    context 'with a CC false positive with creative commons in the title' do
      let(:content) { 'Creative Commons Attribution-NonCommercial 4.0' }

      it "knows it's a potential false positive" do
        detection = [
          license_file.content.match?(regex),
          be_a_potential_false_positive.matches?(license_file)
        ]
        expect(detection).to eql([true, true])
      end
    end

    context 'with a CC false positive without creative commons in the title' do
      let(:content) { 'Attribution-NonCommercial 4.0 International' }

      it "knows it's a potential false positive" do
        detection = [
          license_file.content.match?(regex),
          be_a_potential_false_positive.matches?(license_file)
        ]
        expect(detection).to eql([true, true])
      end
    end

    context 'with CC-BY-ND' do
      let(:content) { 'Attribution-NoDerivatives 4.0 International' }

      it "knows it's a potential false positive" do
        detection = [
          license_file.content.match?(regex),
          be_a_potential_false_positive.matches?(license_file)
        ]
        expect(detection).to eql([true, true])
      end
    end

    context 'with CC-BY-ND with leading instructions' do
      let(:content) do
        <<~LICENSE
          Creative Commons Corporation ("Creative Commons") is not a law firm
          ======================================================================
          Creative Commons Attribution-NonCommercial 4.0
        LICENSE
      end

      it "knows it's a potential false positive" do
        detection = [
          license_file.content.match?(regex),
          be_a_potential_false_positive.matches?(license_file)
        ]
        expect(detection).to eql([true, true])
      end
    end
  end

  context 'with LGPL' do
    let(:lgpl) { Licensee::License.find('lgpl-3.0') }
    let(:content) { sub_copyright_info(lgpl) }

    context 'with a COPYING.lesser file' do
      let(:filename) { 'COPYING.lesser' }

      it 'knows when a license file is LGPL' do
        file = described_class.new(sub_copyright_info(lgpl), filename)
        expect(file).to be_lgpl
      end

      it 'is not lgpl with non-lgpl content' do
        file = described_class.new(sub_copyright_info(mit), filename)
        expect(file).not_to be_lgpl
      end
    end

    context 'with a different file name' do
      let(:filename) { 'COPYING' }

      it 'is not lgpl' do
        expect(license_file).not_to be_lgpl
      end
    end
  end

  context 'with GPL' do
    let(:content) { sub_copyright_info(gpl) }

    it 'knows its GPL' do
      expect(license_file).to be_gpl
    end

    context 'with another license' do
      let(:content) { sub_copyright_info(mit) }

      it 'is not GPL' do
        expect(license_file).not_to be_gpl
      end
    end
  end

  context 'with an unknown license' do
    let(:content) { 'foo' }
    let(:other) { Licensee::License.find('other') }

    it 'matches to other' do
      expect(license_file.license).to eql(other)
    end
  end

  context 'when checking copyright?' do
    context 'with a copyright file' do
      let(:content) { 'Copyright 2017 Ben Balter' }
      let(:filename) { 'COPYRIGHT.txt' }

      it "knows it's a copyright file" do
        expect(license_file.send(:copyright?)).to be_truthy
      end
    end

    context 'with a copyright file with license text' do
      let(:filename) { 'COPYRIGHT.txt' }

      it "knows it's not a copyright file" do
        expect(license_file.send(:copyright?)).to be_falsy
      end
    end

    context 'with a license file with copyright text' do
      let(:content) { 'Copyright 2017 Ben Balter' }

      it "knows it's not a copyright file" do
        expect(license_file.send(:copyright?)).to be_falsy
      end
    end
  end
end
