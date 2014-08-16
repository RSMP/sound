require 'pry'
file = File.open("alsa_library_calls.txt", "r") {|f| f.read }
lines = file.lines.to_a
Parameter = Struct.new(:type, :name)
class LibraryCall
  attr_accessor :comment
  attr_reader :name, :parameters, :return_type
  def initialize(str)
    m = str.match(/^(?<return_type>.+?) +?\t(?<name>\S+) \((?<parameters>.+)\)/)
    @return_type = m[:return_type]
    @name = m[:name]
    @raw_parameters = m[:parameters]
    @parameters = []
    @raw_parameters.split(",").each do |parameter|
      m = parameter.match(/(?<type>^.+(\*| ))(?<name>\w+$)/)
      if m
        if m[:type][0].eql?(" ")
          @parameters << Parameter.new(m[:type][1..-1].chomp(" "), m[:name])
        else
          @parameters << Parameter.new(m[:type].chomp(" "), m[:name])
        end
      else
        @parameters << Parameter.new("void", "")
      end
    end
    @comment = ""
    #binding.pry
  end
end
function = ""
functions = []
lines.each do |line|
  case line
  when /^ \t/
    function.comment = line[2..-1].chomp
  when /^#/
  else
    function = LibraryCall.new(line)
    functions << function
  end
end
output = ""
$params = []
def lookup(param, function)
  case param
  when /\*\*/
    :pointer
  when "const char *"
    :string
  when "snd_pcm_t *"
    :pointer
  when "snd_async_handler_t *"
    :pointer
  when "snd_pcm_sframes_t"
    :long
  when "snd_pcm_sframes_t *"
    :long
  when "int"
    :int
  when "snd_pcm_uframes_t"
    :ulong
  when "snd_pcm_uframes_t *"
    :ulong
  when "snd_htimestamp_t *"
    :pointer
  when "snd_pcm_hw_params_t *"
    :pointer
  when "snd_pcm_info_t *"
    :pointer
  when "snd_pcm_stream_t"
    :int
  when "snd_config_t *"
    :pointer
  when "struct pollfd *"
    :pointer
  when "unsigned int"
    :uint
  when "unsigned short *"
    :ushort
  when "void *"
    :pointer
  when "snd_pcm_format_t"
    :pointer
  when "snd_pcm_access_t"
    :pointer
  when "snd_pcm_state_t"
    :pointer
  when "snd_pcm_status_t *"
    :pointer
  when "snd_pcm_sw_params_t *"
    :pointer
  when "snd_pcm_type_t"
    :pointer
  when "const void *"
    :pointer
  else
    puts "Unknown type: #{param}, #{function.name}" unless $params.include? param
    $params << param
    :UNKNOWN
  end
end
functions.each do |function|
  params_output = ""
  function.parameters.each do |param|
    params_output += ":#{lookup(param.type, function)}, "
  end
  output += "##{function.comment}\n"
  output += "attach_function :#{function.name}, [#{params_output[0..-3]}], :#{lookup(function.return_type, function)}\n"
end
binding.pry
file