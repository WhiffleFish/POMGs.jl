struct ESCFRSolver{G <: POMG, T, RNG<:AbstractRNG}
    game::G
    trees::T
    rng::RNG
    ϵ::Float64
end

function ESCFRSolver(game::POMG; precision=Float64, rng=Random.default_rng(), ϵ::Float64=0.6)
    trees = Tuple(PolicyTree{precision}(game, i) for i ∈ 1:2)
    return ESCFRSolver(game, trees, rng, ϵ)
end

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

function traverse(sol::CFRSolver, s, p, node_idxs::Tuple, π_i=1.0, π_ni=1.0, q_h=1.0) # FIXME: very broken
    (;game,ϵ) = sol
    γ = discount(game)

    if isterminal(game, s)
        return 0.0
    else
        A = actions(game, s)
        node_i, node_ni = nodes(sol.trees, node_idxs)
        σ_i, σ_ni = node_i.σ, node_ni.σ
        A_i, A_ni = A[p], A[other_player(p)]
        σ_i, σ_ni = σs[p]
        
        a_i_idx = rand() > ϵ ? weighted_sample(node_i) : rand(eachindex(A_i))
        a_ni_idx = rand(rng, sol.trees[other_player(p)].nodes[node_idxs[other_player(p)]])

        a_i = A_i[a_i_idx]
        a_ni = A_ni[a_ni_idx]

        a_tup = isone(p) ? (a_i, a_ni) : (a_ni, a_i)

        p_a_i = σ_i[a_i_idx]*(1-ϵ) + ϵ/length(A_i)
        p_a_ni = σ_ni[a_ni_idx]
        T = transition(game, s, a_tup)
        sp = rand(T)
        p_a_c = pdf(T, sp)

        r = reward(game, s, a_tup, sp)
        o1, o2 = observation(game, s, a_tup, sp)
        next_nodes = isterminal(game, sp) ? node_idxs : τ(sol.trees, node_idxs, (a1,a2), (o1,o2), actions(game, sp))
        u = r[p] + γ*traverse(sol, sp, p, next_nodes, π_i*σ_i[a_i_idx], π_ni*p_a_ni*p_a_c, q_h*p_a_i)
        
        ûbσh = 0.0
        ûbσha = zero!(player_node._tmp)
        for k ∈ eachindex(A_i)
            ûbσha[k] = if k == ap_idx
                ξha = p_a_i
                u / ξha
            else
                0.0
            end
            ûbσh += σ[k]*ûbσha[k]
        end

        ûbσIa = ûbσha .*= (π_ni / q_h)
        for k in eachindex(ûbσIa) # (d)
            ûbσI += σ[k]*ûbσIa[k]
        end

        @. node_i.r += (ûbσIa - ûbσI)
        @. node_i.s += (π_ni / q_h) * σ_i
        return ûbσh
    end
end
