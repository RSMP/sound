
require 'ffi'
require 'pry'
require 'os/os'

if OS.windows?
  require 'sound/win32/sound'
else
  warn("warning: Sound output not yet implemented for this platform: #{OS.os}")
end

require 'sound/data'
require 'sound/format'
require 'sound/device'
