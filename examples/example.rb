require 'sound'
include Sound
# Example of opening a device, writing to it, and closing it up
device = Device.new
device = Device.open(device, "w", Format::PCM)
file = File.open("bin/sounds.wav", "r")
device.write(file.to_s)
device.close

# This will close the device on its own after the block finishes
Device.open(Device.new, "w", Format::PCM) do |device|
  puts "inside block"
  data = [*"a".."g"]
  data.each do |d|
    device.play(d)
  end
  device.write("h")
  device.write("i")
  device.write("j")
  device.write("k")
  device.write("l")
end

format = Format.new

Device.open(Device.new, "w", format).write

#file = File.open
#file.write
#file.close

data = WaveData.new

device = Device.open
device.write(data)
device.close