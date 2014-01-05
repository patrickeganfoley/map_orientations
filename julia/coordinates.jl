#  This contains types and functions to go back and forth between
#  (φ,  λ) pairs and (x, y, z) positions.
import Base.abs

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
        if !(-1e-8 <  1 - normSquared  < 1e-8)
            # println("Warning: a spatial coordinate was not on the unit sphere.")
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

+(a::SpatialCoords, b::SpatialCoords) =
    SpatialCoords(a.x+b.x, a.y+b.y, a.z+b.z)

import Base.print

function print(position::SphCoords)
    φ = position.φ * (180 / pi)
    λ = position.λ * (180 / pi)

    north = φ > 0
    east  = λ > 0

    #  Right now I just print degrees.
    if north
        print("$(round(φ))ᵒ North,   ")
    else
        print("$(round(φ))ᵒ South,   ")
    end

    if east
        println("$(round(λ))ᵒ East \n")
    else
        println("$(round(λ))ᵒ West \n")
    end
end

function print(position::SpatialCoords)
    println("($(position.x) , $(position.y) , $(position.z) )")
end

#  This doesn't work and I don't know why.  
import Base.show
show(STDOUT, position::SpatialCoords) = print(STDOUT, "$position")
show(STDOUT, position::SphCoords)     = print(STDOUT, position)

