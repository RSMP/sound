require 'ffi'

module AlsaPCM
  class Sound
    extend FFI::Library
    ffi_lib 'asound'
    ffi_convention :stdcall
    
    attach_function :snd_pcm_open, [:pointer, :string, :int, :int], :int
    attach_function :snd_pcm_prepare, [:pointer], :int
    attach_function :snd_pcm_writen, [:pointer, :pointer, :ulong], :long
    attach_function :snd_pcm_hw_params_malloc, [:pointer], :int
    attach_function :snd_pcm_hw_params_any, [:pointer, :pointer], :int
    attach_function :snd_pcm_hw_params_set_access, [:pointer, :pointer, :int], :int
    attach_function :snd_pcm_hw_params_set_format, [:pointer, :pointer, :int], :int
    attach_function :snd_pcm_hw_params_set_rate_near, [:pointer, :pointer, :uint, :int], :int
    attach_function :snd_pcm_hw_params_set_channels, [:pointer, :pointer, :int], :int
    attach_function :snd_pcm_hw_params, [:pointer, :pointer], :int
    attach_function :snd_pcm_hw_params_free, [:pointer], :void
    
  end
end

# open the device
handle = FFI::MemoryPointer.new(:pointer)
AlsaPCM::Sound.snd_pcm_open(handle, "default", 0, 0)

# allocate hardware parameters
params = FFI::MemoryPointer.new(:pointer)
AlsaPCM::Sound.snd_pcm_hw_params_malloc(params)
AlsaPCM::Sound.snd_pcm_hw_params_any(handle.read_pointer, params.read_pointer)

# set params
SND_PCM_ACCESS_RW_NONINTERLEAVED = 4
SND_PCM_FORMAT_S16_LE = 2
AlsaPCM::Sound.snd_pcm_hw_params_set_access (handle.read_pointer, params.read_pointer, SND_PCM_ACCESS_RW_NONINTERLEAVED)
AlsaPCM::Sound.snd_pcm_hw_params_set_format (handle.read_pointer, params.read_pointer, SND_PCM_FORMAT_S16_LE)
AlsaPCM::Sound.snd_pcm_hw_params_set_rate_near (handle.read_pointer, params.read_pointer, 44100, 0);
AlsaPCM::Sound.snd_pcm_hw_params_set_channels (handle.read_pointer, params.read_pointer, 1);

AlsaPCM::Sound.snd_pcm_hw_params (handle.read_pointer, params.read_pointer);
AlsaPCM::Sound.snd_pcm_hw_params_free (params.read_pointer);

AlsaPCM::Sound.snd_pcm_prepare(handle.read_pointer)
AlsaPCM::Sound.snd_pcm_writen (playback_handle, buf, 128)

