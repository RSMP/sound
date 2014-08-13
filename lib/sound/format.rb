require 'sound/format_interface'

module Sound
  
  class Format
    attr_accessor :channels, :sample_rate, :bits_per_sample, :type
    alias :bps :bits_per_sample
    def initialize(type = DEFAULT_FORMAT)
      @channels = 1
      @sample_rate = 44100
      @bits_per_sample = 16
      @type = type
      new_format
    end
  end
  
end