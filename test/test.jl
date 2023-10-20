using POMGs
using POMGs.Games
using POMDPs

game = CompetitiveTiger()
s = Games.TIGER_LEFT
a = (Games.LISTEN, Games.LISTEN)
sp = s

o_dist = observation(game, a, sp)
p = 0.0
for o ∈ support(o_dist)
    p += pdf(o_dist, o)
end
pdf(o_dist, (Games.TIGER_LEFT, Games.TIGER_LEFT))
pdf(o_dist, (Games.TIGER_LEFT, Games.TIGER_RIGHT))
pdf(o_dist, (Games.TIGER_RIGHT, Games.TIGER_RIGHT))
