# STFT/ISTFT

# countframes returns the number of frames that will be processed.
function countframes{T<:Number}(x::Vector{T}, framelen::Int, hopsize::Int)
    div(length(x) - framelen, hopsize) + 1
end

# splitframes performs overlapping frame splitting.
function splitframes{T<:Number}(x::Vector{T}, 
                                framelen::Int=1024,
                                hopsize::Int=framelen/2)
    const N = countframes(x, framelen, hopsize)
    frames = Array(eltype(x), framelen, N)

    for i=1:N
        frames[:,i] = x[(i-1)*hopsize+1:(i-1)*hopsize+framelen]
    end

    return frames
end

# stft performs Short-Time Fourier Transform (STFT).
function stft{T<:Real}(x::Vector{T}, 
                       framelen::Int=1024,
                       hopsize::Int=int(framelen/2),
                       window=hanning(framelen))
    frames = splitframes(x, framelen, hopsize)

    spectrogram = Array(Complex64, size(frames))
    for i=1:size(frames,2)
        spectrogram[:,i] = fft(frames[:,i] .* window)
    end

    return spectrogram
end

# istft peforms Inverse Short-Time Fourier Transform
function istft{T<:Complex}(spectrogram::Matrix{T},
                           framelen::Int=1024,
                           hopsize::Int=int(framelen/2),
                           window=hanning(framelen))
    const numframes = size(spectrogram, 2)
    expectedlen = framelen + (numframes-1)*hopsize
    reconstructed = zeros(expectedlen)
    windowsum = zeros(expectedlen)
    const windowsquare = window .* window

    # Overlapping addition
    for i=1:numframes
        s, e = (i-1)*hopsize+1, (i-1)*hopsize+framelen
        r = real(ifft(spectrogram[:,i]))
        reconstructed[s:e] += r .* window
        windowsum[s:e] += windowsquare
    end

    # Normalized by window
    for i=1:endof(reconstructed)
        # avoid zero division
        if windowsum[i] > 1.0e-7
            reconstructed[i] /= windowsum[i]
        end
    end

    return reconstructed
end
