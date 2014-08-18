require 'ffi'

module Sound
  module DeviceLibrary
    module ALSA
      extend self
      
      class Handle
        def initialize
          @handle = FFI::MemoryPointer.new(:pointer)
        end
        def pointer
          @handle
        end
        def id
          @handle.read_pointer
        end
      end

      SND_PCM_STREAM_PLAYBACK = 0
      SND_PCM_STREAM_CAPTURE = 1
      DEFAULT_DEVICE_ID = "default"
      
      extend FFI::Library
      ffi_lib 'asound'
      ffi_convention :stdcall
      
      attach_function :snd_pcm_open, [:pointer, :string, :int, :int], :int
      attach_function :snd_pcm_close, [:pointer], :int
      attach_function :snd_pcm_drain, [:pointer], :int
      attach_function :snd_pcm_prepare, [:pointer], :int
      attach_function :write_noninterleaved, :snd_pcm_writen, [:pointer, :pointer, :ulong], :long
      attach_function :snd_pcm_writei, [:pointer, :pointer, :ulong], :long
      attach_function :snd_pcm_hw_params_malloc, [:pointer], :int
      attach_function :snd_pcm_hw_params_any, [:pointer, :pointer], :int
      attach_function :snd_pcm_hw_params_set_access, [:pointer, :pointer, :int], :int
      attach_function :snd_pcm_hw_params_set_format, [:pointer, :pointer, :int], :int
      attach_function :snd_pcm_hw_params_set_rate, [:pointer, :pointer, :uint, :int], :int
      attach_function :snd_pcm_hw_params_set_channels, [:pointer, :pointer, :int], :int
      attach_function :snd_pcm_hw_params, [:pointer, :pointer], :int
      attach_function :snd_pcm_hw_params_free, [:pointer], :void
      
      def self.snd_pcm_open(*args)
        output = `aplay -l 2>&1`
        if output.match(/no soundcard/m)
          raise NoDeviceError, "No sound devices present"
        elsif output.match(/not found/m)
          raise NoDependencyError,
            "aplay is not present in your environment. Install alsa-utils package for audio playback."
        else
          snd_pcm_open(*args)
        end
      end
      
      def open_device(device)
        begin
          self.snd_pcm_open(handle.pointer, device.id, 0, ASYNC)
        rescue NoDeviceError
          Sound.no_device = true
        end
      end
      
      def prepare_buffer
        
        unless Sound.no_device
          buffer_length
          set_params
          snd_pcm_prepare(handle.id)
        end
        
      end
      
      def write_to_device
        snd_pcm_writei(handle.id, data_buffer, buffer_length) unless Sound.no_device
      end
      
      def unprepare_buffer
        snd_pcm_drain(handle.id) unless Sound.no_device
      end
      
      def close_device
        snd_pcm_close(handle.id) unless Sound.no_device
      end
      
      def params_handle
        Thread.current[:params_handle] ||= Handle.new
      end
      
      def buffer_length
        Thread.current[:buffer_length] ||= data_buffer.size/2
      end
      
      def handle
        Thread.current[:handle] ||= Handle.new
      end
      
      def data
        Thread.current[:data] ||= Sound::Data.new
      end
      
      def data_buffer
        Thread.current[:data_buffer] ||= FFI::MemoryPointer.new(:int, data.pcm_data.size).write_array_of_int data.pcm_data
      end
      
      def set_params
          
          snd_pcm_hw_params_malloc(params_handle.pointer)
          snd_pcm_hw_params_any(handle.id, params_handle.id)
          
          snd_pcm_hw_params_set_access(handle.id, params_handle.id, SND_PCM_ACCESS_RW_INTERLEAVED)
          snd_pcm_hw_params_set_format(handle.id, params_handle.id, SND_PCM_FORMAT_S16_LE)
          # need to change this to set_rate_near at some point
          snd_pcm_hw_params_set_rate(handle.id, params_handle.id, data.format.sample_rate, 0)
          snd_pcm_hw_params_set_channels(handle.id, params_handle.id, data.format.channels)
          
          snd_pcm_hw_params(handle.id, params_handle.id)
          snd_pcm_hw_params_free(params_handle.id)
      
      end
      
      SND_PCM_ASYNC = 2
      ASYNC = SND_PCM_ASYNC
      #snd_pcm formats
      # Unknown 
      SND_PCM_FORMAT_UNKNOWN = -1
      # Signed 8 bit 
      SND_PCM_FORMAT_S8 = 0
      # Unsigned 8 bit 
      SND_PCM_FORMAT_U8 = 1
      # Signed 16 bit Little Endian 
      SND_PCM_FORMAT_S16_LE = 2
      # Signed 16 bit Big Endian 
      SND_PCM_FORMAT_S16_BE = 3
      # Unsigned 16 bit Little Endian 
      SND_PCM_FORMAT_U16_LE = 4
      # Unsigned 16 bit Big Endian 
      SND_PCM_FORMAT_U16_BE = 5
      # Signed 24 bit Little Endian using low three bytes in 32-bit word 
      SND_PCM_FORMAT_S24_LE = 6
      # Signed 24 bit Big Endian using low three bytes in 32-bit word 
      SND_PCM_FORMAT_S24_BE = 7
      # Unsigned 24 bit Little Endian using low three bytes in 32-bit word 
      SND_PCM_FORMAT_U24_LE = 8
      # Unsigned 24 bit Big Endian using low three bytes in 32-bit word 
      SND_PCM_FORMAT_U24_BE = 9
      # Signed 32 bit Little Endian 
      SND_PCM_FORMAT_S32_LE = 10
      # Signed 32 bit Big Endian 
      SND_PCM_FORMAT_S32_BE = 11
      # Unsigned 32 bit Little Endian 
      SND_PCM_FORMAT_U32_LE = 12
      # Unsigned 32 bit Big Endian 
      SND_PCM_FORMAT_U32_BE = 13
      # Float 32 bit Little Endian, Range -1.0 to 1.0 
      SND_PCM_FORMAT_FLOAT_LE = 14
      # Float 32 bit Big Endian, Range -1.0 to 1.0 
      SND_PCM_FORMAT_FLOAT_BE = 15
      # Float 64 bit Little Endian, Range -1.0 to 1.0 
      SND_PCM_FORMAT_FLOAT64_LE = 16
      # Float 64 bit Big Endian, Range -1.0 to 1.0 
      SND_PCM_FORMAT_FLOAT64_BE = 17
      # IEC-958 Little Endian 
      SND_PCM_FORMAT_IEC958_SUBFRAME_LE = 18
      # IEC-958 Big Endian 
      SND_PCM_FORMAT_IEC958_SUBFRAME_BE = 19
      # Mu-Law 
      SND_PCM_FORMAT_MU_LAW = 20
      # A-Law 
      SND_PCM_FORMAT_A_LAW = 21
      # Ima-ADPCM 
      SND_PCM_FORMAT_IMA_ADPCM = 22
      # MPEG 
      SND_PCM_FORMAT_MPEG = 23
      # GSM 
      SND_PCM_FORMAT_GSM = 24
      # Special 
      SND_PCM_FORMAT_SPECIAL = 31
      # Signed 24bit Little Endian in 3bytes format 
      SND_PCM_FORMAT_S24_3LE = 32
      # Signed 24bit Big Endian in 3bytes format 
      SND_PCM_FORMAT_S24_3BE = 33
      # Unsigned 24bit Little Endian in 3bytes format 
      SND_PCM_FORMAT_U24_3LE = 34
      # Unsigned 24bit Big Endian in 3bytes format 
      SND_PCM_FORMAT_U24_3BE = 35
      # Signed 20bit Little Endian in 3bytes format 
      SND_PCM_FORMAT_S20_3LE = 36
      # Signed 20bit Big Endian in 3bytes format 
      SND_PCM_FORMAT_S20_3BE = 37
      # Unsigned 20bit Little Endian in 3bytes format 
      SND_PCM_FORMAT_U20_3LE = 38
      # Unsigned 20bit Big Endian in 3bytes format 
      SND_PCM_FORMAT_U20_3BE = 39
      # Signed 18bit Little Endian in 3bytes format 
      SND_PCM_FORMAT_S18_3LE = 40
      # Signed 18bit Big Endian in 3bytes format 
      SND_PCM_FORMAT_S18_3BE = 41
      # Unsigned 18bit Little Endian in 3bytes format 
      SND_PCM_FORMAT_U18_3LE = 42
      # Unsigned 18bit Big Endian in 3bytes format 
      SND_PCM_FORMAT_U18_3BE = 43
      SND_PCM_FORMAT_LAST = SND_PCM_FORMAT_U18_3BE
      
      #snd_pcm access
      # mmap access with simple interleaved channels
      SND_PCM_ACCESS_MMAP_INTERLEAVED = 0
      # mmap access with simple non interleaved channels
      SND_PCM_ACCESS_MMAP_NONINTERLEAVED = 1
      # mmap access with complex placement
      SND_PCM_ACCESS_MMAP_COMPLEX = 2
      # snd_pcm_readi/snd_pcm_writei access
      SND_PCM_ACCESS_RW_INTERLEAVED = 3
      # snd_pcm_readn/snd_pcm_writen access
      SND_PCM_ACCESS_RW_NONINTERLEAVED = 4
      SND_PCM_ACCESS_LAST = SND_PCM_ACCESS_RW_NONINTERLEAVED
      
    end
  end
end