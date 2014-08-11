require 'sound'

# this will alert you when various events occur
# such as when a device is opened or closed, when
# data is added to the queue, etc.
Sound.verbose = true

# Don't trust these examples.  The readme is more up to date.

# Example of opening a device, writing to it, and closing it up

# opens a device for writing
device = Sound::Device.new("w")

# creates a PCM format object
format = Sound::Format.new(Sound::Format::PCM)

# creates a new Sound Data object with a PCM format
data = Sound::Data.new(format)

# writes a sine wave to the data object with
# a frequency of 440 Hz, a duration of 500 ms
# and a volume of 1 (full volume)
data.generate_sine_wave(440, 500, 1)

# writes data to the message queue
device.write data

# flushes the message queue
device.flush

# responsibly closes the device
device.close

# with sensible defaults, you can ignore some of this

device = Sound::Device.new
data = Sound::Data.new
data.generate_sine_wave(440, 500, 1)
device.play data
device.close

# note the lack of specifying a format or explicitly writing the data
# to the message queue.  the #play method writes the data to the queue
# and flushes it automatically.

# with the block form, which uses #open instead of #new, it's even more
# cogent, since it will close the device for you

Sound::Device.new do |device|
  data = Sound::Data.new
  data.generate_sine_wave(440, 500, 1)
  device.play data
end