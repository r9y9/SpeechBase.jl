module SpeechBase

import DSP
using DSP.Windows

# re-export window functions
eval(Expr(:export, names(DSP.Windows)...))

export
  countframes,
  splitframes,
  stft,
  istft,

  # Excitations
  UniformExcitation,
  GaussExcitation,
  generate!,
  generate

for fname in ["stft",
              "excitation"
              ]
    include(string(fname, ".jl"))
end

end # module
