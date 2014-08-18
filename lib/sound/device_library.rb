require 'forwardable'

module Sound
  module DeviceLibrary
    extend Forwardable
    DEFAULT_DEVICE_ID = Sound.device_library::DEFAULT_DEVICE_ID
    duties = [
      :open_device,
      :prepare_buffer,
      :write_to_device,
      :unprepare_buffer,
      :close_device
    ]
    duties.each do |duty|
      delegate duty => Sound.device_library
      private duty
    end
  end
end
