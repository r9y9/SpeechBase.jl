module SpeechBase

export stft, istft, splitframes, blackman, hanning, ss!, ss

for fname in ["window",
              "stft",
              "ss"]
    include(string(fname, ".jl"))
end

end # module
