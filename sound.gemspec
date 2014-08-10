
Gem::Specification.new do |spec|

  spec.name = 'sound'
  spec.version = '0.0.6'
  spec.date = '2014-08-10'
  spec.summary = 'cross-platform sound library wrapper'
  spec.description = 'Allows for effiecent cross-platform sound libraries in pure Ruby by tapping into native libraries.'
  spec.authors = ["Dominic Muller"]
  spec.email = 'nicklink483@gmail.com'
  spec.files = [
    "examples/example.rb",
    "lib/sound.rb",
    "lib/os/os.rb",
    "lib/sound/data.rb",
    "lib/sound/device.rb",
    "lib/sound/format.rb",
    "lib/sound/win32/sound.rb",
    "lib/sound/linux/sound.rb"
  ]
  spec.homepage = 'https://github.com/RSMP/sound'
  spec.license = 'MIT'
  
end
