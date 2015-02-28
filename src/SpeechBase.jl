module SpeechBase

export
  splitframes,
  blackman,
  hanning,
  stft,
  istft,

  # Excitations
  UniformExcitation,
  GaussExcitation,
  generate!,
  generate

for fname in ["window",
              "stft",
              "excitation"
              ]
    include(string(fname, ".jl"))
end

end # module
