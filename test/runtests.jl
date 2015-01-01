using SpeechBase
using Base.Test

for fname in ["stft"]
    include(string(fname, ".jl"))
end

function test_excitation()
    println("Testing: excitation signal generation")
    f0 = [zeros(100), 100*ones(100), zeros(100)]
    fs = 16000
    hopsize = 80

    e = generate(UniformExcitation(), f0, fs, hopsize)
    @test !any(isnan(e))

    e = generate(GaussExcitation(), f0, fs, hopsize)
    @test !any(isnan(e))
end

test_excitation()
