sound
=====
[![Gem Version](https://badge.fury.io/rb/sound.svg)](http://badge.fury.io/rb/sound)
[![Build Status](https://travis-ci.org/RSMP/sound.svg?branch=master)](https://travis-ci.org/RSMP/sound)
[![Coverage Status](https://coveralls.io/repos/RSMP/sound/badge.png)](https://coveralls.io/r/RSMP/sound)
[![Dependency Status](https://gemnasium.com/RSMP/sound.svg)](https://gemnasium.com/RSMP/sound)
[![Code Climate](https://codeclimate.com/github/RSMP/sound/badges/gpa.svg)](https://codeclimate.com/github/RSMP/sound)

**This Gem is still in alpha! Breaking and changes are expected everywhere!**

Cross Platform sound libraries for the Ruby developer

    gem install sound

And then in irb or some script:

    require 'sound'
    device = Sound::Device.new
    format = Sound::Format.new
    data = Sound::Data.new(format)
    data.generate_sine_wave(440, 500, 1)
    device.write data
    device.close
    
This will work on both windows and linux.

With some sensible defaults, the previous example can be written in one line:

    Sound::Device.new {|d| d.write Sound::Data.new.sine_wave(440, 500, 1)}

More can be seen in examples/example.rb

The three main parts of this gem are Sound::Device, Sound::Format, Sound::Data.
That way more platforms can be added easily by interacting with DeviceLibrary.
Obviously the only Data object that can be made is a sine wave (albeit two
different ways), but that will grow into more data types like midi sequences and
data pulled from audio files.  As for Format, well that will just be PCM or MIDI
for now, but that may evolve too.

Come back for more features in the future including more data types (loading
from files, other wave types), more platforms (MacOS is next on the list) and
new formats (midi).
