abstract PulseExcitation

immutable UniformExcitation <: PulseExcitation
end
immutable GaussExcitation <: PulseExcitation
end

abstract Segment
immutable VoicedSegment <: Segment
end
immutable UnVoicedSegment <: Segment
end
const Voiced = VoicedSegment()
const UnVoiced = UnVoicedSegment()

type ExcitationState
    n::Int
end

# return if the segment is voiced or un-voiced given sucessive f0s
function segment_type{T}(f01::T, f02::T)
    if f01 == zero(T) || f02 == zero(T)
        return UnVoiced
    else
        return Voiced
    end
end

## Excitation genration for un-voiced segment

function generate!(e::UniformExcitation,
                   seg::UnVoicedSegment,
                   state::ExcitationState,
                   f01, f02, fs, hopsize)
    state.n = 0
    rand(hopsize)
end

function generate!(e::GaussExcitation,
                   seg::UnVoicedSegment,
                   state::ExcitationState,
                   f01, f02, fs, hopsize)
    state.n = 0
    randn(hopsize)
end

## Excitation genration for voiced segment

# generate f0-dependent excitation
function generate!{T}(e::Union(UniformExcitation, GaussExcitation),
                      seg::VoicedSegment,
                      state::ExcitationState,
                      f01::T, f02::T, fs, hopsize)
    excite = Array(T, hopsize)

    normalized_f01 = fs/f01
    normalized_f02 = fs/f02
    slope = (normalized_f02-normalized_f01) / hopsize
    @inbounds for i = 1:hopsize
        interp = normalized_f01 + slope*(i-1)
        if state.n > int(interp)
            excite[i] = sqrt(interp)
            state.n -= int(interp)
        else
            excite[i] = 0.0
        end
        state.n += 1
    end

    excite
end

function generate{T}(e::PulseExcitation, f0::Vector{T}, fs, hopsize)
    excite = Array(T, hopsize*length(f0))

    state = ExcitationState(0)
    prev_f0 = f0[1]
    @inbounds for i=1:length(f0)
        if i > 1
            prev_f0 = f0[i-1]
        end
        seg = segment_type(prev_f0, f0[i])
        ex = generate!(e, seg, state, prev_f0, f0[i], fs, hopsize)
        for j = 1:length(ex)
            excite[(i-1)*hopsize+j] = ex[j]
        end
    end

    excite
end
