require 'pry'
require 'os/os'

module Sound

  @verbose = false
  @no_device = false
  @platform_supported = true
  
  class << self
    attr_accessor :verbose, :no_device, :platform_supported, :device_library, :format_library
  end
  
  class NoDeviceError < RuntimeError; end
  class NoDependencyError < RuntimeError; end
  
end

if OS.windows?
  require 'sound/device_library/mmlib'
  require 'sound/format_library/mmlib'
  Sound.device_library = Sound::DeviceLibrary::MMLib
  Sound.format_library = Sound::FormatLibrary::MMLib
elsif OS.linux?
  libasound_present = !(`which aplay`.eql? "")
  if libasound_present
    require 'sound/device_library/alsa'
    require 'sound/format_library/alsa'
    Sound.device_library = Sound::DeviceLibrary::ALSA
    Sound.format_library = Sound::FormatLibrary::ALSA
  else
    warn("warning: sound output requires libasound2, libasound2-dev, and alsa-utils packages")
  end
else
  Sound.device_library = Sound::DeviceLibrary::Base
  Sound.format_library = Sound::FormatLibrary::Base
  warn("warning: Sound output not yet implemented for this platform: #{OS.os}")
  Sound.platform_supported = false
end

require 'sound/device_library'
require 'sound/format_library'
require 'sound/device'
require 'sound/data'
require 'sound/format'
