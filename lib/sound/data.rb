
module Sound

  class Data
    attr_reader :data, :duration
    def initialize(format)
      @format = format
      @data = []
    end
    def generate_sine_wave(freq, duration, volume)
      @data = []
      @duration = duration
      ramp = 200.0
      samples = (@format.sample_rate/2*duration/1000.0).floor

      samples.times do |sample|

        angle = (2.0*Math::PI*freq) * sample/samples * duration/1000
        factor = Math.sin(angle)
        x = 32768.0*factor*volume

        if sample < ramp
          x *= sample/ramp
        end
        if samples - sample < ramp
          x *= (samples - sample)/ramp
        end

        @data << x.floor
      end

      self
    end
  end
  
end