require 'sound/format_library/base'

module Sound
  module FormatLibrary
    module ALSA
      include FormatLibrary::Base
      DEFAULT_FORMAT = 0
    end
  end
end
