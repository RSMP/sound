
Gem::Specification.new do |spec|

  spec.name = 'sound'
  spec.version = '0.0.4'
  spec.date = '2014-08-03'
  spec.summary = 'cross-platform sound library wrapper'
  spec.description = 'Allows for effiecent cross-platform sound libraries in pure Ruby by tapping into native libraries.'
  spec.authors = ["Dominic Muller"]
  spec.email = 'nicklink483@gmail.com'
  spec.files = [
    "lib/sound.rb",
    "lib/sound/out.rb",
    "lib/sound/sound.rb",
    "lib/os/os.rb"
  ]
  #spec.add_runtime_dependency 'win32-sound', ['>= 0.6.0']
  spec.requirements << "win32-sound, '>= 0.6.0' on Windows"
  spec.homepage = 'https://github.com/RSMP/sound'
  spec.license = 'MIT'
  #spec.extensions << 'ext/mkrf_conf.rb'
  
end
