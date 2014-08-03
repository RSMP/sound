
module Sound

  module Out
  
    def self.play_freq(frequency = 440, duration = 1000, volume = 1, pause_execution = false)
      if Platform.eql? "i386-mingw32"
        Win32::Sound.play_freq(frequency, duration, volume, pause_execution)
      else
        warn("play_freq not implemented for this platform: #{RUBY_PLATFORM}")
      end
    
    end
    
  end
  
end
