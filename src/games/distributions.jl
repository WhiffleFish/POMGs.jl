struct Deterministic{T}
    val::T
end

Base.rand(::AbstractRNG, d::Deterministic) = d.val

function Base.iterate(d::Deterministic, s=(1,1))
    return if first(s) > 1
        nothing
    else
        (d.val, 1.0), (2,2)
    end
end

struct Uniform{T}
    vals::Vector{T}
    p::Float64
    Uniform(v::AbstractVector) = new{eltype(vals)}(v, inv(length(v)))
end

Base.rand(rng::AbstractRNG, d::Uniform) = rand(rng, d.vals)

function Base.iterate(d::Uniform, state::Tuple=1)
    state > length(d.vals) && return nothing
    val = d.vals[state]
    return (val=>inv(length(d.vals))), state+1
end

uniform(::Type{T}, l::Integer) where T = fill(T(inv(l)), l)
uniform(l::Integer) = fill(inv(l), l)

struct Categorical{T}
    vals::Vector{T}
    probs::Vector{Float64}
end

Base.length(d::Categorical) = length(d.vals)

Base.iterate(d::Categorical, s=(1,1)) = iterate(zip(d.vals, d.probs), s)

# TODO: double check that this is correct
function Base.rand(rng::AbstractRNG, d::Categorical)
    s = sum(probs)
    r = rand(rng)*s
    c = first(d.probs)
    i = 1
    U = r
    while U > c && i < length(d)
        i += 1
        c += d.probs[i]
    end
    return d.vals[i]
end
