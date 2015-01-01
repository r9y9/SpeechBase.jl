abstract PulseExcitation

type UniformExcitation <: PulseExcitation
end

type GaussExcitation <: PulseExcitation
end

type ExcitationState
    n::Int
end

function generate!(e::Union(UniformExcitation, GaussExcitation),
                   state::ExcitationState,
                   f01::Float64, f02::Float64,
                   fs::Real, hopsize::Int)
    excite = Array(Float64, hopsize)

    # absent segment
    if f01 == 0.0 || f02 == 0.0
        state.n = 0
        if isa(e, UniformExcitation)
            return rand(hopsize)
        elseif isa(e, GaussExcitation)
            return randn(hopsize)
        end
    end

    # generate f0-dependent excitation
    normalized_f01 = fs/f01
    normalized_f02 = fs/f02
    slope = (normalized_f02-normalized_f01) / hopsize
    for i=1:hopsize
        interp = normalized_f01 + slope*(i-1)
        if state.n > int(interp)
            @inbounds excite[i] = sqrt(interp)
            state.n -= int(interp)
        else
            excite[i] = 0.0
        end
        state.n += 1
    end

    excite
end

function generate(e::PulseExcitation, f0::Vector{Float64}, fs::Int,
                  hopsize::Int)
    excite = Array(Float64, hopsize*length(f0))

    state = ExcitationState(0)
    prev_f0 = f0[1]
    for i=1:length(f0)
        if i > 1
            @inbounds prev_f0 = f0[i-1]
        end
        excite_a_frame = generate!(e, state, prev_f0, f0[i], fs, hopsize)
        for j=1:length(excite_a_frame)
            @inbounds excite[(i-1)*hopsize+j] = excite_a_frame[j]
        end
    end

    excite
end
