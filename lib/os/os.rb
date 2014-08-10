module OS

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
    @os ||= (
      host_os = RbConfig::CONFIG['host_os']
      case host_os
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc|emx/
        :windows
      when /darwin|mac os/
        :mac
      when /linux/
        :linux
      when /solaris|bsd/
        :unix
      else
        raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
      end
    )
  end

end
