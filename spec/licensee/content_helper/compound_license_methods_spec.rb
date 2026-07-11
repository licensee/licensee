# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Licensee::ContentHelper::CompoundLicenseMethods do
  describe '.extract_primary_section' do
    let(:separator) { "#{'=' * 79}\n" }

    it 'returns text unchanged when no component sections exist' do
      text = "MIT License\n\nPermission is hereby granted\n"
      expect(described_class.extract_primary_section(text)).to eq(text)
    end

    it 'truncates before per-file component license sections' do
      text = <<~LICENSE
        Project preamble

        #{separator}Project is distributed under the 3-clause BSD license:

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met.

        #{separator}src/ext/helper.c is licensed under the following license:

        Permission is hereby granted, free of charge, to any person obtaining a copy
      LICENSE

      result = described_class.extract_primary_section(text)
      expect(result).to include('3-clause BSD')
      expect(result).not_to include('src/ext/helper.c')
    end

    it 'does not truncate MPL-style title separators' do
      text = <<~LICENSE
        Mozilla Public License Version 2.0
        ==================================

        1. Definitions
      LICENSE

      expect(described_class.extract_primary_section(text)).to eq(text)
    end
  end
end

RSpec.describe Licensee::ProjectFiles::LicenseFile do
  describe 'compound aggregated LICENSE files' do
    let(:separator) { "#{'=' * 79}\n" }
    let(:content) do
      <<~LICENSE
        This file contains the license for ExampleProject.

        #{separator}ExampleProject is distributed under the "3-clause BSD" license:

        Copyright (c) 2001-2019, Example Authors

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.

            * Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following disclaimer
        in the documentation and/or other materials provided with the
        distribution.

            * Neither the names of the copyright owners nor the names of its
        contributors may be used to endorse or promote products derived from
        this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
        "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
        LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
        A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
        OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
        SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
        LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
        DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
        THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
        OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
        #{separator}src/ext/strlcat.c and src/ext/strlcpy.c are licensed under the following license:

         Permission is hereby granted, free of charge, to any person obtaining a copy
         of this software and associated documentation files (the "Software"), to deal
         in the Software without restriction, including without limitation the rights
         to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
         copies of the Software, and to permit persons to whom the Software is
         furnished to do so, subject to the following conditions:

        #{separator}Attribution-ShareAlike adapted remix share alike noncommercial commercial
        Creative Commons decorative vocabulary to trigger false positives when merged
      LICENSE
    end

    subject(:license_file) { described_class.new(content, 'LICENSE') }

    it 'detects the primary BSD-3-Clause license instead of a CC false positive' do
      expect(license_file.license.key).to eq('bsd-3-clause')
    end
  end
end
