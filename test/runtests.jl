using POMGs
using POMGs.Games
using Test

@testset "smoke" begin
    atol = 1e-2
    game = MatrixGame()
    sol = CFRSolver(game)
    train!(sol, 10)

    s1 = sol.trees[1].nodes[1].s
    σ1 = s1 ./ sum(s1)
    s2 = sol.trees[2].nodes[1].s
    σ2 = s2 ./ sum(s2)

    @test length(sol.trees[1]) == length(sol.trees[1].nodes) == 1
    @test length(sol.trees[2]) == length(sol.trees[2].nodes) == 1

    @test all(σ1 .≈ 1/3)
    @test all(σ2 .≈ 1/3)

    # prisoner's dilemma
    game = MatrixGame([
        (-1,-1) (-3,0);
        (0,-3) (-2,-2)
    ])
    sol = CFRSolver(game)
    train!(sol, 10_000)

    s1 = sol.trees[1].nodes[1].s
    σ1 = s1 ./ sum(s1)
    s2 = sol.trees[2].nodes[1].s
    σ2 = s2 ./ sum(s2)

    @test length(sol.trees[1]) == length(sol.trees[1].nodes) == 1
    @test length(sol.trees[2]) == length(sol.trees[2].nodes) == 1

    @test isapprox(σ1,[0.,1.], atol=1e-2)
    @test isapprox(σ2,[0.,1.], atol=1e-2)

    # https://sites.math.northwestern.edu/~clark/364/handouts/bimatrix-mixed.pdf
    game = POMGs.Games.MatrixGame([
            (1,1) (0,0) (0,0);
            (0,0) (0,2) (3,0);
            (0,0) (2,0) (0,3);
    ])
    sol = CFRSolver(game)
    train!(sol, 10_000)
    NEs = [[6/11,3/11,2/11], [0,3/5,2/5], [1,0,0]]
    σ1 = sol.trees[1].nodes[1].s
    σ2 = sol.trees[2].nodes[1].s
    σ1 /= sum(σ1)
    σ2 /= sum(σ2)
    @test begin
        ≈(σ1, NEs[1], atol=atol) ||
        ≈(σ1, NEs[2], atol=atol) ||
        ≈(σ1, NEs[3], atol=atol)
    end

    @test begin
        ≈(σ2, NEs[1], atol=atol) ||
        ≈(σ2, NEs[2], atol=atol) ||
        ≈(σ2, NEs[3], atol=atol)
    end
end

##
# game = Kuhn()
# sol = CFRSolver(game)
# train!(sol, 10_000)

# sol.trees[2].nodes[1].s


# s0 = initialstate(game)
# actions(game, s0)
# s,p = first(transition(game, s0, (0,0)))
# sp, pp = first(transition(game, s, (1,0)))
