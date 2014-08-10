require 'ffi'

module AlsaPCM
  class Sound
    extend FFI::Library
    ffi_lib 'asound'
    ffi_convention :stdcall
    
    attach_function :snd_pcm_open, [:pointer, :string, :int, :int], :int
    attach_function :snd_pcm_close, [:pointer], :int
    attach_function :snd_pcm_drain, [:pointer], :int
    attach_function :snd_pcm_prepare, [:pointer], :int
    attach_function :snd_pcm_writen, [:pointer, :pointer, :ulong], :long
    attach_function :snd_pcm_writei, [:pointer, :pointer, :ulong], :long
    attach_function :snd_pcm_hw_params_malloc, [:pointer], :int
    attach_function :snd_pcm_hw_params_any, [:pointer, :pointer], :int
    attach_function :snd_pcm_hw_params_set_access, [:pointer, :pointer, :int], :int
    attach_function :snd_pcm_hw_params_set_format, [:pointer, :pointer, :int], :int
    attach_function :snd_pcm_hw_params_set_rate, [:pointer, :pointer, :uint, :int], :int
    attach_function :snd_pcm_hw_params_set_channels, [:pointer, :pointer, :int], :int
    attach_function :snd_pcm_hw_params, [:pointer, :pointer], :int
    attach_function :snd_pcm_hw_params_free, [:pointer], :void
    
  end
end
