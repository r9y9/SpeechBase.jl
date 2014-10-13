# Blackman window
function blackman(n::Integer)
    const a0, a1, a2 = 0.42, 0.5, 0.08
    t = 2*pi/(n-1)
    [a0 - a1*cos(t*k) + a2*cos(t*k*2) for k=0:n-1]
end

function hanning(n::Integer)
    [0.5*(1-cos(2*pi*k/(n-1))) for k=0:n-1]
end
