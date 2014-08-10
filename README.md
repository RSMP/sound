sound
=====

Cross Platform sound libraries for the Ruby developer

    gem install sound

And then in irb or some script:

    require 'sound'
    device = Sound::Device.new
    data = Sound::Data.new(device.format)
    data.generate_sine_wave(440, 500, 1)
    device.write data
    device.close
    
This will work on both windows and linux.  However Linux platforms will need
to install the libasound and libasound-dev packages.  You may already have
these installed.

Come back for more features in the future including more data
types (loading from files, other wave types), and new formats (midi).
