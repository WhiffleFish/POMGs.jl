struct Deterministic{T}
    val::T
end

Base.rand(rng::AbstractRNG, d::Deterministic) = d.val

function Base.iterate(d::Deterministic, state::Int=0)
    return (d.val, 1.0), nothing
end

function Base.iterate(d::Deterministic, state::Nothing)
    return nothing
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