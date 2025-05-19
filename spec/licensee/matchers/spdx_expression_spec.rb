# frozen_string_literal: true

RSpec.describe Licensee::Matchers::SpdxExpression do
  let(:mit) { Licensee::License.find('mit') }
  let(:content) { "Copyright 2020\n\nSPDX-License-Identifier: #{license_expression}" }
  let(:file) { Licensee::ProjectFiles::LicenseFile.new(content, 'LICENSE.md') }
  let(:matcher) { described_class.new(file) }
  let(:license_expression) { 'MIT' }

  it 'matches on SPDX license expressions' do
    expect(matcher.match).to eql(mit)
  end

  it 'handles OR expressions' do
    bsd = Licensee::License.find('bsd-3-clause')
    or_expression = 'MIT OR BSD-3-Clause'
    or_content = content.sub(license_expression, or_expression)
    or_file = Licensee::ProjectFiles::LicenseFile.new(or_content, 'LICENSE.md')
    or_matcher = described_class.new(or_file)

    # Currently, our implementation returns the first license in the expression
    # Future work could enhance this to return a complex license object
    expect(or_matcher.match).to eql(mit)
  end

  it 'handles AND expressions' do
    apache = Licensee::License.find('apache-2.0')
    and_expression = 'MIT AND Apache-2.0'
    and_content = content.sub(license_expression, and_expression)
    and_file = Licensee::ProjectFiles::LicenseFile.new(and_content, 'LICENSE.md')
    and_matcher = described_class.new(and_file)

    # Currently, our implementation returns the first license in the expression
    # Future work could enhance this to return a complex license object
    expect(and_matcher.match).to eql(mit)
  end

  it 'handles -or-later expressions' do
    gpl = Licensee::License.find('gpl-2.0')
    or_later_expression = 'GPL-2.0-or-later'
    or_later_content = content.sub(license_expression, or_later_expression)
    or_later_file = Licensee::ProjectFiles::LicenseFile.new(or_later_content, 'LICENSE.md')
    or_later_matcher = described_class.new(or_later_file)

    # For 'or-later' expressions, it should match the base license
    expect(or_later_matcher.match).to eql(gpl)
  end

  it 'has a confidence of 100' do
    expect(matcher.confidence).to eql(100)
  end
end