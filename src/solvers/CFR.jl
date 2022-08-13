struct CFRSolver{G <: POMG, T, RNG<:AbstractRNG}
    game::G
    trees::T
    rng::RNG
end

function train!(sol::CFRSolver, n)
    prog = Progress(n; enabled=show_progress)
    s0 = initialstate(sol.game)
    for i ∈ 1:n
        regret_match!(sol)
        for p ∈ players(game)
            traverse(sol, s0, p, (1,1))
        end
        next!(prog)
    end
end

function traverse(sol, s, p, node_idxs::Tuple, π_i=1.0, π_ni=1.0)
    game = sol.game
    γ = discount(game)

    if isterminal(game, s)
        return 0.0
    else
        A1, A2 = actions(game, s, 1), actions(game, s, 2)
        L1, L2 = length(A1), length(A2)
        σs = strategies(sol.trees, node_idxs)
        
        v_σ = 0.0
        v_σ_Ia = zero(σs[p])
        for a1_idx ∈ eachindex(A1), a2_idx ∈ eachindex(A2)
            a_tup = (a1_idx, a2_idx)
            a1,a2 = A1[a1_idx], A2[a2_idx]
            sp, o, r = gen(game, s, (a1, a2)) # is there any way to generalize to N players ???
            # σ_a = joint_action_prob(σs, (a1_idx, a2_idx))
            σ_p = σs[p][a_tup[p]]
            σ_np = σs[other_player(p)][a_tup[other_player(p)]]

            next_nodes = τ(sol.trees, node_idxs, (a1,a2), o, (L1, L2))
            val = r[p] + γ*traverse(sol, sp, i, next_nodes, π_i*σ_p, π_ni*σ_np)
            
            v_σ_Ia[a_tup[p]] += σ_np*val
            v_σ += σ_np*σ_p*val
        end

        trees[p].nodes[node_idxs[p]].r .+= π_ni .* (v_σ_Ia .- v_σ)
        return v_σ
    end
end