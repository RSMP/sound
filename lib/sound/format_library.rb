require 'forwardable'

module Sound
  module FormatLibrary
    #extend Forwardable
    DEFAULT_FORMAT = Sound.format_library::DEFAULT_FORMAT
    include Sound.format_library
    #duties = [
    #  :new_format,
    #  :pointer,
    #  :avg_bps
    #]
    #delegate duties => Sound.format_library
  end
end
