# Spectral Subtraction

function ss!(input, noise;
             w::Union(Float64, Vector{Float64})=1.0,
             floorrate::Float64=0.01)
    @assert size(input) == size(noise)
    input[:,:] -= w.* noise[:,:]

    const lowerbound = floorrate .* w .* noise
    oversubtracted_indices = input .< lowerbound
    input[oversubtracted_indices] = lowerbound[oversubtracted_indices]

    nothing
end

function ss(input, noise;
            w::Union(Float64, Vector{Float64})=1.0,
            floorrate::Float64=0.01)
    subtracted = copy(input)
    ss!(subtracted, noise, w=w, floorrate=floorrate)
    return subtracted
end
