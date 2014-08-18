
module Sound
  
  class Device
    include DeviceLibrary
    
    class Buffer < Array
      attr_accessor :force
      def new_block
        self.force || self.empty? || self.last.kind_of?(Thread)
      end
    end
  
    attr_reader :status, :id
    
    # creates a new device for writing by default.  default id is set by
    # whatever device interface was included (Win32 or ALSA, e.g.)
    # if a block is passed, it executes the code in the block, passing
    # the newly created device, and then closes the device.
    #
    def initialize(direction = "w", id = DeviceLibrary::DEFAULT_DEVICE_ID, &block)
      
      @id = id
      @status = :open
      @queue = Device::Buffer.new
      @mutex = Mutex.new
      @direction = direction
      
      puts "opening device: '#{id}'" if Sound.verbose
      
      if block_given?
        block.call(self)
        close
      end
      
    end
    
    # checks if the current status of the device is :open
    #
    def open?
      status == :open
    end
    
    # checks if the current status of the device is :closed
    #
    def closed?
      status == :closed
    end
    
    # returns the current queue.  should be used for debugging only.
    #
    def queue
      @queue.dup.freeze
    end
  
    class << self
      # Opens a sound device for reading or writing
      # device is one of several devices, usually defined by a constant
      # direction is reading or writing or both
      # format is MIDI vs PCM or others
      # this method can take a block and if so closes the device after execution
      #
      def open(device = Device.new, direction = "w", &block)
        puts "opening device: '#{device.id}'" if Sound.verbose
        if block_given?
          block.call(device)
          device.close
        else
          device.open
          device
        end
      end
    end
    
    # opens the device.
    #
    def open
      @status = :open
      self
    end
    
    # writes data to the queue and immediately flushes the queue.
    #
    def play(data = Sound::Data.new)
      write(data)
      flush
    end
    
    # writes given Data to the queue as a data block thread.  Threads pause
    # after preperation, and during flushing they get started back up. If a
    # thread isn't done preparing when flushed, it finished preparing and
    # immediately writes data to the device.
    #
    def write(data = Sound::Data.new)
      if closed?
        warn("warning: cannot write to a closed device")
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
    
    # starts up data block threads that get played back at the same time.  Need
    # to make all threads wait until others are finished preparing the buffer.
    #
    def write_async(data = Sound::Data.new, force_new = false)
      if closed?
        warn("warning: cannot write to a closed device")
      else
        @mutex.lock
        @queue.force = force_new
        if @queue.new_block
          @queue << [new_async_thread_for(data)]
        else
          @queue.last << new_async_thread_for(data)
        end
        @mutex.unlock
        puts "writing async to queue of device '#{id}': #{data}" if Sound.verbose
      end
      self
    end
    
    # flushes any pending queue data blocks, waits for them to finish playing,
    # and then closes the device.
    #
    def close
      if closed?
        warn("warning: device is already closed")
      else
        flush
        puts "device '#{id}' is closing now" if Sound.verbose
        @status = :closed
      end
      self
    end
    
    # closes the device as quickly as possible without flushing the
    # data buffer.
    #
    def close!
      if closed?
        warn("warning: device is already closed")
      else
        flush!
        puts "device '#{id}' is closing immediately now" if Sound.verbose
        @status = :closed
      end
      self
    end
    
    # flushes each block after previous finishes.  Should make other options,
    # like flush each block after a specified amount of time.
    #
    def flush
      until @queue.empty?
        output = @queue.shift
        if output.kind_of? Thread
          finish_up(output).join
        else
          output.each do |thread|
            finish_up(thread)
          end
          output.last.join if output.last.alive?
        end
      end
    end
    
    # works like #flush, but empties the buffer without playing any sounds and
    # closes the physical device as quickly as possible for its platform.
    #
    def flush!
      @queue = Device::Buffer.new
    end
    
    private
    
    def write_thread
      Thread.current[:stop] = true if Thread.current[:stop].nil?
      if Sound.platform_supported
        set_up
        write_to_device
        tear_down
      else
        warn("warning: playback is not yet supported on this platform")
      end
    end
    
    def set_up
      open_device(id)
      prepare_buffer
      Thread.stop if Thread.current[:stop]
      Thread.pass if Thread.current[:async]
    end
    
    def tear_down
      unprepare_buffer
      close_device
    end
    
    def new_async_thread_for(data)
      Thread.new do
        Thread.current[:async] = true
        Thread.current[:data] = data
        write_thread
      end
    end
    
    def finish_up(thread)
      thread[:stop] = false
      puts "writing to device '#{id}': #{thread[:data].class}" if Sound.verbose #this may be NilClass if parent thread is too fast
      thread.run
    end
  end

end
