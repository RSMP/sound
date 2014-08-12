require 'spec_helper'

describe Sound::Device do
  context "when created without a block" do
    let(:device) {Sound::Device.new}
    it "is open" do
      expect(device).to be_open
    end
  end
  context "when created with a block" do
    let(:device) {Sound::Device.new {|d|}}
    it "is closed" do
      expect(device).to be_closed
    end
  end
end