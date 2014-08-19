require 'spec_helper'

describe Sound::DeviceLibrary do
  context "when included in a class" do
    class SomeDeviceClass; include Sound::DeviceLibrary; end
    describe "#open_device" do
      it "is a private method" do
        expect(SomeDeviceClass.new.private_methods).to include :open_device
      end
      it "is delegated to the loaded DeviceLibrary for the current Platform" #do
        #these aren't the same and I don't know how to test this.
        #expect(SomeDeviceClass.new.method(:open_device)).to eq Sound.device_library.method(:open_device)
      #end
    end
    describe "#prepare_buffer" do
      it "is a private method" do
        expect(SomeDeviceClass.new.private_methods).to include :prepare_buffer
      end
    end
    describe "#write_to_device" do
      it "is a private method" do
        expect(SomeDeviceClass.new.private_methods).to include :write_to_device
      end
    end
    describe "#unprepare_buffer" do
      it "is a private method" do
        expect(SomeDeviceClass.new.private_methods).to include :unprepare_buffer
      end
    end
    describe "#close_device" do
      it "is a private method" do
        expect(SomeDeviceClass.new.private_methods).to include :close_device
      end
    end
  end
end
