RSpec.describe Licensee::Matchers::Copyright do
  let(:content) { 'Copyright 2015 Ben Balter' }
  let(:file) { Licensee::Project::LicenseFile.new(content, 'LICENSE.txt') }
  let(:mit) { Licensee::License.find('mit') }
  let(:no_license) { Licensee::License.find('no-license') }

  subject { described_class.new(file) }

  it 'stores the file' do
    expect(subject.file).to eql(file)
  end

  it 'matches' do
    expect(subject.match).to eql(no_license)
  end

  it 'has a confidence' do
    expect(subject.confidence).to eql(100)
  end

  {
    'Standard'              => 'Copyright (C) 2015 Ben Balter',
    'Unicode (C)-style'     => 'Copyright © 2015 Ben Balter',
    'Symbol only'           => '(C) 2015 Ben Balter',
    'UTF-8 Encoded'         => 'Copyright (c) 2010-2014 Simon Hürlimann',
    'Comma-separated date'  => 'Copyright (c) 2003, 2004 Ben Balter',
    'Hyphen-separated date' => 'Copyright (c) 2003-2004 Ben Balter',
    'ASCII-8BIT encoded'    => "Copyright \xC2\xA92015 Ben Balter`"
      .force_encoding('ASCII-8BIT'),
    'Full sentence'         => 'This software is copyright (c) 2016 by '\
      'John Smith.'
  }.each do |description, notice|
    context "with a #{description} notice" do
      let(:content) { notice }

      it 'matches' do
        expect(subject.match).to eql(no_license)
      end
    end
  end

  context 'with a license with a copyright notice' do
    let(:content) { sub_copyright_info(mit.content) }

    it "doesn't match" do
      expect(subject.match).to be_nil
    end
  end
end
