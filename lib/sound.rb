require_relative 'os/os'

if OS.windows?
  require 'win32/sound'
else
  warn("Sound output not yet implemented for this platform: #{OS.os}")
end

require_relative 'sound/sound'
require_relative 'sound/out'
