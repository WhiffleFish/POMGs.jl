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
            regret_match!(sol.trees[p])
        end
        next!(prog)
    end
end

# llvm pls compile my shitty code into something reasonably performant
function traverse(sol::CFRSolver, s, p, node_idxs::Tuple, π_i=1.0, π_ni=1.0)
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
            σ_p = σs[p][a_tup[p]]
            σ_np = σs[other_player(p)][a_tup[other_player(p)]]

            for (sp, trans_prob) in transition(game, s, (a1, a2))
                r = reward(game, s, (a1, a2), sp)
                o1,o2 = observation(game, s, (a1,a2), sp)
                next_nodes = τ(sol.trees, node_idxs, (a1,a2), (o1,o2), (L1, L2))
                val = r[p] + γ*traverse(sol, sp, p, next_nodes, π_i*σ_p, π_ni*σ_np*trans_prob)
                v_σ_Ia[a_tup[p]] += σ_np*trans_prob*val
                v_σ += σ_np*σ_p*trans_prob*val
            end
        end

        sol.trees[p].nodes[node_idxs[p]].r .+= π_ni .* (v_σ_Ia .- v_σ)
        return v_σ
    end
end

# function traverse(sol::CFRSolver, s, p, node_idxs::Tuple, π_i=1.0, π_ni=1.0)
#     game = sol.game
#     γ = discount(game)

#     if isterminal(game, s)
#         return 0.0
#     else
#         A_i, A_ni = actions(game, s, p), actions(game, s, other_player(p))
#         L_i, L_ni = length(A_i), length(A_ni)
#         I_i, I_ni = sol.trees[p].nodes[node_idxs[p]], sol.trees[other_player(p)].nodes[node_idxs[other_player(p)]]
#         σ_i, σ_ni = I_i.σ, I_ni.σ
        
#         v_σ = 0.0
#         v_σ_Ia = zero(σ_i)
#         for a_i_idx ∈ eachindex(A_i), a_ni_idx ∈ eachindex(A_ni)

#             a_tup = (a1_idx, a2_idx)
#             a1,a2 = A1[a1_idx], A2[a2_idx]
#             σ_p = σs[p][a_tup[p]]
#             σ_np = σs[other_player(p)][a_tup[other_player(p)]]

#             for (sp, trans_prob) in transition(game, s, (a_1, a_2))
#                 r = reward(game, s, a, sp)
#                 next_nodes = τ(sol.trees, node_idxs, (a1,a2), o, (L1, L2))
#                 val = r[p] + γ*traverse(sol, sp, i, next_nodes, π_i*σ_p, π_ni*σ_np*trans_prob)
#                 v_σ_Ia[a_tup[p]] += σ_np*trans_prob*val
#                 v_σ += σ_np*σ_p*trans_prob*val
#             end
#         end

#         I_i.r .+= π_ni .* (v_σ_Ia .- v_σ)
#         return v_σ
#     end
# end