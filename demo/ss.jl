using SpeechBase
using WAV

# Demo of Spectral Subtration (SS)

x₁, fs₁ = wavread("input.wav")
x₂, fs₂ = wavread("noise.wav")
@assert fs₁ == fs₂
x₁, x₂ = vec(x₁), vec(x₂)

# align start position
const searchmax = fs₂ * 5 # can be tuned
m = indmax(xcorr(x₁[1:searchmax], x₂[1:searchmax])) - searchmax
@show m
if m < 0
    x₂ = x₂[abs(m)+1:end]
else
    x₁ = x₁[abs(m)+1:end]
end

# adjast length
maxlen = min(length(x₁), length(x₂))
@show maxlen
x₁, x₂ = x₁[1:maxlen], x₂[1:maxlen]

framelen = 2048
X₁ᶜ = stft(x₁, framelen)
X₂ᶜ = stft(x₂, framelen)

@show size(X₁ᶜ)
@show size(X₂ᶜ)

X₁, P₁ = abs(X₁ᶜ), angle(X₁ᶜ)
X₂ = abs(X₂ᶜ)

# perform spectral subtraction
elapsed_ss = @elapsed ss!(X₁, X₂, w=0.98, floorrate=0.05)
println("Elapsed time in SS: $(elapsed_ss) sec.")

# back to complex domain
Yᶜ = X₁ .* exp(im * P₁)

# back to time domain
y = istft(Yᶜ, framelen)

wavwrite(float32(y), "input_ss.wav", Fs=fs₁)
