module OS

  class UnknownOSError < StandardError; end

  class << self
    attr_accessor :os
  end

  def OS.windows?
    os == :windows
  end

  def OS.mac?
    os == :mac
  end

  def OS.unix?
    os == :unix
  end

  def OS.linux?
    os == :linux
  end
  
  def OS.os
    @os ||= OS.host_os
  end
  
  def OS.host_os
    case RbConfig::CONFIG['host_os']
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc|emx/
      :windows
    when /darwin|mac os/
      :mac
    when /linux/
      :linux
    when /solaris|bsd/
      :unix
    else
      raise UnknownOSError, "unknown os: #{RbConfig::CONFIG['host_os'].inspect}"
    end
  end

end
