

module Sound
  
  class Format
    attr_accessor :channels, :sample_rate, :bps
    def initialize(format_type = WAVE_FORMAT_PCM)
      channels = 1
      sample_rate = 44100
      bps = 16
    end
    PCM = self.new
    def block_align
      (bps >> 3) * channels
    end
    def avg_bps
      block_align * sample_rate
    end
  end
  
end