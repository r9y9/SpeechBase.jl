using SpeechBase
using WAV

# https://github.com/r9y9/RPCA.jl
using RPCA

# Singing voice separation using Robust PCA

x, fs = wavread("input.wav")
x = vec(x)

# x = x[fs*0+1:fs*60]

@show size(x)

framelen = 4096
Xᶜ = stft(x, framelen)

X, P = abs(Xᶜ), angle(Xᶜ)
@show size(X)

# performs RPCA
# A: row-rank matrix
# S: sparse matrix
elapsed_rpca = @elapsed begin
    A, E = inexact_alm_rpca(X, verbose=true)
end
println("Elapsed time in Robust PCA: $(elapsed_rpca) sec.")

# back to time domain
a = istft(A .* exp(im * P), framelen)
e = istft(E .* exp(im * P), framelen)

wavwrite(float32(a), "input_A.wav", Fs=fs)
wavwrite(float32(e), "input_E.wav", Fs=fs)
