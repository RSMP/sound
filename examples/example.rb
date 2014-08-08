require 'sound'
include Sound
# Example of opening a device, writing to it, and closing it up
device = Device.open(Device::DEFAULT, "w", Format::PCM)
file = File.open("bin/sounds.wav", "r")
device.write(file)
device.close

# This will close the device on its own after the block finishes
Device.open(Device::DEFAULT, "w", Format::PCM) do |device|
  device.write(File.open("bin/sounds.wav", "r"))
end

format = Format.new

Device.open(Device::DEFAULT, "w", format)

#file = File.open
#file.write
#file.close

data = ""

device = Device.open
device.write(data)
device.close