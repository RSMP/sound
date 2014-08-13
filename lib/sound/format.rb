

module Sound

  WAVE_FORMAT_PCM = 1
  
  class Format
  
    PCM = WAVE_FORMAT_PCM
    attr_accessor :channels, :sample_rate, :bps, :alsa_format
    def initialize(format_type = PCM)
      @channels = 1
      @sample_rate = 44100
      @bps = 16
      if OS.windows?
        @wfx = DeviceInterface::Win32::WAVEFORMATEX.new
        @wfx[:wFormatTag] = format_type
        @wfx[:nChannels] = channels
        @wfx[:nSamplesPerSec] = sample_rate
        @wfx[:wBitsPerSample] = bps
        @wfx[:cbSize] = 0
        @wfx[:nBlockAlign] = block_align
        @wfx[:nAvgBytesPerSec] = avg_bps
      end
    end
    def block_align
      (bps >> 3) * channels
    end
    def avg_bps
      block_align * sample_rate
    end
    def pointer
      if OS.windows?
        @wfx.pointer
      end
    end
  end
  
end