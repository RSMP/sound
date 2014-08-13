require 'spec_helper'

describe Sound::Data do

  context "a new data object" do
    let(:data) {Sound::Data.new}
    it "has a format" do
      expect(data.format)
    end
    it "can have a sine wave written to it" do
      expect{data.generate_sine_wave(440, 10, 0) }.not_to raise_error
      expect{data.sine_wave(440, 10, 0) }.not_to raise_error
    end
  end
  context "when a sine wave is generated" do
    let(:data) {Sound::Data.new.generate_sine_wave(440, 500, 1)}
    it "has a freq of 440"
    it "has a duration of 500 milliseconds"
    it "has a volume of 1 (full volume"
  end
  
end
