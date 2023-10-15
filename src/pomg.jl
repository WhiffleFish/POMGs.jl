export 
    POMG, 
    discount, 
    transition, 
    observation,
    player_observation,
    reward, 
    isterminal, 
    initialstate, 
    players,
    states,
    actions,
    player_actions, 
    observations,
    player_observations,
    @gen,
    gen,
    belief_reward,
    isterminal_belief,
    statetype,
    actiontype,
    obstype
    

"""
    POMG{S,A,O}
Abstract base type for a partially observable Markov games.
    S: state type
    A: joint action type
    O: joint observation type
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

"""
    player_observation(m::POMG, i::Int, a, sp)

Return observation distribution for player `i`

"""
function player_observation end

player_observation(m::POMG, i::Int, s, a, sp) = player_observation(m, i, a, sp)
player_observation(m::POMG, i::Int, a, sp) = player_observation(m, i, sp)


function reward end

reward(p::POMG, s, a, sp, o) = reward(p, s, a, sp)
reward(p::POMG, s, a, sp) = reward(p, s, a)

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

"""
    actions(game)

Returns the action space for each player (A1, A2)

--
    actions(game, s)

Returns the actions that can be taken for each player (A1, A2) at state `s`

"""
function actions end

actions(g::POMG, s) = actions(g)

actions(g::POMG, s, p) = actions(g, s)[p]

"""
    player_actions(game, p)

Returns the action space for player `p`

--
    player_actions(game, s, p)

Returns the actions that can be taken by player `p` at state `s`
"""
function player_actions end

player_actions(game::POMG, i) = actions(game)[i]

player_actions(game::POMG, i, s) = actions(game, s)[i]

"""
    states(game)

Returns the state space of a given game
"""
function states end

"""
    (O1, O2) = observations(game)

Returns the observation space of a given game for both players
"""
function observations end

observations(p::POMG, s) = observations(p)

"""
    Oi = player_observations(game::POMG, i::Int)

Returns the observation space of a given game for player `i`
"""
function player_observations end

player_observations(p::POMG, i::Int, s) = player_observations(p, i)

function gen end

@inline other_player(i) = 3-i

"""
    belief_reward(game::POMG, b, a)
"""
function belief_reward end

"""
    isterminal_belief(game::POMG, b)
"""
function isterminal_belief end

statetype(::POMG{S}) where S = S
actiontype(::POMG{S,A}) where {S,A} = A
obstype(::POMG{S,A,O}) where {S,A,O} = O

"""
    stateindex(game::POMG, s)
"""
function stateindex end

"""
    player_actionindex(game::POMG, i::Int, a)
"""
function player_actionindex end

"""
    player_obs(game::POMG, i::Int, a)
"""
function player_obsindex end
