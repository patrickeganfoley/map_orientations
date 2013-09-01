#  This defines functions for quaternions stored as arrays of 4 numbers.
using Distributions

#  I don't need to define plus or minus.
function conjugate(q)

    q[2:4] = -q[2:4]
    return q

end

function multiplyQuaternions(p, q)

    pq = zeros(4)

    pq[1] = p[1]*q[1] - p[2]*q[2] - p[3]*q[3] - p[4]*q[4]
    pq[2] = p[1]*q[2] + p[2]*q[1] + p[3]*q[4] - p[4]*q[3]
    pq[3] = p[1]*q[3] - p[2]*q[4] + p[3]*q[1] + p[4]*q[2]
    pq[4] = p[1]*q[4] + p[2]*q[3] - p[3]*q[2] + p[4]*q[1]

    return pq

end

function rotateByQuaternion(x, q)

    qxq = multiplyQuaternions(multiplyQuaternions(q, [0 x[1] x[2] x[3]]), conjugate(q))
    x = [qxq[2] qxq[3] qxq[4]]
    return x

end


function randomVersor(size)

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

    return q

end