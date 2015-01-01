module SpeechBase

export
  # Basic functionality
  splitframes,
  blackman,
  hanning,
  stft,
  istft,

  # Excitations
  UniformExcitation,
  GaussExcitation,
  generate!,
  generate,

  # Noise reduction (to be removed)
  ss!,
  ss

for fname in ["window",
              "stft",
              "excitation",
              "ss"]
    include(string(fname, ".jl"))
end

end # module
