struct CFRSolver{G <: POMG, T, RNG<:AbstractRNG}
    game::G
    trees::T
    rng::RNG
end

function CFRSolver(game::POMG; precision=Float64, rng=Random.default_rng())
    trees = Tuple(PolicyTree{precision}(game, i) for i ∈ 1:2)
    return CFRSolver(game, trees, rng)
end

function train!(sol::CFRSolver, n; progress=true)
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

function traverse(sol::CFRSolver, s, p, node_idxs::Tuple, π_i=1.0, π_ni=1.0)
    game = sol.game
    γ = discount(game)

    if isterminal(game, s)
        return 0.0
    else
        A1, A2 = actions(game, s)
        σs = strategies(sol.trees, node_idxs)
        node = sol.trees[p].nodes[node_idxs[p]]
        
        v_σ = 0.0
        v_σ_Ia = node._σ_tmp .= zero(eltype(node._σ_tmp))
        for a1_idx ∈ eachindex(A1), a2_idx ∈ eachindex(A2)
            a_tup = (a1_idx, a2_idx)
            a1,a2 = A1[a1_idx], A2[a2_idx]
            σ_p = σs[p][a_tup[p]]
            σ_np = σs[other_player(p)][a_tup[other_player(p)]]

            for (sp, trans_prob) in transition(game, s, (a1, a2))
                r = reward(game, s, (a1, a2), sp)
                o1,o2 = observation(game, s, (a1,a2), sp)
                next_nodes = isterminal(game, sp) ? node_idxs : τ(sol.trees, node_idxs, (a1,a2), (o1,o2), actions(game, sp))
                val = r[p] + γ*traverse(sol, sp, p, next_nodes, π_i*σ_p, π_ni*σ_np*trans_prob)
                v_σ_Ia[a_tup[p]] += σ_np*trans_prob*val
                v_σ += σ_np*σ_p*trans_prob*val
            end
        end

        sol.trees[p].nodes[node_idxs[p]].r .+= π_ni .* (v_σ_Ia .- v_σ)
        return v_σ
    end
end
