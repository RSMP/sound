require 'sound/device_interface'

module Sound
  module DeviceInterface
    module Base
      def Base.please_implement
        raise NoMethodError, "Please implement ##{method} for your DeviceInterface."
      end
      class Handle
        def pointer
          raise NoMethodError, "Please implement #{self.class}##{__method__} for your DeviceInterface"
        end
        def id
          raise NoMethodError, "Please implement #{self.class}##{__method__} for your DeviceInterface"
        end
      end
      private
      def open_device
        Base.please_implement(__method__)
      end
      def prepare_buffer
        Base.please_implement(__method__)
      end
      def write_to_device
        Base.please_implement(__method__)
      end
      def unprepare_buffer
        Base.please_implement(__method__)
      end
      def close_device
        Base.please_implement(__method__)
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
    end
  end
end
