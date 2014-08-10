
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
          @hWaveOut = Win32::HWAVEOUT.new
        end
      end
      def pointer
        if OS.windows?
          @hWaveOut.pointer
        end
      end
      def id
        if OS.windows?
          @hWaveOut[:i]
        end
      end
    end
  
    attr_accessor :closed, :id, :handle, :format
    
    def initialize(format = Format::PCM, direction = "w", id = WAVE_MAPPER)
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
      else
        warn("playback is not yet supported on this platform")
      end
    end
    
    def windows_write_thread(data)
      handle = Handle.new
      Win32::Sound.waveOutOpen(handle.pointer, id, format.pointer, 0, 0, 0)
      data_buffer = FFI::MemoryPointer.new(:int, data.data.size)
      data_buffer.write_array_of_int data.data
      buffer_length = format.avg_bps*data.duration/1000
      header = Win32::WAVEHDR.new(data_buffer, buffer_length)
      Win32::Sound.waveOutPrepareHeader(handle.id, header.pointer, header.size)
      puts Thread.current[:stop]
      Thread.stop if Thread.current[:stop]
      Win32::Sound.waveOutWrite(handle.id, header.pointer, header.size)
      while Win32::Sound.waveOutUnprepareHeader(handle.id, header.pointer, header.size) == 33
        sleep 0.001
      end
      Win32::Sound.waveOutClose(handle.id)
    end
  end

end
