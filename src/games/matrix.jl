struct MatrixGame{N,T} <: POMG{Bool,NTuple{N,Int},Nothing}
    R::Array{NTuple{N,T}, N}
end

MatrixGame() = MatrixGame([
    (0,0) (-1,1) (1,-1);
    (1,-1) (0,0) (-1,1);
    (-1,1) (1,-1) (0,0)
])

POMGs.initialstate(::MatrixGame) = false

POMGs.players(::MatrixGame{N}) where N = 1:N

POMGs.isterminal(::MatrixGame, s) = s

POMGs.discount(::MatrixGame) = 1.0

POMGs.actions(g::MatrixGame, s, i) = axes(g.R, i)

POMGs.observation(g::MatrixGame{N}, s, a, sp) where N = Iterators.repeated(nothing, N)

POMGs.reward(g::MatrixGame, s, a, sp) = g.R[a...]

function POMGs.transition(g::MatrixGame, s, a)
    return Deterministic(true)
end

function POMGs.gen(g::MatrixGame{N}, s, a, rng) where N
    return (sp=true, o=Iterators.repeated(nothing, N), r=g.R[a...])
end