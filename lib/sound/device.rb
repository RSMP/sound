
module Sound
  
  WAVE_FORMAT_PCM = 1
  WAVE_MAPPER = -1
  
  class Device
    
    def initialize(device_id)
      
    end
  
    DEFAULT = self.new(WAVE_MAPPER)
  
    class << self
      # Opens a sound device for reading or writing
      # device_id is an id of one of several devices, usually defined by a constant
      # direction is reading or writing or both
      # format_id is MIDI vs PCM or others
      # this method can take a block and if so closes the device after execution
      def open(device = Device.new(WAVE_MAPPER), direction = "w", format = Format.new(WAVE_FORMAT_PCM), &block)
        if block_given?
          block.call(device)
          device.close
        else
          device
        end
      end
    end
  
    def write(data)
      
    end
    
    def close
      
    end
  end

end
