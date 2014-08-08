
module Sound
  
  WAVE_FORMAT_PCM = 1
  WAVE_MAPPER = -1
  
  class Device
  
    attr_accessor :closed, :id
    
    def initialize(id = WAVE_MAPPER)
      @id = id
      closed = false
      @queue = []
    end
  
    DEFAULT = self.new
  
    class << self
      # Opens a sound device for reading or writing
      # device is one of several devices, usually defined by a constant
      # direction is reading or writing or both
      # format is MIDI vs PCM or others
      # this method can take a block and if so closes the device after execution
      def open(device = Device::DEFAULT, direction = "w", format = Format::PCM, &block)
        puts "opening device_#{device.id}"
        if block_given?
          block.call(device)
          device.close
        else
          device.closed = false
          device
        end
      end
    end
  
    def write(data = "beep boop")
      if closed?
        puts "cannot write to a closed device"
      else
        @queue.push(data)
        puts "writing to device_#{id}: #{@queue.shift}"
      end
    end
    
    def close
      if closed?
        puts "cannot close a closed device"
      else
        puts "device is closing now"
        closed = true
      end
    end
    
    def closed?
      closed
    end
  end

end
