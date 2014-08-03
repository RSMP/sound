
module Sound

  module Out
  
    def self.play_freq(frequency = 440, duration = 1000, volume = 1, immediate_playback = true)
      if OS.windows?
        Win32::Sound.play_freq(frequency, duration, volume, immediate_playback)
      else
        warn("play_freq not implemented for this platform: #{RUBY_PLATFORM}")
      end
    
    end
    
  end
  
end
