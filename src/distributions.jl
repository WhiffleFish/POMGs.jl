struct ProductDistribution{D<:Tuple}
    dists::D
    ProductDistribution(t::Tuple) = new{typeof(t)}(t)
    ProductDistribution(args...) = new{typeof(args)}(args)
end

Base.iterate(d::ProductDistribution) = iterate(d.dists)
Base.iterate(d::ProductDistribution, i) = iterate(d.dists, i)
Base.getindex(d::ProductDistribution, i) = getindex(d.dists, i)
Base.length(d::ProductDistribution) = length(d.dists)

POMDPs.pdf(d::ProductDistribution, x) = mapreduce(*, x, d.dists) do x_i, dist
    POMDPs.pdf(dist, x_i)
end

POMDPs.support(d::ProductDistribution) = Iterators.product((support(_d) for _d ∈ d)...)

Random.rand(rng::AbstractRNG, d::Random.SamplerTrivial{<:ProductDistribution}) = map(_d->rand(rng, _d), d[].dists)
