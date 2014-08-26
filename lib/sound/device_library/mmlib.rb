#gem 'ffi', '=1.3.1'
require 'ffi'

module Sound
  module DeviceLibrary
    module MMLib
      extend self
      
      class Handle
        def initialize
          @handle = FFI::MemoryPointer.new(:pointer)
        end
        def pointer
          @handle
        end
        def id
          @handle.read_int
        end
      end

      extend FFI::Library

      typedef :ulong, :dword
      typedef :uintptr_t, :hwaveout
      typedef :uint, :mmresult
      
      ffi_lib :winmm
      ffi_convention :stdcall
    
      callback :waveOutProc, [:hwaveout, :uint, :pointer, :ulong, :ulong], :void
      attach_function :waveOutOpen, [:pointer, :uint, :pointer, :dword, :dword, :dword], :mmresult
      attach_function :waveOutPrepareHeader, [:hwaveout, :pointer, :uint], :mmresult
      attach_function :waveOutWrite, [:hwaveout, :pointer, :uint], :mmresult
      attach_function :waveOutUnprepareHeader, [:hwaveout, :pointer, :uint], :mmresult
      attach_function :waveOutClose, [:hwaveout], :mmresult
      attach_function :midiOutOpen, [:pointer, :uint, :dword, :dword, :dword], :mmresult
      attach_function :midiOutClose, [:uintptr_t], :mmresult
      attach_function :midiOutShortMsg, [:uintptr_t, :ulong], :mmresult
      
      WaveOutProc = Proc.new do |hwo, uMsg, dwInstance, dwParam1, dwParam2|
        # explicit returns in this callback will result in an error
        case uMsg
        when WOM_OPEN
          puts "haha"
          sleep 3
        when WOM_DONE
          block_mutex.lock
          dwInstance.write_int(dwInstance.read_int + 1)
          block_mutex.unlock
        when WOM_CLOSE
        end
      end
      
      WAVE_MAPPER = -1
      DEFAULT_DEVICE_ID = WAVE_MAPPER
      
      WOM_OPEN = 0x3BB
      WOM_CLOSE = 0x3BC
      WOM_DONE = 0x3BD
      CALLBACK_FUNCTION = 0x30000
      
      def play_midi_notes
        handle = FFI::MemoryPointer.new(:pointer)
        midiOutOpen(handle, -1, 0, 0, 0)
        midiOutShortMsg(handle.read_int, 0x007F3C90)
        sleep 0.3
        midiOutShortMsg(handle.read_int, 0x007F4090)
        sleep 0.3
        midiOutShortMsg(handle.read_int, 0x007F4390)
        sleep 2
        midiOutShortMsg(handle.read_int, 0x00003C90)
        midiOutShortMsg(handle.read_int, 0x00004090)
        midiOutShortMsg(handle.read_int, 0x00004390)
        midiOutClose(handle.read_int)
      end
      
      def play_with_multiple_buffers(buffer_count = 2)
      
        data = Sound::Data.new.sine_wave(440, 200, 1)
        free_blocks.write_int buffer_count
        waveOutOpen(handle, id, data.format.pointer, WaveOutProc, free_blocks.address, CALLBACK_FUNCTION)
      
        data = data.data
      
        data1 = data[0...(data.length/2)]
        data_buffer = FFI::MemoryPointer.new(:int, data1.size)
        data_buffer.write_array_of_int data1
        buffer_length = wfx[:nAvgBytesPerSec]*100/1000
        header = WAVEHDR.new(data_buffer, buffer_length)
        waveOutPrepareHeader(handle.id, header.pointer, header.size)
        block_mutex.lock
        free_blocks.write_int(free_blocks.read_int - 1)
        block_mutex.unlock
        
        
        data2 = data[(data.length/2)..-1]
        data_buffer = FFI::MemoryPointer.new(:int, data2.size)
        data_buffer.write_array_of_int data2
        buffer_length = wfx[:nAvgBytesPerSec]*100/1000
        header = WAVEHDR.new(data_buffer, buffer_length)
        waveOutPrepareHeader(handle.id, header2.pointer, header2.size)
        block_mutex.lock
        free_blocks.write_int(free_blocks.read_int - 1)
        block_mutex.unlock
        
        waveOutWrite(handle.id, header.pointer, header.size)
        waveOutWrite(handle.id, header2.pointer, header2.size)
        
        until free_blocks.read_int == 2
          sleep 0.01
        end

        waveOutUnprepareHeader(handle.id, header.pointer, header.size)
        waveOutUnprepareHeader(handle.id, header2.pointer, header2.size)
        
        waveOutClose(handle.id)
        
      end
      
      def open_device(device)
        waveOutOpen(handle.pointer, device.id, data.format.pointer, 0, 0, 0)
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

      private
      
      def handle
        Thread.current[:handle] ||= Handle.new
      end
      
      def data
        Thread.current[:data] ||= Sound::Data.new
      end
      
      def data_buffer
        Thread.current[:data_buffer] ||= FFI::MemoryPointer.new(:int, data.pcm_data.size).write_array_of_int data.pcm_data
      end
      
      def header
        Thread.current[:header] ||= WAVEHDR.new(data_buffer, buffer_length)
      end
      
      def buffer_length
        Thread.current[:buffer_length] ||= data.format.avg_bps*data.duration/1000
      end
      
      def free_blocks
        Thread.current[:free_blocks] ||= FFI::MemoryPointer.new(:ulong)
      end
      
      def block_mutex
        Thread.current[:block_mutex] ||= Mutex.new
      end
      
      def pointer
        self.wfx.pointer
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