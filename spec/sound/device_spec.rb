require 'spec_helper'
#Device
#  Abstracts physical devices
#  it can be opened
#  it can be closed
#  it can be written to
#    in that you write to its buffer
#  it can be flushed
#    in that its buffer is flushed
#  it can be played
#    in that its buffer is written to and immediately flushed
#  you can write any Data to it
#  it has a identification
describe Sound::Device do
  let(:default_device) {Sound::Device.new}
  it "has an id" do
    expect(default_device.id)
    if OS.linux?
      expect(default_device.id).to eq "default"
    end
  end
  describe "#new" do
    context "when created without a block" do
      it "is open" do
        expect(default_device).to be_open
      end
    end
    context "when created with a block" do
      let(:device) {Sound::Device.new {|d|}}
      it "is closed" do
        expect(device).to be_closed
      end
    end
  end
  describe "self.open" do
    let(:default_device) {Sound::Device.open}
    context "when created without a block" do
      it "is open" do
        expect(default_device).to be_open
      end
    end
    context "when created with a block" do
      let(:device) {Sound::Device.open {|d|}}
      it "is closed" do
        expect(device).to be_closed
      end
    end
  end
  describe "#open" do
    it "should return an open device" do
      default_device.open
      expect(default_device).to be_open
      default_device.close
      default_device.open
      expect(default_device).to be_open
    end
  end
  describe "@queue" do
    it "can be read" do
      expect(default_device.queue)
      expect(default_device.queue.length).to eq 0
    end
    it "cannot be written to directly" do
      expect{device.queue << Thread.new {} }.to raise_error
    end
  end
  describe "#write" do
    let(:device) {Sound::Device.new.write(Sound::Data.new.sine_wave(440, 10, 0))}
    it "adds adds the data to the queue in its own thread" do
      expect(device.queue[0]).to be_kind_of Thread
    end
    it "does not play the data" do
      expect(device.queue[0]).to be_alive
    end
    context "when device is closed" do
      it "informs the user that they cannot write to a closed device"
    end
  end
  describe "#flush" do
    context "buffer is empty" do
      it "does nothing" do
        expect(default_device.flush).to be_nil
      end
    end
    context "buffer has one thing in it" do
      let(:device) {Sound::Device.new.write(Sound::Data.new.sine_wave(440, 10, 0))}
      it "has an empty buffer" do
        device.flush
        expect(device.queue).to be_empty
      end
    end
    context "buffer has many things in it" do
      let(:data) {Sound::Data.new.sine_wave(440, 10, 0)}
      let(:device) {Sound::Device.new.write(data).write(data).write(data)}
      it "has an empty buffer" do
        device.flush
        expect(device.queue).to be_empty
      end
    end
  end
end