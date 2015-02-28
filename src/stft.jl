# STFT/ISTFT

# countframes returns the number of frames that will be processed.
function countframes(x::AbstractVector, framelen::Integer, hopsize::Integer)
    div(length(x) - framelen, hopsize) + 1
end

# splitframes performs overlapping frame splitting.
function splitframes{T}(x::AbstractVector{T},
                        framelen::Integer=1024,
                        hopsize::Integer=framelen>>1)
    N = countframes(x, framelen, hopsize)
    frames = Array(T, framelen, N)

    @inbounds for i = 1:N
        frames[:,i] = x[(i-1)*hopsize+1:(i-1)*hopsize+framelen]
    end

    frames
end

# stft performs the Short-Time Fourier Transform (STFT) for real signals.
function stft{T}(x::AbstractVector{T},
                 framelen::Integer=1024,
                 hopsize::Integer=framelen>>1,
                 window=hanning(framelen))
    frames = splitframes(x, framelen, hopsize)

    freqbins = framelen>>1 + 1
    spectrogram = Array(Complex{T}, freqbins, size(frames,2))
    @inbounds for i = 1:size(frames,2)
        spectrogram[:,i] = rfft(frames[:,i] .* window)
    end

    spectrogram
end

# istft peforms the Inverse STFT to recover the original signal from STFT
# coefficients.
function istft{T<:Complex}(spectrogram::AbstractMatrix{T},
                           framelen::Integer=1024,
                           hopsize::Integer=framelen>>1,
                           window=hanning(framelen))
    numframes = size(spectrogram, 2)

    expectedlen = framelen + (numframes-1)*hopsize
    reconstructed = zeros(expectedlen)
    windowsum = zeros(expectedlen)
    windowsquare = window .* window

    # Overlapping addition
    @inbounds for i = 1:numframes
        s, e = (i-1)*hopsize+1, (i-1)*hopsize+framelen
        r = irfft(spectrogram[:,i], framelen)
        reconstructed[s:e] += r .* window
        windowsum[s:e] += windowsquare
    end

    # Normalized by window
    @inbounds for i = 1:length(reconstructed)
        # avoid zero division
        if windowsum[i] > 1.0e-7
            reconstructed[i] /= windowsum[i]
        end
    end

    reconstructed
end
