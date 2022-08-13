struct PolicyNode{T}
    σ::Vector{T}
    r::Vector{T}
    s::Vector{T}
end

function PolicyNode{T}(l)
    return PolicyNode(
            fill(T(inv(l)), l), 
            zeros(T, l), 
            zeros(T, l)
    )
end

regret(n::PolicyNode) = n.r
strategy_sum(n::PolicyNode) = n.s
strategy(n::PolicyNode) = n.s ./ sum(n.s)

struct PolicyTree{T,A,O}
    nodes::Vector{PolicyNode{T}}
    children::Dict{Tuple{Int,A,O}, Int} # τ(bao)
end

function τ(tree::PolicyTree{T}, b_idx, a, o, l) where T
    get!(tree.children, (b_idx, a, o)) do
        PolicyNode{T}(l)
    end
end

function τ(trees::Tuple, b_idxs::Tuple, as::Tuple, os::Tuple, Ls::Tuple)
    return Tuple(
        τ(trees[i], b_idxs[i], as[i], os[i], Ls[i]) 
        for i ∈ eachindex(trees)
    )
end

function strategies(trees::Tuple, idxs)
    return Tuple(tree.nodes[idxs[i]] for i in eachindex(trees, idxs))
end

function joint_action_prob(strats, idxs)
    p = 1.0
    for i ∈ eachindex(strats, idxs)
        p *= strats[idxs[i]]
    end
    return p
end

regret_match!(n::PolicyNode) = n.σ .= n.r ./ sum(n.r)

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
    tup
end
