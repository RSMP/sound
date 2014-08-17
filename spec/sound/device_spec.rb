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
  let(:data) {Sound::Data.new.sine_wave(440, 10, 0)}
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
    let(:device) {Sound::Device.new.write(data)}
    it "adds adds the data to the queue in its own thread" do
      expect(device.queue[0]).to be_kind_of Thread
    end
    it "does not play the data" do
      expect(device.queue[0]).to be_alive
    end
    context "when device is closed" do
      it "informs the user that they cannot write to a closed device" do
        default_device.close
        warning = "warning: cannot write to a closed device\n"
        expect{default_device.write(data)}.to output(warning).to_stderr
      end
    end
  end
  describe "#flush" do
    context "buffer is empty" do
      it "does nothing" do
        expect(default_device.flush).to be_nil
      end
    end
    context "buffer has one thing in it" do
      let(:device) {Sound::Device.new.write(data)}
      it "has an empty buffer" do
        device.flush
        expect(device.queue).to be_empty
      end
      context "when the platform is not supported" do
        it "informs the user that playback is not supported on their platform" do
          orig_support = Sound.platform_supported
          Sound.platform_supported = false
          warning = "warning: playback is not yet supported on this platform\n"
          expect{device.flush}.to output(warning).to_stderr
          Sound.platform_supported = orig_support
        end
      end
    end
    context "buffer has many things in it" do
      let(:device) {Sound::Device.new.write(data).write(data).write(data)}
      it "has an empty buffer" do
        device.flush
        expect(device.queue).to be_empty
      end
    end
  end
  describe "#play" do
    it "writes the data to the queue and immediately flushes it" do
      default_device.play data
      expect(default_device.queue).to be_empty
    end
  end
  describe "#close" do
    context "when a device is open" do
      it "returns the device closed" do
        expect(default_device.close).to be_closed
      end
    end
    context "when a device is closed" do
      it "informs the user that the device is already closed" do
        default_device.close
        warning = "warning: device is already closed"
        expect{default_device.close}.to output.to_stderr
      end
    end
  end
  describe "#write_async" do
    context "when queue is empty" do
      it "adds a new array of threads to the queue" do
        default_device.write_async data
        expect(default_device.queue.count).to eq 1
        expect(default_device.queue[0].class).to eq Array
      end
    end
    context "when queue contains a non-async member" do
      it "adds a new array of threads to the queue" do
        default_device.write data
        default_device.write_async data
        expect(default_device.queue.count).to eq 2
        expect(default_device.queue[0].class).to eq Thread
        expect(default_device.queue[1].class).to eq Array
      end
    end
    context "when last member of queue is async" do
      context "when current call is forced to be new" do
        it "adds a new array of threads to the queue" do
          default_device.write_async data
          default_device.write_async data, true
          expect(default_device.queue.count).to eq 2
          expect(default_device.queue[0].class).to eq Array
          expect(default_device.queue[1].class).to eq Array
        end
      end
      context "when current call is not new" do
        it "adds to the last member of a queue which should be an array" do
          default_device.write_async data
          default_device.write_async data
          expect(default_device.queue.count).to eq 1
          expect(default_device.queue[0].class).to eq Array
          expect(default_device.queue[0].count).to eq 2
        end
      end
    end
    context "when the device is closed" do
      it "informs the user that the device is closed" do
        default_device.close
        output = "warning: cannot write to a closed device\n"
        expect {default_device.write_async data}.to output(output).to_stderr
      end
    end
  end
end