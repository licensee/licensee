# frozen_string_literal: true

RSpec.describe Licensee::Projects::Project do
  subject(:project) { described_class.new }

  context 'when calling abstract methods on the base class' do
    it 'raises NotImplementedError for #files' do
      expect { project.send(:files) }.to raise_error(NotImplementedError, /Project#files/)
    end

    it 'raises NotImplementedError for #load_file' do
      expect { project.send(:load_file, nil) }.to raise_error(NotImplementedError, /Project#load_file/)
    end
  end
end
