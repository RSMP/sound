require 'sound'
Sound.verbose = true

# Don't trust these examples.  The readme is more up to date.

# Example of opening a device, writing to it, and closing it up

device = Sound::Device.new
data = Sound::Data.new(device.format)
data.generate_sine_wave(440, 500, 1)
device.write data
device.close

# This will close the device on its own after the block finishes


#data = WaveData.new
#
#device = Device.open
#device.write(data)
#device.close
