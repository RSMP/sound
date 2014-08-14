require 'sound'

# this will alert you when various events occur
# such as when a device is opened or closed, when
# data is added to the queue, etc.
Sound.verbose = true

Sound::Device.new.play_midi_notes