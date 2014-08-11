
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
    
    def initialize(direction = "w", id = nil, &block)
      
      if OS.windows?
        id ||= WAVE_MAPPER
      elsif OS.linux?
        id ||= "default"
      end
      
      @id = id
      @closed = false
      @queue = []
      @mutex = Mutex.new
      @direction = direction
      
      puts "opening device: '#{id}'" if Sound.verbose
      
      if block_given?
        block.call(self)
        close
      end
      
    end
  
    class << self
      # Opens a sound device for reading or writing
      # device is one of several devices, usually defined by a constant
      # direction is reading or writing or both
      # format is MIDI vs PCM or others
      # this method can take a block and if so closes the device after execution
      def open(device = Device.new, direction = "w", &block)
        puts "opening device: '#{device.id}'" if Sound.verbose
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
          Thread.current[:data] = data
          write_thread
        end
        @mutex.unlock
        puts "writing to queue of device '#{id}': #{data.class}" if Sound.verbose
      end
    end
    
    def close
      if closed?
        puts "cannot close a closed device"
      else
        flush
        puts "device '#{id}' is closing now" if Sound.verbose
        closed = true
      end
    end
    
    def flush
      until @queue.empty?
        output = @queue.shift
        output[:stop] = false
        puts "writing to device '#{id}': #{output[:data].class}" if Sound.verbose
        output.run.join
      end
    end
    
    def closed?
      closed
    end
    
    private
    
    def write_thread
      Thread.current[:stop] = true if Thread.current[:stop].nil?
      if OS.windows? || OS.linux?
        open_device
        prepare_buffer
        Thread.stop if Thread.current[:stop]
        write_to_device
        close_device
      else
        warn("warning: playback is not yet supported on this platform")
      end
    end
    
    def data_buffer
      Thread.current[:data_buffer] ||= FFI::MemoryPointer.new(:int, data.pcm_data.size).write_array_of_int data.pcm_data
    end
    
    def buffer_length
      Thread.current[:buffer_length] ||= data.format.avg_bps*data.duration/1000
    end
    
    def handle
      Thread.current[:handle] ||= Handle.new
    end
    
    def data
      Thread.current[:data]
    end
    
    def header
      Thread.current[:header] ||= Win32::WAVEHDR.new(data_buffer, buffer_length)
    end
    
    def open_device
      if OS.windows?
        Win32::Sound.waveOutOpen(handle.pointer, id, data.format.pointer, 0, 0, 0)
      elsif OS.linux?
        ALSA::PCM.open(handle.pointer, id, 0, 0)
      end
    end
    
    def prepare_buffer
      if OS.windows?
        Win32::Sound.waveOutPrepareHeader(handle.id, header.pointer, header.size)
      elsif OS.linux?
      
        buffer_size = data_buffer.size/2
        
        params = FFI::MemoryPointer.new(:pointer)
        
        ALSA::PCM.params_malloc(params)
        ALSA::PCM.params_any(handle.id, params.read_pointer)
        
        ALSA::PCM.set_access(handle.id, params.read_pointer, ALSA::PCM::SND_PCM_ACCESS_RW_INTERLEAVED)
        ALSA::PCM.set_format(handle.id, params.read_pointer, ALSA::PCM::SND_PCM_FORMAT_S16_LE)
        ALSA::PCM.set_rate(handle.id, params.read_pointer, data.format.sample_rate, 0)
        ALSA::PCM.set_channels(handle.id, params.read_pointer, 1)
        
        ALSA::PCM.save_params(handle.id, params.read_pointer)
        ALSA::PCM.free_params(params.read_pointer)
        
        ALSA::PCM.prepare(handle.id)
        
      end
    end
    
    def write_to_device
      if OS.windows?
        Win32::Sound.waveOutWrite(handle.id, header.pointer, header.size)
      elsif OS.linux?
        ALSA::PCM.write_interleaved(handle.id, data_buffer, buffer_size)
      end
    end
    
    def close_device
      if OS.windows?
        while Win32::Sound.waveOutUnprepareHeader(handle.id, header.pointer, header.size) == 33
          sleep 0.001
        end
        Win32::Sound.waveOutClose(handle.id)
      elsif OS.linux?
        ALSA::PCM.drain(handle.id)
        ALSA::PCM.close(handle.id)
      end
    end
  end

end
