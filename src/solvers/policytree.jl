struct PolicyNode{T}
    σ::Vector{T}
    r::Vector{T}
    s::Vector{T}
    _tmp::Vector{T}
end

function PolicyNode{T}(l) where T
    return PolicyNode(
            fill(T(inv(l)), l),
            zeros(T, l),
            fill(T(inv(l)), l),
            Vector{T}(undef, l)
    )
end

zero!(v::AbstractVector{T}) where T = fill!(v, zero(T))

regret(n::PolicyNode) = n.r
strategy_sum(n::PolicyNode) = n.s
strategy(n::PolicyNode) = n.s ./ sum(n.s)

struct PolicyTree{T,A,O}
    nodes::Vector{PolicyNode{T}}
    children::Dict{Tuple{Int,A,O}, Int} # τ(bao)
end

function PolicyTree{T}(game::POMG{S,Tuple{A1,A2},O}, p::Number) where {T,S,A1,A2,O}
    A = isone(p) ? A1 : A2
    s0 = initialstate(game)
    act = actions(game, s0, p)


    return PolicyTree(
            PolicyNode{T}[PolicyNode{T}(length(act))],
            Dict{Tuple{Int,A,O}, Int}()
    )
end

Base.length(tree::PolicyTree) = length(tree.nodes)

"""
b' = τ(bao)
where b' is the index/id of the new belief node in the policy tree
"""
function τ(tree::PolicyTree{T}, b_idx, a, o, l) where T
    get!(tree.children, (b_idx, a, o)) do
        push!(tree.nodes, PolicyNode{T}(l))
        length(tree.nodes)
    end
end

function τ(trees::Tuple, b_idxs::NTuple{N,Int}, as::Tuple, os::Tuple, As::Tuple) where N
    return NTuple{N,Int}(
        τ(trees[i], b_idxs[i], as[i], os[i], length(As[i]))
        for i ∈ eachindex(trees)
    )
end

function strategies(trees::Tuple, idxs::NTuple{N,Int}) where N
    return NTuple{N,Vector{Float64}}(trees[i].nodes[idxs[i]].σ for i in eachindex(trees, idxs))
end

function joint_action_prob(strats, idxs)
    p = 1.0
    for i ∈ eachindex(strats, idxs)
        p *= strats[idxs[i]]
    end
    return p
end

function regret_match!(n::PolicyNode)
    (;σ, r) = n
    s = zero(eltype(r))
    @inbounds for i in eachindex(σ,r)
        if r[i] > zero(eltype(r))
            s += r[i]
            σ[i] = r[i]
        end
    end
    s > zero(eltype(r)) ? (σ ./= s) : fill!(σ,inv(length(σ)))
end

function regret_match!(tree::PolicyTree)
    for node ∈ tree.nodes
        regret_match!(node)
    end
    tree
end

function regret_match!(trees::Tuple)
    for tree ∈ trees
        regret_match!(tree)
    end
    trees
end

function update_strategy!(n::PolicyNode)
    regret_match!(n)
    n.s .+= n.σ
end

function update_strategy!(tree::PolicyTree)
    for node ∈ tree.nodes
        update_strategy!(node)
    end
    tree
end

function update_strategy!(trees::Tuple)
    for tree ∈ trees
        update_strategy!(tree)
    end
    trees
end
