# POMDP model functions
"""
    POMG{S,A,O}
Abstract base type for a partially observable Markov games.
    S: state type
    A: action type
    O: observation type
"""
abstract type POMG{S,A,O} end

"""
    discount(m::POMG)
Return the discount factor for the problem.
"""
function discount end

"""
    transition(m::POMG, state, action)
Return the transition distribution from the current state-action pair.
If it is difficult to define the probability density or mass function explicitly, consider using `POMDPModelTools.ImplicitDistribution` to define a generative model.
"""
function transition end

"""
    observation(m::POMG, statep)
    observation(m::POMG, action, statep)
    observation(m::POMG, state, action, statep)
Return the observation distribution. You need only define the method with the fewest arguments needed to determine the observation distribution.
If it is difficult to define the probability density or mass function explicitly, consider using `POMDPModelTools.ImplicitDistribution` to define a generative model.
# Example
```julia
using POMDPModelTools # for SparseCat
struct MyPOMDP <: POMDP{Int, Int, Int} end
observation(p::MyPOMDP, sp::Int) = SparseCat([sp-1, sp, sp+1], [0.1, 0.8, 0.1])
```
"""
function observation end

observation(problem::POMG, a, sp) = observation(problem, sp)

observation(problem::POMG, s, a, sp) = observation(problem, a, sp)

"""
    reward(m::POMG, s, a)
Return the immediate reward for the s-a pair.
    reward(m::POMG, s, a, sp)
Return the immediate reward for the s-a-s' triple
    reward(m::POMG, s, a, sp, o)
Return the immediate reward for the s-a-s'-o quad
For some problems, it is easier to express `reward(m, s, a, sp)` or `reward(m, s, a, sp, o)`, than `reward(m, s, a)`, but some solvers, e.g. SARSOP, can only use `reward(m, s, a)`. Both can be implemented for a problem, but when `reward(m, s, a)` is implemented, it should be consistent with `reward(m, s, a, sp[, o])`, that is, it should be the expected value over all destination states and observations.
"""
function reward end

reward(m::POMG, s, a, sp) = reward(m, s, a)

reward(m::POMG, s, a, sp, o) = reward(m, s, a, sp)

"""
    isterminal(m::POMG, s)
Check if state `s` is terminal.
If a state is terminal, no actions will be taken in it and no additional rewards will be accumulated. Thus, the value function at such a state is, by definition, zero.
"""
isterminal(problem::POMG, state) = false

"""
    initialstate(m::POMG)
Return a distribution of initial states for POMG `m`.
If it is difficult to define the probability density or mass function explicitly, consider using `POMDPModelTools.ImplicitDistribution` to define a model for sampling.
"""
function initialstate end

@inline other_player(i) = 3-i
