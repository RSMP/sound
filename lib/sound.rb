
require 'ffi'
require 'pry'
require 'os/os'

module Sound

  @verbose = false
  @no_device = false
  @platform_supported = false
  
  class << self
    attr_accessor :verbose, :no_device, :platform_supported
  end
  
  WAVE_MAPPER = -1
  
  class NoDeviceError < RuntimeError; end
  class NoDependencyError < RuntimeError; end
  
end

if OS.windows?
  require 'sound/win32'
  module Sound
    class Device
      include Win32
    end
  end
  Sound.platform_supported = true
elsif OS.linux?
  libasound_present = !(`which aplay`.eql? "")
  unless libasound_present
    warn("warning: sound output requires libasound2, libasound2-dev, and alsa-utils packages")
  end
  require 'sound/alsa'
  module Sound
    class Device
      include ALSA
    end
  end
  Sound.platform_supported = true
else
  warn("warning: Sound output not yet implemented for this platform: #{OS.os}")
end

require 'sound/device'
require 'sound/data'
require 'sound/format'
