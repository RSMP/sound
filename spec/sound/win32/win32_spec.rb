require 'spec_helper'

if OS.windows?
  describe Sound::DeviceInterface::Win32 do
    it "implements DeviceInterface::Base"
  end
end