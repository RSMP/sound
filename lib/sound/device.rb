
module Sound

  @verbose = false
  @no_device = false
  
  class << self
    attr_accessor :verbose, :no_device
  end
  
  WAVE_MAPPER = -1
  
  class NoDeviceError < SystemCallError; end
  class NoDependencyError < RuntimeError; end
  
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
    
    class Buffer < Array; end
  
    attr_accessor :closed, :id, :handle, :format
    
    def initialize(direction = "w", id = nil, &block)
      if OS.windows?
        id ||= WAVE_MAPPER
      elsif OS.linux?
        id ||= "default"
      end
      
      @id = id
      @closed = false
      @queue = Device::Buffer.new
      @mutex = Mutex.new
      @direction = direction
      
      puts "opening device: '#{id}'" if Sound.verbose
      
      if block_given?
        block.call(self)
        close
      end
      
    end
    
    def open?
      !closed
    end
    
    def queue
      @queue.dup.freeze
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
          Thread.current[:async] = false
          Thread.current[:data] = data
          write_thread
        end
        @mutex.unlock
        puts "writing to queue of device '#{id}': #{data}" if Sound.verbose
      end
      self
    end
    
    def write_async(data = "beep boop", new_queue_elem = false)
      if closed?
        puts "cannot write to a closed device"
      else
        @mutex.lock
        if new_queue_elem || @queue.empty? || @queue.last.kind_of?(Thread)
          threads = []
          threads << Thread.new do
            Thread.current[:async] = true
            Thread.current[:data] = data
            write_thread
            Thread.pass
          end
          @queue << threads
        else
          @queue.last << Thread.new do
            Thread.current[:data] = data
            write_thread
            Thread.pass
          end
        end
        @mutex.unlock
        puts "writing async to queue of device '#{id}': #{data}" if Sound.verbose
      end
    end
    
    def close
      if closed?
        puts "cannot close a closed device"
      else
        flush
        puts "device '#{id}' is closing now" if Sound.verbose
        self.closed = true
      end
    end
    
    def flush
      until @queue.empty?
        output = @queue.shift
        if output.kind_of? Thread
          output[:stop] = false
          puts "writing to device '#{id}': #{output[:data].class}" if Sound.verbose
          output.run.join
        else
          output.each do |thread|
            thread[:stop] = false
            puts "writing to device '#{id}': #{thread[:data].class}" if Sound.verbose
            thread.run
          end
          output.last.join if output.last.alive?
        end
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
        unless Sound.no_device
          prepare_buffer
        end
        Thread.stop if Thread.current[:stop]
        unless Sound.no_device
          write_to_device
          close_device
        end
      else
        warn("warning: playback is not yet supported on this platform")
      end
    end
    
    def open_device
      if OS.windows?
        Win32::Sound.waveOutOpen(handle.pointer, id, data.format.pointer, 0, 0, 0)
      elsif OS.linux?
        begin
          ALSA::PCM.open(handle.pointer, id, 0, ALSA::PCM::ASYNC)
        rescue NoDeviceError
          Sound.no_device = true
        end
      end
    end
    
    def prepare_buffer
      if OS.windows?
        Win32::Sound.waveOutPrepareHeader(handle.id, header.pointer, header.size)
      elsif OS.linux?
      
        buffer_length
        
        ALSA::PCM.params_malloc(params_handle.pointer)
        ALSA::PCM.params_any(handle.id, params_handle.id)
        
        ALSA::PCM.set_access(handle.id, params_handle.id, ALSA::PCM::SND_PCM_ACCESS_RW_INTERLEAVED)
        ALSA::PCM.set_format(handle.id, params_handle.id, ALSA::PCM::SND_PCM_FORMAT_S16_LE)
        ALSA::PCM.set_rate(handle.id, params_handle.id, data.format.sample_rate, 0)
        ALSA::PCM.set_channels(handle.id, params_handle.id, 1)
        
        ALSA::PCM.save_params(handle.id, params_handle.id)
        ALSA::PCM.free_params(params_handle.id)
        
        ALSA::PCM.prepare(handle.id)
        
      end
    end
    
    def write_to_device
      if OS.windows?
        Win32::Sound.waveOutWrite(handle.id, header.pointer, header.size)
      elsif OS.linux?
        ALSA::PCM.write_interleaved(handle.id, data_buffer, buffer_length)
      end
    end
    
    def close_device
      wait_for_sounds_to_finish
      if OS.windows?
        Win32::Sound.waveOutClose(handle.id)
      elsif OS.linux?
        ALSA::PCM.close(handle.id)
      end
    end
    
    def handle
      Thread.current[:handle] ||= Handle.new
    end
    
    def params_handle
      Thread.current[:params_handle] ||= Handle.new
    end
    
    def data
      Thread.current[:data]
    end
    
    def header
      Thread.current[:header] ||= Win32::WAVEHDR.new(data_buffer, buffer_length)
    end
    
    def data_buffer
      Thread.current[:data_buffer] ||= FFI::MemoryPointer.new(:int, data.pcm_data.size).write_array_of_int data.pcm_data
    end
    
    def buffer_length
      if OS.windows?
        Thread.current[:buffer_length] ||= data.format.avg_bps*data.duration/1000
      elsif OS.linux?
        Thread.current[:buffer_length] ||= data_buffer.size/2
      end
    end
    
    def wait_for_sounds_to_finish
      if OS.windows?
        while Win32::Sound.waveOutUnprepareHeader(handle.id, header.pointer, header.size) == 33
          sleep 0.001
        end
      elsif OS.linux?
        ALSA::PCM.drain(handle.id)
      end
    end
  end

end
