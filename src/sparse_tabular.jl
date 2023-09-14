# assumed zero-sum
struct SparseTabularPOSG <: POSG{Int, Tuple{Int,Int}, Tuple{Int,Int}}
    T::Matrix{SparseMatrixCSC{Float64, Int64}} # T[a1, a2][sp, s]
    R::Array{Float64, 3} # R[s,a1,a2]
    O::NTuple{2,Matrix{SparseMatrixCSC{Float64, Int64}}} # O[i][a1, a2][sp, o]
    isterminal::SparseVector{Bool, Int}
    initialstate::SparseVector{Float64, Int}
    discount::Float64
end

function SparseTabularPOSG(game::POSG)
    S = ordered_states(game)
    A = A1,A2 = ordered_actions(game) # (A1, A2)
    O = O1,O2 = ordered_observations(game) # (O1, O2)

    terminal = _vectorized_terminal(game, S)
    T = _tabular_transitions(game, S, A, terminal)
    R = _tabular_rewards(game, S, A, terminal)
    O = _tabular_observations(game, S, A, O)
    b0 = _vectorized_initialstate(game, S)
    return ModifiedSparseTabular(T,R,O,terminal,b0,discount(game))
end

function _tabular_transitions(game::POMG, S, A, terminal)
    ns = length(S)
    na1, na2 = length.(A)
    T = fill(zeros(ns,ns), na1, na2)
    for idx ∈ CartesianIndices(T)
        a = Tuple(idx)
        _fill_transitions!(game, T[idx], S, a, terminal)
    end
    T
end

function _fill_transitions!(game::POMG, T, S, a, terminal)
    for (s_idx, s) ∈ enumerate(S)
        if terminal[s_idx]
            T[:, s_idx] .= 0.0
            T[s_idx, s_idx] = 1.0
            continue
        end
        Tsa = transition(game, s, a)
        for (sp_idx, sp) ∈ enumerate(S)
            T[sp_idx, s_idx] = pdf(Tsa, sp)
        end
    end
    T
end

function _tabular_rewards(pomdp, S, A, terminal)
    R = Matrix{Float64}(undef, length(S), length(A))
    for (s_idx, s) ∈ enumerate(S)
        if terminal[s_idx]
            R[s_idx, :] .= 0.0
            continue
        end
        for (a_idx, a) ∈ enumerate(A)
            R[s_idx, a_idx] = reward(pomdp, s, a)
        end
    end
    R
end

function _tabular_observations(pomdp, S, A, O)
    _O = [Matrix{Float64}(undef, length(S), length(O)) for _ ∈ eachindex(A)]
    for i ∈ eachindex(_O)
        _fill_observations!(pomdp, _O[i], S, A[i], O)
    end
    _O
end

function _fill_observations!(pomdp, Oa, S, a, O)
    for (sp_idx, sp) ∈ enumerate(S)
        obs_dist = observation(pomdp, a, sp)
        for (o_idx, o) ∈ enumerate(O)
            Oa[sp_idx, o_idx] = pdf(obs_dist, o)
        end
    end
    Oa
end

function _vectorized_terminal(pomdp, S)
    term = BitVector(undef, length(S))
    @inbounds for i ∈ eachindex(term,S)
        term[i] = isterminal(pomdp, S[i])
    end
    return term
end

function _vectorized_initialstate(pomdp, S)
    b0 = initialstate(pomdp)
    b0_vec = Vector{Float64}(undef, length(S))
    @inbounds for i ∈ eachindex(S, b0_vec)
        b0_vec[i] = pdf(b0, S[i])
    end
    return sparse(b0_vec)
end

POMDPTools.ordered_states(pomdp::ModifiedSparseTabular) = axes(pomdp.R, 1)
POMDPs.states(pomdp::ModifiedSparseTabular) = ordered_states(pomdp)
POMDPTools.ordered_actions(pomdp::ModifiedSparseTabular) = eachindex(pomdp.T)
POMDPs.actions(pomdp::ModifiedSparseTabular) = ordered_actions(pomdp)
POMDPTools.ordered_observations(pomdp::ModifiedSparseTabular) = axes(first(pomdp.O), 2)
POMDPs.observations(pomdp::ModifiedSparseTabular) = ordered_observations(pomdp)

POMDPs.discount(pomdp::ModifiedSparseTabular) = pomdp.discount
POMDPs.initialstate(pomdp::ModifiedSparseTabular) = pomdp.initialstate
POMDPs.isterminal(pomdp::ModifiedSparseTabular, s::Int) = pomdp.isterminal[s]

n_states(pomdp::ModifiedSparseTabular) = length(states(pomdp))
n_actions(pomdp::ModifiedSparseTabular) = length(actions(pomdp))
n_observations(pomdp::ModifiedSparseTabular) = length(observations(pomdp))
