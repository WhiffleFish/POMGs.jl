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

# Base.iterate(::Deterministic, ::Nothing) = nothing


struct Uniform{T}
    vals::Vector{T}
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

Base.iterate(d::Categorical, s=(1,1)) = iterate(zip(d.vals, d.probs), s)

# function Base.iterate(d::Categorical)
#     val, vstate = iterate(d.vals)
#     prob, pstate = iterate(d.probs)
#     return ((val=>prob), (vstate, pstate))
# end

# function Base.iterate(d::Categorical, dstate::Tuple)
#     vstate, pstate = dstate
#     vnext = iterate(d.vals, vstate)
#     pnext = iterate(d.probs, pstate)
#     if isnothing(vnext) || isnothing(pnext)
#         return nothing 
#     end
#     val, vstate_next = vnext
#     prob, pstate_next = pnext
#     return ((val=>prob), (vstate_next, pstate_next))
# end

# TODO: implement Base.rand(::Categorical)