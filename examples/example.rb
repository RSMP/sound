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
format = Sound::Format.new#(Sound::Format::PCM)

# creates a new Sound Data object with a PCM format
data = Sound::Data.new(format)

# writes a sine wave to the data object with
# a frequency of 440 Hz, a duration of 500 ms
# and a volume of 1 (full volume)
data.generate_sine_wave(880, 500, 1)

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

Sound::Device.new {|d| d.play Sound::Data.new.sine_wave(440, 500, 1)}

# Let's play a little melody!  It starts to get out of sync about halfway through

threads = []

threads << Thread.new do
  Sound::Device.new do |device|
    device.write Sound::Data.new.sine_wave(440, 1200, 0.4)
    device.write Sound::Data.new.sine_wave(440*2**(4/12.0), 600, 0.4)
    device.write Sound::Data.new.sine_wave(440*2**(7/12.0), 600, 0.4)
    device.write Sound::Data.new.sine_wave(440*2**(-1/12.0), 900, 0.4)
    device.write Sound::Data.new.sine_wave(440*2**(0/12.0), 150, 0.4)
    device.write Sound::Data.new.sine_wave(440*2**(2/12.0), 150, 0.4)
    device.write Sound::Data.new.sine_wave(440*2**(0/12.0), 1200, 0.4)
    device.write Sound::Data.new.sine_wave(440*2**(9/12.0), 1200, 0.4)
    device.write Sound::Data.new.sine_wave(440*2**(7/12.0), 600, 0.4)
    device.write Sound::Data.new.sine_wave(440*2**(12/12.0), 600, 0.4)
    device.write Sound::Data.new.sine_wave(440*2**(7/12.0), 600, 0.4)
    device.write Sound::Data.new.sine_wave(440*2**(5/12.0), 70, 0.4)
    device.write Sound::Data.new.sine_wave(440*2**(7/12.0), 70, 0.4)
    device.write Sound::Data.new.sine_wave(440*2**(5/12.0), 70, 0.4)
    device.write Sound::Data.new.sine_wave(440*2**(7/12.0), 70, 0.4)
    device.write Sound::Data.new.sine_wave(440*2**(5/12.0), 170, 0.4)
    device.write Sound::Data.new.sine_wave(440*2**(4/12.0), 150, 0.4)
    device.write Sound::Data.new.sine_wave(440*2**(4/12.0), 1200, 0.4)
    Thread.pass
    Thread.pass
  end
end

threads << Thread.new do
  Sound::Device.new do |device|
    device.write Sound::Data.new.sine_wave(220*2**(0/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(7/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(4/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(7/12.0), 300, 0.4)
    
    device.write Sound::Data.new.sine_wave(220*2**(0/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(7/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(4/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(7/12.0), 300, 0.4)
    
    device.write Sound::Data.new.sine_wave(220*2**(-1/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(7/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(5/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(7/12.0), 300, 0.4)
    
    device.write Sound::Data.new.sine_wave(220*2**(0/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(7/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(4/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(7/12.0), 300, 0.4)
    
    device.write Sound::Data.new.sine_wave(220*2**(0/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(9/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(5/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(9/12.0), 300, 0.4)
    
    device.write Sound::Data.new.sine_wave(220*2**(0/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(7/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(4/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(7/12.0), 300, 0.4)
    
    device.write Sound::Data.new.sine_wave(220*2**(-1/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(7/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(5/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(7/12.0), 300, 0.4)
    
    device.write Sound::Data.new.sine_wave(220*2**(0/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(7/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(4/12.0), 300, 0.4)
    device.write Sound::Data.new.sine_wave(220*2**(7/12.0), 300, 0.4)
    Thread.pass
  end
end

threads.each {|t| t.join}
#example of asynchronous playback

Sound::Device.new do |device|
  device.write_async Sound::Data.new.sine_wave(440, 300, 1)
  device.write_async Sound::Data.new.sine_wave(660, 300, 1)
  device.write Sound::Data.new.sine_wave(660, 300, 1)
  device.write_async Sound::Data.new.sine_wave(440, 300, 1), true
  device.write_async Sound::Data.new.sine_wave(880, 300, 1)
  device.write_async Sound::Data.new.sine_wave(440, 300, 1), true
  device.write_async Sound::Data.new.sine_wave(880*2**(4/12.0), 300, 1)
  
end

threads = []

threads << Thread.new do
  Sound::Device.new do |device|
    device.write Sound::Data.new.sine_wave(440, 500, 1)
    Thread.pass
  end
end
threads << Thread.new do
  Sound::Device.new do |device|
    device.write Sound::Data.new.sine_wave(660, 500, 1)
    Thread.pass
  end
end

threads.each {|t| t.join}