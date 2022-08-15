export 
    POMG, 
    discount, 
    transition, 
    observation, 
    reward, 
    isterminal, 
    initialstate, 
    players, 
    actions, 
    gen

"""
    POMG{S,A,O}
Abstract base type for a partially observable Markov games.
    S: state type
    A: joint action type
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

function observation end

observation(problem::POMG, a, sp) = observation(problem, sp)

observation(problem::POMG, s, a, sp) = observation(problem, a, sp)

function reward end

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

function players end

players(::POMG) = 1:2

function actions end

actions(g::POMG, s) = actions(g)

actions(g::POMG, s, p) = actions(g, s)[p]

function gen end

@inline other_player(i) = 3-i
