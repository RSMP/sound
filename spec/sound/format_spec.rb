require 'spec_helper'

describe Sound::Format do
  let(:format) {Sound::Format.new}
  it "has a type" do
    expect(format.type)
  end
  it "has a sample rate" do
    expect(format.sample_rate).to eq 44100
  end
  it "has a number of channels" do
    expect(format.channels).to eq 1
  end
  it "has some number of bits per sample" do
    expect(format.bps).to eq 16
  end
end
