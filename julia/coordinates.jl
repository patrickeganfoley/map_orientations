#  This contains types and functions to go back and forth between
#  (φ,  λ) pairs and (x, y, z) positions.

type SphCoords
    φ::Float64
    λ::Float64

    function SphCoords(φ::Real, λ::Real)
    #  I'm not forcing φ ∈ (-π/2, π/2) or λ ∈ (-π, π) here.
    #  I'm not yet sure where the right place is for that.
        φ %= 2pi
        λ %= 2pi
        new(float64(φ), float64(λ))
    end

end

type SpatialCoords
    x::Float64
    y::Float64
    z::Float64

    # tol = 1e-8

    function SpatialCoords(x::Real, y::Real, z::Real)
        normSquared = x^2 + y^2 + z^2
        if abs( 1 - normSquared ) > 1e-8
            println("Warning: a spatial coordinate was not on the unit sphere.")
            norm = sqrt(normSquared)
            x /= norm
            y /= norm
            z /= norm    
        end
        new(float64(x), float64(y), float64(z))
    end

end

SpatialCoords(x::Array{Float64}) = SpatialCoords(x[1],x[2],x[3])
SpatialCoords(x::Array{Int64}) = SpatialCoords(x[1],x[2],x[3])

function SpatialCoords(position::SphCoords)
    φ = position.φ
    λ = position.λ
    #  I ought to know if the compiler would take care of 
    #  this kind of thing for me.
    cosφ = cos(φ)
    x = cosφ * cos(λ)
    y = cosφ * sin(λ)
    z = sin(φ)

    return SpatialCoords(x, y, z)
end

function SphCoords(position::SpatialCoords)
    x = position.x
    y = position.y
    z = position.z

    φ = asin(z)
    λ = atan2(y, x)

    return SphCoords(φ, λ)
end