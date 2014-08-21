
Gem::Specification.new do |spec|

  spec.name = 'sound'
  spec.version = '0.1.0'
  spec.date = '2014-08-21'
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
    "lib/sound/device_library.rb",
    "lib/sound/format.rb",
    "lib/sound/format_library.rb",
    "lib/sound/device_library/alsa.rb",
    "lib/sound/device_library/base.rb",
    "lib/sound/device_library/mmlib.rb",
    "lib/sound/format_library/alsa.rb",
    "lib/sound/format_library/base.rb",
    "lib/sound/format_library/mmlib.rb"
  ]
  spec.add_runtime_dependency 'ffi', '= 1.3.1'
  spec.add_development_dependency 'rspec', '~> 3.0', '>=3.0.0'
  
  spec.homepage = 'https://github.com/RSMP/sound'
  spec.license = 'MIT'
  
end
