

module Sound

  WAVE_FORMAT_PCM = 1
  
  class Format
    attr_accessor :channels, :sample_rate, :bps
    def initialize(format_type = WAVE_FORMAT_PCM)
      @wfx = Win32::WAVEFORMATEX.new
      @channels = 1
      @sample_rate = 44100
      @bps = 16
      @wfx[:wFormatTag] = format_type
      @wfx[:nChannels] = channels
      @wfx[:nSamplesPerSec] = sample_rate
      @wfx[:wBitsPerSample] = bps
      @wfx[:cbSize] = 0
      @wfx[:nBlockAlign] = block_align
      @wfx[:nAvgBytesPerSec] = avg_bps
    end
    def block_align
      (bps >> 3) * channels
    end
    def avg_bps
      block_align * sample_rate
    end
    def pointer
      @wfx.pointer
    end
    PCM = self.new
  end
  
end