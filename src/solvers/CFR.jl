# TODO: add max_depth & leaf-node value estimator
struct CFRSolver{G <: POMG, T, UP}
    game::G
    trees::T
    updater::UP
end

function CFRSolver(game::POMG; precision=Float64, updater=POMDPs.updater(game))
    trees = Tuple(PolicyTree{precision}(game, i) for i ∈ 1:2)
    return CFRSolver(game, trees, updater)
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

function traverse(sol::CFRSolver, b, p, node_idxs::Tuple, π_i=1.0, π_ni=1.0)
    game = sol.game
    upd = sol.updater
    γ = discount(game)

    if isterminal_belief(game, b)
        return 0.0
    else
        A1, A2 = actions(game, b)
        σs = strategies(sol.trees, node_idxs)

        v_σ = 0.0
        player_node = sol.trees[p].nodes[node_idxs[p]]
        v_σ_Ia = zero!(player_node._tmp) # zero(σs[p])
        for a1_idx ∈ eachindex(A1), a2_idx ∈ eachindex(A2)
            a_tup = (a1_idx, a2_idx)
            a1,a2 = A1[a1_idx], A2[a2_idx]
            σ_p = σs[p][a_tup[p]]
            σ_np = σs[other_player(p)][a_tup[other_player(p)]]
            r = belief_reward(game, b, (a1, a2))

            for ((o1, o2), po) ∈ weighted_iterator(belief_observation(game, (a1,a2), bp))
                bp = update(upd, b, (a1, a2), (o1, o2))
                next_nodes = isterminal_belief(game, bp) ? node_idxs : τ(sol.trees, node_idxs, (a1,a2), (o1,o2), actions(game, bp))
                val = r[p] + γ*traverse(sol, bp, p, next_nodes, π_i*σ_p, po*π_ni*σ_np*trans_prob)
                v_σ_Ia[a_tup[p]] += po*σ_np*trans_prob*va
                v_σ += po*σ_np*σ_p*trans_prob*val
            end
        end

        sol.trees[p].nodes[node_idxs[p]].r .+= π_ni .* (v_σ_Ia .- v_σ)
        return v_σ
    end
end
