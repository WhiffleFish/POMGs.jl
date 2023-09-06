struct MatrixGame{N,T} <: POMG{Bool,NTuple{N,Int},Nothing}
    R::Array{NTuple{N,T}, N}
end

MatrixGame() = MatrixGame([
    (0,0) (-1,1) (1,-1);
    (1,-1) (0,0) (-1,1);
    (-1,1) (1,-1) (0,0)
])

POMGs.initialstate(::MatrixGame) = Deterministic(false)

POMGs.players(::MatrixGame{N}) where N = 1:N

POMGs.isterminal(::MatrixGame, s) = s

POMGs.discount(::MatrixGame) = 1.0

POMGs.actions(g::MatrixGame, s) = axes(g.R)

POMGs.actions(g::MatrixGame, s, i) = axes(g.R, i)

POMGs.observation(::MatrixGame{N}, s, a, sp) where N = Deterministic(NTuple{N, Nothing}(nothing for _ in 1:N))

POMGs.reward(g::MatrixGame, s, a, sp) = g.R[a...]

POMGs.transition(::MatrixGame, s, a) = Deterministic(true)

function POMGs.gen(g::MatrixGame{N}, s, a, rng) where N
    return (sp=true, o=NTuple{N, Nothing}(nothing for _ in 1:N), r=g.R[a...])
end
