using SpeechBase
using WAV
using Base.Test

# load test data
x_test16k, fs = wavread("test16k.wav")
x_test16k = vec(x_test16k)
@assert fs == 16000

let
    println("test consistency between stft and istft")

    x = copy(x_test16k)
    for winfunc in (hanning, blackman)
        for framelen in (4096, 2048, 1024, 512)
            const win = winfunc(framelen)
            for shiftdenom in (2, 3, 4, 5, 6, 7, 8) # 50% overlap, 75% ...
                const hopsize = div(framelen, shiftdenom)

                X = stft(x, framelen, hopsize, win)
                @test !any(isnan(X))

                y = istft(X, framelen, hopsize, win)
                @test !any(isnan(y))

                len = min(length(x), length(y))
                x, y = x[1:len], y[1:len]

                # check reconstruction error
                err = norm(x-y)/norm(x)
                @show (framelen, hopsize, winfunc, err)
                @test norm(x-y)/norm(x) < 0.05
            end
        end
    end
end

let
    println("Testing: excitation signal generation")
    srand(98765)
    f0 = [zeros(100); 100*ones(100); zeros(100)]
    fs = 16000
    hopsize = 80

    e = generate(UniformExcitation(), f0, fs, hopsize)
    @test !any(isnan(e))
    @test all(e .>= 0.0)

    e = generate(GaussExcitation(), f0, fs, hopsize)
    @test !any(isnan(e))
    @test !all(e .>= 0.0)
end
