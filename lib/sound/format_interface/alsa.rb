require 'sound/format_interface/base'

module Sound
  module FormatInterface
    module ALSA
      include FormatInterface::Base
      DEFAULT_FORMAT = 0
    end
  end
end
