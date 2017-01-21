module Licensee
  module Matchers
    class DistZilla < Package
      attr_reader :file

      LICENSE_REGEX = /^license\s*=\s*([a-z\-0-9\._]+)/i

      private

      def license_property
        match = file.content.match LICENSE_REGEX
        spdx_name(match[1]).downcase if match && match[1]
      end

      CONVERT_PERL_LICENSE_NAME_TO_SPDX_NAME = {
        'AGPL_3'       => 'AGPL-3.0',
        'Apache_1_1'   => 'Apache-1.1',
        'Apache_2_0'   => 'Apache-2.0',
        'Artistic_1_0' => 'Artistic-1.0',
        'Artistic_2_0' => 'Artistic-2.0',
        'CC0_1_0'      => 'CC0-1.0',
        'GFDL_1_2'     => 'GFDL-1.2',
        'GFDL_1_3'     => 'GFDL-1.3',
        'GPL_1'        => 'GPL-1.0',
        'GPL_2'        => 'GPL-2.0',
        'GPL_3'        => 'GPL-3.0',
        'LGPL_2_1'     => 'LGPL-2.1',
        'LGPL_3_0'     => 'LGPL-3.0',
        'Mozilla_1_0'  => 'MPL-1.0',
        'Mozilla_1_1'  => 'MPL-1.1',
        'Mozilla_2_0'  => 'MPL-2.0',
        'QPL_1_0'      => 'QPL-1.0'
      }.freeze

      def spdx_name(perl_name)
        spdx = CONVERT_PERL_LICENSE_NAME_TO_SPDX_NAME[perl_name]
        return spdx if spdx
        perl_name
      end
    end
  end
end
