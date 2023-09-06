struct ProductDistribution{D<:Tuple}
    dists::D
end

Random.rand(rng::AbstractRNG, d::Random.SamplerTrivial{<:ProductDistribution}) = map(_d->rand(rng, _d), d[].dists)
