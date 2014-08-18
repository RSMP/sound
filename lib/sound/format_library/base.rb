
module Sound
  module FormatLibrary
    module Base
      def new_format
      
      end
      def block_align
        (bps >> 3) * channels
      end
      def avg_bps
        block_align * sample_rate
      end
    end
  end
end
