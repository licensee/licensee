RSpec.describe Licensee::License do
  let(:license_count) { 32 }
  let(:hidden_license_count) { 20 }
  let(:featured_license_count) { 3 }
  let(:pseudo_license_count) { 2 }
  let(:non_featured_license_count) do
    license_count - featured_license_count - hidden_license_count
  end

  let(:mit) { described_class.find('mit') }
  let(:cc_by) { described_class.find('cc-by-4.0') }
  let(:unlicense) { described_class.find('unlicense') }
  let(:other) { described_class.find('other') }
  let(:gpl) { described_class.find('gpl-3.0') }
  let(:lgpl) { described_class.find('lgpl-3.0') }

  let(:license_dir) do
    File.expand_path 'vendor/choosealicense.com/_licenses', project_root
  end

  context 'listing licenses' do
    let(:licenses) { described_class.all(arguments) }

    it 'returns the license keys' do
      expect(described_class.keys.count).to eql(license_count)
      expect(described_class.keys).to include(mit.key)
      expect(described_class.keys).to include('other')
    end

    context 'without any arguments' do
      let(:arguments) { {} }

      it 'returns the licenses' do
        expect(licenses).to all be_a(Licensee::License)
        expect(licenses.count).to eql(license_count - hidden_license_count)
      end

      it "doesn't include hidden licenses" do
        expect(licenses).to all(satisfy { |license| !license.hidden? })
      end

      it 'includes featured licenses' do
        expect(licenses).to include(mit)
        expect(licenses).to_not include(cc_by)
      end
    end

    context 'hidden licenses' do
      let(:arguments) { { hidden: true } }

      it 'includes hidden licenses' do
        expect(licenses).to include(cc_by)
        expect(licenses).to include(mit)
        expect(licenses.count).to eql(license_count)
      end
    end

    context 'featured licenses' do
      let(:arguments) { { featured: true } }

      it 'includes only featured licenses' do
        expect(licenses).to include(mit)
        expect(licenses).to_not include(cc_by)
        expect(licenses.count).to eql(featured_license_count)
      end
    end

    context 'non-featured licenses' do
      let(:arguments) { { featured: false } }

      it 'includes only non-featured licenses' do
        expect(licenses).to include(unlicense)
        expect(licenses).to_not include(mit)
        expect(licenses.count).to eql(non_featured_license_count)
      end

      context 'including hidden licenses' do
        let(:arguments) { { featured: false, hidden: true } }

        it 'includes only non-featured licenses' do
          expect(licenses).to include(unlicense)
          expect(licenses).to include(cc_by)
          expect(licenses).to_not include(mit)
          expect(licenses.count).to eql(license_count - featured_license_count)
        end
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
    expect(described_class.license_dir).to eql(license_dir)
    expect(described_class.license_dir).to be_an_existing_file
  end

  it 'returns license files' do
    expected = license_count - pseudo_license_count
    expect(described_class.license_files.count).to eql(expected)
    expect(described_class.license_files).to all be_an_existing_file
    expect(described_class.license_files).to include(mit.path)
  end

  it 'stores the key when initialized' do
    expect(described_class.new('mit')).to be == mit
    expect(described_class.new('MIT')).to be == mit
  end

  it 'exposes the path' do
    expect(mit.path).to be_an_existing_file
    expect(mit.path).to match(described_class.license_dir)
  end

  it 'exposes the key' do
    expect(mit.key).to eql('mit')
  end

  context 'meta' do
    it 'exposes license meta' do
      expect(mit).to respond_to(:meta)
      expect(mit.meta).to have_key('title')
      expect(mit.meta['title']).to eql('MIT License')
    end

    it 'includes defaults' do
      expect(other.meta['hidden']).to eql(true)
    end

    it 'returns the name' do
      expect(mit.name).to eql('MIT License')
    end

    it 'uses the default name when none exists' do
      expect(other.name).to eql('Other')
    end

    it 'expoeses the nickname' do
      expect(gpl.nickname).to eql('GNU GPLv3')
    end

    it 'exposes the name without version' do
      expect(mit.name_without_version).to eql('MIT License')
      expect(gpl.name_without_version).to eql('GNU General Public License')
    end

    it 'knows if a license is hidden' do
      expect(mit).to_not be_hidden
      expect(cc_by).to be_hidden
    end

    it 'knows if a license is featured' do
      expect(mit).to be_featured
      expect(unlicense).to_not be_featured
    end

    it 'knows if a license is GPL' do
      expect(mit).to_not be_gpl
      expect(gpl).to be_gpl
    end

    it 'knows a license is lgpl' do
      expect(mit).to_not be_gpl
      expect(lgpl).to be_lgpl
    end

    it 'knows if a license is CC' do
      expect(gpl).to_not be_creative_commons
      expect(cc_by).to be_creative_commons
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
      content_hash = 'd64f3bb4282a97b37454b5bb96a8a264a3363dc3'
      expect(mit.content_hash).to eql(content_hash)
    end

    context 'with content stubbed' do
      let(:license) do
        license = described_class.new 'MIT'
        license.instance_variable_set(:@raw_content, content)
        license
      end

      context 'with a horizontal rule' do
        let(:content) do
          "---\nfoo: bar\n---\nSome license\n---------\nsome text\n"
        end

        it 'parses the content' do
          expect(license.content).to eql("Some license\n---------\nsome text\n")
        end
      end
    end
  end

  it 'returns the URL' do
    expect(mit.url).to eql('http://choosealicense.com/licenses/mit/')
  end

  it 'knows equality' do
    expect(mit).to eql(mit)
    expect(gpl).to_not eql(mit)
  end

  it 'knows if a license is a pseudo license' do
    expect(mit).to_not be_pseudo_license
    expect(other).to be_pseudo_license
  end

  it 'fails loudly for invalid license' do
    expect do
      described_class.new('foo').name
    end.to raise_error(Licensee::InvalidLicense)
  end

  it 'returns the rules' do
    expect(mit.rules).to have_key('permissions')
    expect(mit.rules['permissions'].first).to be_a(Licensee::Rule)
    expect(mit.rules.flatten.count).to eql(6)
  end

  it 'returns rules by tag and group' do
    expect(cc_by.rules).to have_key('limitations')
    rule = cc_by.rules['limitations'].find { |r| r.tag == 'patent-use' }
    expect(rule).to_not be_nil
    expect(rule.description).to include('does NOT grant')

    expect(gpl.rules).to have_key('permissions')
    rule = gpl.rules['permissions'].find { |r| r.tag == 'patent-use' }
    expect(rule).to_not be_nil
    expect(rule.description).to include('an express grant of patent rights')
  end
end
