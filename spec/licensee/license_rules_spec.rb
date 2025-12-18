# frozen_string_literal: true

RSpec.describe Licensee::LicenseRules do
  subject(:rules) { mit.rules }

  let(:mit) { Licensee::License.find('mit') }

  Licensee::Rule.groups.each do |group|
    context "with the #{group} rule group" do
      it 'responds as a hash key string' do
        expect(rules[group]).to be_a(Array)
      end

      it 'responds as a hash key symbol' do
        expect(rules[group.to_sym]).to be_a(Array)
      end

      it 'responds as a method' do
        expect(rules.public_send(group.to_sym)).to be_a(Array)
      end
    end
  end

  context 'when created from a license' do
    subject(:rules) { described_class.from_license(mit) }

    it 'exposes the rules' do
      expect(rules.permissions.first.label).to eql('Commercial use')
    end
  end

  context 'when created from a meta' do
    subject(:rules) { described_class.from_meta(mit.meta) }

    it 'exposes the rules' do
      expect(rules.permissions.first.label).to eql('Commercial use')
    end
  end

  context 'when created from a hash' do
    subject(:rules) { described_class.from_hash(hash) }

    let(:hash) { { 'permissions' => Licensee::Rule.all } }

    it 'exposes the rules' do
      expect(rules.permissions.first.label).to eql('Commercial use')
    end
  end

  context 'when calling #to_h' do
    let(:hash) { rules.to_h }
    let(:expected) do
      {
        conditions:  rules.conditions.map(&:to_h),
        permissions: rules.permissions.map(&:to_h),
        limitations: rules.limitations.map(&:to_h)
      }
    end

    it 'Converts to a hash' do
      expect(hash).to eql(expected)
    end
  end
end
