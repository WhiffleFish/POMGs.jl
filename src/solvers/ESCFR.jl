struct ESCFRSolver{G <: POMG, T, RNG<:AbstractRNG}
    game::G
    trees::T
    rng::RNG
end

function ESCFRSolver(game::POMG; precision=Float64, rng=Random.default_rng())
    trees = Tuple(PolicyTree{precision}(game, i) for i ∈ 1:2)
    return ESCFRSolver(game, trees, rng)
end

function weighted_sample(rng::AbstractRNG, w::AbstractVector)
    t = rand(rng)
    i = 1
    cw = first(w)
    while cw < t && i < length(w)
        i += 1
        @inbounds cw += w[i]
    end
    return i
end

weighted_sample(w::AbstractVector) = weighted_sample(Random.GLOBAL_RNG, w)

Random.rand(I::PolicyNode) = weighted_sample(I.σ)

function train!(sol::ESCFRSolver, n; progress=true)
    prog = Progress(n; enabled=progress)
    s0 = initialstate(sol.game)
    for i ∈ 1:n
        for p ∈ players(sol.game)
            traverse(sol, s0, p, (1,1))
            update_strategy!(sol.trees[p])
        end
        next!(prog)
    end
end

function traverse(sol::CFRSolver, s, p, node_idxs::Tuple)
    game = sol.game
    γ = discount(game)

    if isterminal(game, s)
        return 0.0
    else
        A = actions(game, s)
        node_i, node_ni = nodes(sol.trees, node_idxs)
        σ_i, σ_ni = node_i.σ, node_ni.σ
        A_i, A_ni = A[p], A[other_player(p)]
        σ_i, σ_ni = σs[p]

        v_σ = 0.0
        player_node = sol.trees[p].nodes[node_idxs[p]]
        v_σ_Ia = zero!(player_node._tmp)

        a_ni_idx = rand(rng, sol.trees[other_player(p)].nodes[node_idxs[other_player(p)]])
        a_ni = A_ni[a_ni_idx]
        a_tup = isone(p) ? (first(A_i), a_ni) : (a_ni, first(A_i))
        for a_i_idx ∈ eachindex(A_i)
            a_i = A_i[a_i_idx]
            a_tup = setindex(a_tup, a_i, p)
            sp = rand(rng, transition(game, s, a_tup))
            r = reward(game, s, a_tup, sp)
            o1, o2 = observation(game, s, a_tup, sp)
            next_nodes = isterminal(game, sp) ? node_idxs : τ(sol.trees, node_idxs, (a1,a2), (o1,o2), actions(game, sp))
            val = r[p] + γ*traverse(sol, sp, p, next_nodes)
            v_σ_Ia[ap_idx] = val
            v_σ += σ_p*val
        end

        @. node_i.r += (1 - σ_i) * (v_σ_Ia - v_σ)
        @. node_i.s += σ_i
        return v_σ
    end
end
