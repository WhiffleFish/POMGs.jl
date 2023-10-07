struct ProductDistribution{D<:Tuple}
    dists::D
    ProductDistribution(t::Tuple) = new{typeof(t)}(t)
    ProductDistribution(args...) = new{typeof(args)}(args)
end

Base.iterate(d::ProductDistribution) = iterate(d.dists)
Base.iterate(d::ProductDistribution, i) = iterate(d.dists, i)

Distributions.pdf(d::ProductDistribution, x) = mapreduce(*, x, d.dists) do x_i, dist
    pdf(dist, x_i)
end

Random.rand(rng::AbstractRNG, d::Random.SamplerTrivial{<:ProductDistribution}) = map(_d->rand(rng, _d), d[].dists)
