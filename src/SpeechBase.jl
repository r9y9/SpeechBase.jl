module SpeechBase

export stft, istft, splitframes, blackman, hanning

for fname in ["window",
              "stft"]
    include(string(fname, ".jl"))
end

end # module
