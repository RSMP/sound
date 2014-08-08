require 'sound'
include Sound
# Example of opening a device, writing to it, and closing it up
device = Device.new
device = Device.open(device, "w", Format::PCM)
file = File.open("bin/sounds.wav", "r")
device.write(file.to_s)
device.close

# This will close the device on its own after the block finishes
Device.open(Device::DEFAULT, "w", Format::PCM) do |device|
  puts "inside block"
  device.write("")
end

format = Format.new

Device.open(Device::DEFAULT, "w", format).write

#file = File.open
#file.write
#file.close

data = WaveData.new

device = Device.open
device.write(data)
device.close