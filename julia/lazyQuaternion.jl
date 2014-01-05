#  This defines functions for quaternions stored as arrays of 4 numbers.
using Distributions

type quaternion
    values::Array{Float64}
    #  Values are coded real, i, j, k.
end


Re(q::quaternion) = q.values[1]
i(q::quaternion)  = q.values[2]
j(q::quaternion)  = q.values[3]
k(q::quaternion)  = q.values[4]

import Base.conj
conj(q::quaternion) = quaternion([Re(q) -i(q) -j(q) -k(q) ])
abs(q::quaternion) = sqrt( sum((q*conj(q)).values.^2) )

+(q::quaternion, p::quaternion) = quaternion(q.values + p.values)
-(q::quaternion, p::quaternion) = quaternion(q.values - p.values)

scalar(q::quaternion) = Re(q)
vector(q::quaternion) = [i(q) j(q) k(q)]

function *(q1::quaternion, q2::quaternion)

    pq = zeros(4)

    re1  = Re(q1)
    re2  = Re(q2)
    vec1 = reshape(vector(q1), 3)
    vec2 = reshape(vector(q2), 3)

    re3  = re1*re2 - dot(vec1, vec2)
    vec3 = re1*vec2 + re2*vec1 + cross(vec1, vec2)

    return quaternion([re3 vec3[1] vec3[2] vec3[3]])
end

*(q::quaternion, s::Float64) = quaternion(s*q.values)
*(s::Float64, q::quaternion) = q * s
/(q::quaternion, s::Float64) = quaternion(q.values / s)


function *(q::quaternion, a::Array{Float64,2})
#  When multiplying by an array, if there is only one element, use
#  scalar multiplication.  If there are three, treat them as a vector
#  and multipliy with quaternion multiplication.  If the size is
#  anything else, throw an error.
    if length(a) != 3
        error("Length of vector not equal to three.")
    end

    quaternionA = quaternion([0 a[1] a[2] a[3]])

    return q * quaternionA

end

function *(a::Array{Float64,2}, q::quaternion)
#  I need to implement this twice, since multiplication is not
#  commuatative.
    if length(a) != 3
        error("Length of vector not equal to three.")
    end

    quaternionA = quaternion([0 a])

    return quaternionA * q

end

rotateByQuaternion(x::Array{Float64,2}, q::quaternion) =
    vector(q*x*conj(q))

rotateByQuaternion(loc::SpatialCoords, q::quaternion) =
    rotateByQuaternion([loc.x loc.y loc.z], q)

function rotateByQuaternion(loc::SphCoords, q::quaternion)

    space      = SpatialCoords(loc)
    spacePrime = SpatialCoords(rotateByQuaternion(space, q))
    locPrime   = SphCoords(spacePrime)

    return locPrime

end



function randomVersor(size)
    #  In quaternion rotation, the real part of q is equal to the
    #  cosine of one half the angle by which the vector is rotated.
    #  This sets up a rotation about a random axis by an angle theta,
    #  where theta is chosen from a normal with sd 'size'.  


    # Size is the mean angle.
    theta = rand(Normal(0, size))
    q = zeros(4)

    q[1] = cos(0.5*theta)

    i = rand(Normal())
    j = rand(Normal())
    k = rand(Normal())

    l2 = sqrt(i^2 + j^2 + k^2)
    i /= l2
    j /= l2
    k /= l2

    sinHalfTheta = sin(0.5*theta)

    q[2] = sinHalfTheta * i
    q[3] = sinHalfTheta * j
    q[4] = sinHalfTheta * k

    return quaternion(q)

end