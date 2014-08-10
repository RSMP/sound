
module Sound

  @verbose = false
  
  class << self
    attr_accessor :verbose
  end
  
  WAVE_MAPPER = -1
  
  class Device
    
    class Handle
      def initialize
        if OS.windows?
          @handle = Win32::HWAVEOUT.new
        elsif OS.linux?
          @handle = FFI::MemoryPointer.new(:pointer)
        end
      end
      def pointer
        if OS.windows?
          @handle.pointer
        elsif OS.linux?
          @handle
        end
      end
      def id
        if OS.windows?
          @handle[:i]
        elsif OS.linux?
          @handle.read_pointer
        end
      end
    end
  
    attr_accessor :closed, :id, :handle, :format
    
    def initialize(format = Format::PCM, direction = "w", id)
      if OS.windows?
        id ||= WAVE_MAPPER
      elsif OS.linux?
        id ||= "default"
      end
      @id = id
      closed = false
      @queue = []
      @mutex = Mutex.new
      @handle = Device::Handle.new
      @format = format
      @direction = direction
    end
  
    class << self
      # Opens a sound device for reading or writing
      # device is one of several devices, usually defined by a constant
      # direction is reading or writing or both
      # format is MIDI vs PCM or others
      # this method can take a block and if so closes the device after execution
      def open(device = Device::DEFAULT, direction = "w", format = Format::PCM, &block)
        device.format = format
        puts "opening device_#{device.id}" if Sound.verbose
        if block_given?
          block.call(device)
          device.close
        else
          device.closed = false
          device
        end
      end
    end
    
    def play(data = "beep boop")
      write(data)
      flush
    end
  
    def write(data = "beep boop")
      if closed?
        puts "cannot write to a closed device"
      else
        @mutex.lock
        @queue << Thread.new do
          write_thread(data)
        end
        @mutex.unlock
        puts "writing to device_#{id}_queue: #{data.class}" if Sound.verbose
      end
    end
    
    def close
      if closed?
        puts "cannot close a closed device"
      else
        flush
        puts "device is closing now" if Sound.verbose
        closed = true
      end
    end
    
    def flush
      until @queue.empty?
        output = @queue.shift
        output[:stop] = false
        puts "writing to device_#{id}: #{output}" if Sound.verbose
        output.run.join
      end
    end
    
    def closed?
      closed
    end
    
    def write_thread(data)
      Thread.current[:stop] = true if Thread.current[:stop].nil?
      if OS.windows?
        windows_write_thread(data)
      elsif OS.linux?
        linux_write_thread(data)
      else
        warn("warning: playback is not yet supported on this platform")
      end
    end
    
    def windows_write_thread(data)
      handle = Handle.new
      Win32::Sound.waveOutOpen(handle.pointer, id, format.pointer, 0, 0, 0)
      data_buffer = FFI::MemoryPointer.new(:int, data.data.size)
      data_buffer.write_array_of_int data.data
      buffer_length = format.avg_bps*data.duration/1000
      puts buffer_length
      header = Win32::WAVEHDR.new(data_buffer, buffer_length)
      Win32::Sound.waveOutPrepareHeader(handle.id, header.pointer, header.size)
      Thread.stop if Thread.current[:stop]
      Win32::Sound.waveOutWrite(handle.id, header.pointer, header.size)
      while Win32::Sound.waveOutUnprepareHeader(handle.id, header.pointer, header.size) == 33
        sleep 0.001
      end
      Win32::Sound.waveOutClose(handle.id)
    end
    
    def linux_write_thread(data)
      handle = Handle.new
      AlsaPCM::Sound.snd_pcm_open(handle.pointer, id, 0, 0)
      data_buffer = FFI::MemoryPointer.new(:int, data.data.size)
      data_buffer.write_array_of_int data.data
      buffer_length = data_buffer.size/2
      params = FFI::MemoryPointer.new(:pointer)
      AlsaPCM::Sound.snd_pcm_hw_params_malloc(params)
      AlsaPCM::Sound.snd_pcm_hw_params_any(handle.id, params.read_pointer)
      
      AlsaPCM::Sound.snd_pcm_hw_params_set_access(handle.id, params.read_pointer, 3)
      AlsaPCM::Sound.snd_pcm_hw_params_set_format(handle.id, params.read_pointer, 2)
      AlsaPCM::Sound.snd_pcm_hw_params_set_rate(handle.id, params.read_pointer, 44100, 0)
      AlsaPCM::Sound.snd_pcm_hw_params_set_channels(handle.id, params.read_pointer, 1)
      
      AlsaPCM::Sound.snd_pcm_hw_params(handle.id, params.read_pointer)
      AlsaPCM::Sound.snd_pcm_hw_params_free(params.read_pointer)
      
      AlsaPCM::Sound.snd_pcm_prepare(handle.id)
      Thread.stop if Thread.current[:stop]
      AlsaPCM::Sound.snd_pcm_writei(handle.id, data_buffer, buffer_length)
      
      sleep 0.5
      
      AlsaPCM::Sound.snd_pcm_close(handle.id)
      
    end
  end

end
