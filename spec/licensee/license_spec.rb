# frozen_string_literal: true

RSpec.describe Licensee::License do
  let(:license_count) { 49 }
  let(:hidden_license_count) { 36 }
  let(:featured_license_count) { 3 }
  let(:pseudo_license_count) { 2 }
  let(:non_featured_license_count) do
    license_count - featured_license_count - hidden_license_count
  end

  let(:mit) { described_class.find('mit') }
  let(:cc_by) { described_class.find('cc-by-4.0') }
  let(:unlicense) { described_class.find('unlicense') }
  let(:other) { described_class.find('other') }
  let(:no_license) { described_class.find('no-license') }
  let(:gpl) { described_class.find('gpl-3.0') }
  let(:lgpl) { described_class.find('lgpl-3.0') }
  let(:content_hash) { license_hashes['mit'] }

  let(:license_dir) do
    File.expand_path 'vendor/choosealicense.com/_licenses', project_root
  end

  context 'listing licenses' do
    let(:licenses) { described_class.all(arguments) }

    it 'returns the license keys' do
      expect(described_class.keys).to satisfy do |keys|
        keys.count == license_count && keys.include?(mit.key) && keys.include?('other')
      end
    end

    context 'without any arguments' do
      let(:arguments) { {} }

      it 'returns the licenses' do
        expect(licenses).to satisfy do |values|
          values.all?(described_class) && values.count == (license_count - hidden_license_count)
        end
      end

      it "doesn't include hidden licenses" do
        expect(licenses).to all(satisfy { |license| !license.hidden? })
      end

      it 'includes featured licenses' do
        expect(licenses).to satisfy do |values|
          values.include?(mit) && !values.include?(cc_by) && !values.include?(other)
        end
      end
    end

    context 'hidden licenses' do
      let(:arguments) { { hidden: true } }

      it 'includes hidden licenses' do
        expect(licenses).to satisfy do |values|
          values.include?(cc_by) && values.include?(mit) && values.count == license_count
        end
      end
    end

    context 'featured licenses' do
      let(:arguments) { { featured: true } }

      it 'includes only featured licenses' do
        expect(licenses).to satisfy do |values|
          values.include?(mit) && !values.include?(cc_by) && !values.include?(other) &&
            values.count == featured_license_count
        end
      end
    end

    context 'non-featured licenses' do
      let(:arguments) { { featured: false } }

      it 'includes only non-featured licenses' do
        expect(licenses).to satisfy do |values|
          values.include?(unlicense) && !values.include?(mit) && !values.include?(other) &&
            values.count == non_featured_license_count
        end
      end
    end

    context 'non-featured licenses including hidden licenses' do
      let(:arguments) { { featured: false, hidden: true } }

      it 'includes only non-featured licenses' do
        expect(licenses).to satisfy do |values|
          values.include?(unlicense) && values.include?(cc_by) && !values.include?(mit) &&
            values.count == (license_count - featured_license_count)
        end
      end
    end

    context 'pseudo licenses by default' do
      let(:arguments) { {} }

      it "doesn't include pseudo licenses" do
        expect(licenses).not_to include(other)
      end
    end

    context 'pseudo licenses with hidden licenses' do
      let(:arguments) { { hidden: true } }

      it 'includes pseudo licenses' do
        expect(licenses).to include(other)
      end
    end

    context 'pseudo licenses when explicitly asked' do
      let(:arguments) { { hidden: true, pseudo: true } }

      it 'includes psudo licenses' do
        expect(licenses).to include(other)
      end
    end

    context 'pseudo licenses when explicitly excluded' do
      let(:arguments) { { hidden: true, pseudo: false } }

      it "doesn'tincludes psudo licenses" do
        expect(licenses).not_to include(other)
      end
    end

    context 'pseudo licenses when explicitly asked (mispelled)' do
      let(:arguments) { { hidden: true, psuedo: true } }

      it 'includes psudo licenses' do
        expect(licenses).to include(other)
      end
    end

    context 'pseudo licenses when explicitly excluded (mispelled)' do
      let(:arguments) { { hidden: true, psuedo: false } }

      it "doesn'tincludes psudo licenses" do
        expect(licenses).not_to include(other)
      end
    end
  end

  context 'finding' do
    it 'finds the MIT license' do
      expect(described_class.find('mit')).to eql(mit)
    end

    it 'finds hidden licenses' do
      expect(described_class.find('cc-by-4.0')).to eql(cc_by)
    end

    it 'is case insensitive' do
      expect(described_class.find('MIT')).to eql(mit)
    end
  end

  it 'returns the license dir' do
    expect(described_class.license_dir).to satisfy do |dir|
      dir == license_dir && File.exist?(dir)
    end
  end

  it 'returns license files' do
    expected = license_count - pseudo_license_count
    expect(described_class.license_files).to satisfy do |files|
      files.count == expected && files.all? { |file| File.exist?(file) } && files.include?(mit.path)
    end
  end

  it 'stores the key when initialized' do
    expect([described_class.new('mit'), described_class.new('MIT')]).to all(eq(mit))
  end

  it 'exposes the path' do
    path = mit.path
    expect(path).to(satisfy { |value| File.exist?(value) && value.match?(described_class.license_dir) })
  end

  it 'exposes the key' do
    expect(mit.key).to eql('mit')
  end

  it 'exposes the SPDX ID' do
    expect(gpl.spdx_id).to eql('GPL-3.0')
  end

  it 'exposes special SPDX ID for pseudo licenses' do
    expect([other.spdx_id, no_license.spdx_id]).to eql(%w[NOASSERTION NONE])
  end

  describe '#other?' do
    it 'knows MIT is not other' do
      expect(gpl).not_to be_other
    end

    it 'knows the other license is other?' do
      expect(other).to be_other
    end
  end

  context 'meta' do
    it 'exposes license meta' do
      expect([mit.meta['title'], mit.meta.title]).to eql(['MIT License', 'MIT License'])
    end

    it 'includes defaults' do
      expect(other.meta['hidden']).to be(true)
    end

    it 'returns the name' do
      expect(mit.name).to eql('MIT License')
    end

    it 'uses the default name when none exists' do
      expect([other.name, no_license.name]).to eql(['Other', 'No license'])
    end

    it 'expoeses the nickname' do
      expect(gpl.nickname).to eql('GNU GPLv3')
    end

    it 'exposes the name without version' do
      expect([mit.name_without_version, gpl.name_without_version]).to eql(
        ['MIT License', 'GNU General Public License']
      )
    end

    it 'knows if a license is hidden' do
      expect([mit.hidden?, cc_by.hidden?]).to eql([false, true])
    end

    it 'knows if a license is featured' do
      expect([mit.featured?, unlicense.featured?]).to eql([true, false])
    end

    it 'knows if a license is GPL' do
      expect([mit.gpl?, gpl.gpl?]).to eql([false, true])
    end

    it 'knows a license is lgpl' do
      expect([mit.lgpl?, lgpl.lgpl?]).to eql([false, true])
    end

    it 'knows if a license is CC' do
      expect([gpl.creative_commons?, cc_by.creative_commons?]).to eql([false, true])
    end
  end

  context 'content' do
    it 'returns the license content' do
      expect(mit.content).to match('Permission is hereby granted')
    end

    it 'strips leading whitespace' do
      expect(mit.content).to start_with('M')
    end

    it 'computes the hash' do
      expect(mit.content_hash).to eql(content_hash)
    end

    it 'parses content with a horizontal rule when raw content is stubbed' do
      content = "---\nfoo: bar\n---\nSome license\n---------\nsome text\n"
      license = described_class.new 'MIT'
      license.instance_variable_set(:@raw_content, content)

      expect(license.content).to eql("Some license\n---------\nsome text\n")
    end
  end

  it 'returns the URL' do
    expect(mit.url).to eql('http://choosealicense.com/licenses/mit/')
  end

  it 'knows equality' do
    found = described_class.find('mit')
    expect([found == mit, found.eql?(mit), gpl.eql?(mit)]).to eql([true, true, false])
  end

  it 'returns false when compared to a boolean' do
    expect(described_class.find('mit')).not_to be(true)
  end

  it 'knows if a license is a pseudo license' do
    expect([mit.pseudo_license?, other.pseudo_license?]).to eql([false, true])
  end

  it 'fails loudly for invalid license' do
    expect do
      described_class.new('foo').name
    end.to raise_error(Licensee::InvalidLicense)
  end

  it 'returns the rules' do
    rules = mit.rules
    expect(rules).to satisfy do |value|
      value.is_a?(Licensee::LicenseRules) && value.key?('permissions') &&
        value['permissions'].first.is_a?(Licensee::Rule) && value.flatten.count == 7
    end
  end

  it 'returns limitation rule by tag for cc_by' do
    rule = cc_by.rules['limitations'].find { |r| r.tag == 'patent-use' }
    expect(rule).to(satisfy { |value| !value.nil? && value.description.include?('does NOT grant') })
  end

  it 'returns permission rule by tag for gpl' do
    rule = gpl.rules['permissions'].find { |r| r.tag == 'patent-use' }
    expect(rule).to satisfy do |value|
      !value.nil? && value.description.include?('an express grant of patent rights')
    end
  end

  context 'fields' do
    it 'returns the license fields' do
      expect([mit.fields.map(&:key), gpl.fields]).to eql([%w[year fullname], []])
    end

    context 'muscache' do
      let(:license) do
        license = described_class.new 'MIT'
        content = "#{license.content}[foo] [bar]"
        license.instance_variable_set(:@content, content)
        license
      end

      it 'returns mustache content' do
        content = license.content_for_mustache
        expect(content).to(satisfy do |value|
          value.match?(/{{{year}}}/) && value.match?(/{{{fullname}}}/) &&
            !value.include?('[year]') && !value.include?('[fullname]')
        end)
      end

      it "doesn't mangle other fields" do
        content = license.content_for_mustache
        expect(content).to(satisfy { |value| value.include?('[foo]') && !value.match?(/{{{foo}}}/) })
      end
    end
  end

  context 'License.title_regex' do
    namey = %i[title nickname key]
    described_class.all(hidden: true, pseudo: false).each do |license|
      namey.each do |variation|
        next if license.public_send(variation).nil?

        it "matches #{license.key} #{variation}" do
          text = license.public_send(variation).sub('*', 'u')
          expect([text.match?(license.title_regex), described_class.find_by_title(text)]).to eql([true, license])
        end

        it "matches #{license.key} #{variation} with 'the' and 'license'" do
          license_variation = license.public_send(variation).sub('*', 'u')
          text = "The #{license_variation} license"
          expect(text).to match(license.title_regex)
        end

        if /\bGNU\b/.match?(license.title)
          it "matches #{license.key} #{variation} without 'GNU'" do
            license_variation = license.public_send(variation).sub('*', 'u')
            text = license_variation.sub(/GNU /i, '')
            expect(text).to match(license.title_regex)
          end
        end

        next unless variation == :title

        it "matches #{license.key} title with 'version x.x'" do
          license_variation = license.title.sub('*', 'u')
          text = license_variation.sub(/v?(\d+\.\d+)/i, 'version \1')
          expect(text).to match(license.title_regex)
        end

        it "matches #{license.key} title with ', version x.x'" do
          license_variation = license.title.sub('*', 'u')
          text = license_variation.sub(/ v?(\d+\.\d+)/i, ', version \1')
          expect(text).to match(license.title_regex)
        end

        it "matches #{license.key} title with 'vx.x'" do
          license_variation = license.title.sub('*', 'u')
          text = license_variation.sub(/(?:version)? (\d+\.\d+)/i, ' v\1')
          expect(text).to match(license.title_regex)
        end
      end
    end

    context 'a license with an alt title' do
      let(:text) { 'The Clear BSD license' }
      let(:license) { described_class.find('bsd-3-clause-clear') }

      it 'matches' do
        expect(text).to match(license.title_regex)
      end

      it 'finds by title' do
        expect(described_class.find_by_title(text)).to eql(license)
      end
    end
  end

  context 'to_h' do
    let(:hash) { mit.to_h }
    let(:expected) do
      {
        key:     'mit',
        spdx_id: 'MIT',
        meta:    mit.meta.to_h,
        url:     'http://choosealicense.com/licenses/mit/',
        rules:   mit.rules.to_h,
        fields:  mit.fields.map(&:to_h),
        other:   false,
        gpl:     false,
        lgpl:    false,
        cc:      false
      }
    end

    it 'Converts to a hash' do
      expect(hash).to eql(expected)
    end
  end

  context 'source regex' do
    schemes = %w[http https]
    prefixes = ['www.', '']
    suffixes = ['.html', '.htm', '.txt', '']

    let(:build_source) do
      lambda do |license, scheme, prefix, suffix|
        source = URI.parse(license.source)
        source.scheme = scheme
        source.host = "#{prefix}#{source.host.delete_prefix('www.')}"

        unless license.key == 'wtfpl'
          regex = /#{Licensee::License::SOURCE_SUFFIX}\z/o
          source.path = "#{source.path.sub(regex, '')}#{suffix}"
        end

        source.to_s
      end
    end

    described_class.all(hidden: true, pseudo: false).each do |license|
      context "the #{license.title} license" do
        schemes.each do |scheme|
          prefixes.each do |prefix|
            suffixes.each do |suffix|
              it "matches with #{scheme}:// #{prefix.inspect} #{suffix.inspect}" do
                source = build_source.call(license, scheme, prefix, suffix)
                expect(source).to match(license.source_regex)
              end
            end
          end
        end
      end
    end
  end
end
