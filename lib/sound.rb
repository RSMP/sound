
require 'ffi'
require 'pry'
require 'os/os'

if OS.windows?
  require 'sound/win32/sound'
elsif OS.linux?
  libasound_present = !(`which aplay`.eql? "")
  unless libasound_present
    warn("warning: sound output requires libasound2, libasound2-dev, and alsa-utils packages")
  end
  require 'sound/linux/sound'
else
  warn("warning: Sound output not yet implemented for this platform: #{OS.os}")
end

require 'sound/data'
require 'sound/format'
require 'sound/device'
