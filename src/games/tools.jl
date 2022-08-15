struct Deterministic{T}
    val::T
end

Base.rand(::AbstractRNG, d::Deterministic) = d.val

Base.iterate(d::Deterministic, ::Int=0) = (d.val, 1.0), nothing

Base.iterate(::Deterministic, ::Nothing) = nothing


struct Uniform{T}
    vals::Vector{T}
end

Base.rand(rng::AbstractRNG, d::Uniform) = rand(rng, d.vals)

function Base.iterate(d::Uniform, state::Tuple=1)
    state > length(d.vals) && return nothing 
    val = d.vals[state]
    return (val=>inv(length(d.vals))), state+1
end


struct Categorical{T}
    vals::Vector{T}
    probs::Vector{Float64}
end

function Base.iterate(d::Categorical)
    val, vstate = iterate(d.vals)
    prob, pstate = iterate(d.probs)
    return ((val=>prob), (vstate, pstate))
end

function Base.iterate(d::Categorical, dstate::Tuple)
    vstate, pstate = dstate
    vnext = iterate(d.vals, vstate)
    pnext = iterate(d.probs, pstate)
    if isnothing(vnext) || isnothing(pnext)
        return nothing 
    end
    val, vstate_next = vnext
    prob, pstate_next = pnext
    return ((val=>prob), (vstate_next, pstate_next))
end

# TODO: implement Base.rand(::Categorical)