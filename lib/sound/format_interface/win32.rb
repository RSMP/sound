require 'sound/format_interface/base'

module Sound
  module FormatInterface
    module Win32
      include FormatInterface::Base
    
      WAVE_FORMAT_PCM = 1
      DEFAULT_FORMAT = WAVE_FORMAT_PCM
      
      attr_accessor :wfx
      
      def new_format
        self.wfx = WAVEFORMATEX.new
        self.wfx[:wFormatTag] = type
        self.wfx[:nChannels] = channels
        self.wfx[:nSamplesPerSec] = sample_rate
        self.wfx[:wBitsPerSample] = bps
        self.wfx[:cbSize] = 0
        self.wfx[:nBlockAlign] = block_align
        self.wfx[:nAvgBytesPerSec] = avg_bps
      end
      
      def pointer
        self.wfx.pointer
      end

      # Define WAVEFORMATEX which defines the format (PCM in this case)
      # and various properties like sampling rate, number of channels, etc.
      #
      class WAVEFORMATEX < FFI::Struct
    
        # Initializes struct with sensible defaults for most commonly used
        # values.  While setting these manually is possible, please be
        # sure you know what changes will result in, as an incorrectly
        # set struct will result in unpredictable behavior.
        #
        def initialize(nSamplesPerSec = 44100, wBitsPerSample = 16, nChannels = 1, cbSize = 0)
          self[:wFormatTag] = WAVE_FORMAT_PCM
          self[:nChannels] = nChannels
          self[:nSamplesPerSec] = nSamplesPerSec
          self[:wBitsPerSample] = wBitsPerSample
          self[:cbSize] = cbSize
          self[:nBlockAlign] = (self[:wBitsPerSample] >> 3) * self[:nChannels]
          self[:nAvgBytesPerSec] = self[:nBlockAlign] * self[:nSamplesPerSec]
        end
      
        layout(
          :wFormatTag,      :ushort,
          :nChannels,       :ushort,
          :nSamplesPerSec,  :ulong,
          :nAvgBytesPerSec, :ulong,
          :nBlockAlign,     :ushort,
          :wBitsPerSample,  :ushort,
          :cbSize,          :ushort
        )
      end
    
    end
  end
end
