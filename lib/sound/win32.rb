require 'ffi'

module Sound
  module Win32
    
    class Handle
      def initialize
        @handle = HWAVEOUT.new
      end
      def pointer
        @handle.pointer
      end
      def id
        @handle[:i]
      end
    end

    extend FFI::Library

    typedef :ulong, :dword
    typedef :uintptr_t, :hwaveout
    typedef :uint, :mmresult
    
    ffi_lib :winmm
  
    attach_function :waveOutOpen, [:pointer, :uint, :pointer, :dword, :dword, :dword], :mmresult
    attach_function :waveOutPrepareHeader, [:hwaveout, :pointer, :uint], :mmresult
    attach_function :waveOutWrite, [:hwaveout, :pointer, :uint], :mmresult
    attach_function :waveOutUnprepareHeader, [:hwaveout, :pointer, :uint], :mmresult
    attach_function :waveOutClose, [:hwaveout], :mmresult
    
    WAVE_FORMAT_PCM = 1
    WAVE_MAPPER = -1
    DEFAULT_DEVICE_ID = WAVE_MAPPER
    
    def open_device
      waveOutOpen(handle.pointer, id, data.format.pointer, 0, 0, 0)
    end
    
    def prepare_buffer
      waveOutPrepareHeader(handle.id, header.pointer, header.size)
    end
    
    def write_to_device
      waveOutWrite(handle.id, header.pointer, header.size)
    end
    
    def unprepare_buffer
      while waveOutUnprepareHeader(handle.id, header.pointer, header.size) == 33
        sleep 0.001
      end
    end
    
    def close_device
      waveOutClose(handle.id)
    end
    
    def handle
      Thread.current[:handle] ||= Handle.new
    end
    
    def data
      Thread.current[:data]
    end
    
    def header
      Thread.current[:header] ||= WAVEHDR.new(data_buffer, buffer_length)
    end
    
    def data_buffer
      Thread.current[:data_buffer] ||= FFI::MemoryPointer.new(:int, data.pcm_data.size).write_array_of_int data.pcm_data
    end
    
    def buffer_length
      Thread.current[:buffer_length] ||= data.format.avg_bps*data.duration/1000
    end
    
    # Define an HWAVEOUT struct for use by all the waveOut functions.
    # It is a handle to a waveOut stream, so starting up multiple
    # streams using different handles allows for simultaneous playback.
    # You never need to actually look at the struct, C takes care of
    # its value.
    #
    class HWAVEOUT < FFI::Struct
      layout :i, :int
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

    #define WAVEHDR which is a header to a block of audio
    #lpData is a pointer to the block of native memory that,
    # in this case, is an integer array of PCM data

    class WAVEHDR < FFI::Struct
    
      # Initializes struct with sensible defaults for most commonly used
      # values.  While setting these manually is possible, please be
      # sure you know what changes will result in, as an incorrectly
      # set struct will result in unpredictable behavior.
      #
      def initialize(lpData, dwBufferLength, dwFlags = 0, dwLoops = 1)
        self[:lpData] = lpData
        self[:dwBufferLength] = dwBufferLength
        self[:dwFlags] = dwFlags
        self[:dwLoops] = dwLoops
      end
      
      layout(
        :lpData,          :pointer,
        :dwBufferLength,  :ulong,
        :dwBytesRecorded, :ulong,
        :dwUser,          :ulong,
        :dwFlags,         :ulong,
        :dwLoops,         :ulong,
        :lpNext,          :pointer,
        :reserved,        :ulong
      )
    end
    
  end
end
