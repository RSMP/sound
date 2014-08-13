
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
  
  class NoDeviceError < RuntimeError; end
  class NoDependencyError < RuntimeError; end
  
end

if OS.windows?
  require 'sound/device_interface/win32'
  require 'sound/format_interface/win32'
  module Sound
    class Device
      include DeviceInterface::Win32
    end
    class Format
      include FormatInterface::Win32
    end
  end
  Sound.platform_supported = true
elsif OS.linux?
  libasound_present = !(`which aplay`.eql? "")
  unless libasound_present
    warn("warning: sound output requires libasound2, libasound2-dev, and alsa-utils packages")
  end
  require 'sound/device_interface/alsa'
  require 'sound/format_interface/alsa'
  module Sound
    class Device
      include DeviceInterface::ALSA
    end
  end
  Sound.platform_supported = true
else
  warn("warning: Sound output not yet implemented for this platform: #{OS.os}")
end

require 'sound/device'
require 'sound/data'
require 'sound/format'
