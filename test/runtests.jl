using SpeechBase
using Base.Test

for fname in ["stft"]
    include(string(fname, ".jl"))
end
