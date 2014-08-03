
module Sound

  module Out
  
    def self.play_freq(frequency = 440, duration = 1000, volume = 1, pause_execution = false)
      Win32::Sound.play_freq(frequency, duration, volume, pause_execution)
    
    end
    
  end
  
end
