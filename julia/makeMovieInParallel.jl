#  This is a script to make a movie.

#  using Images
#  using Distributions

resolution = 8000

@everywhere using Images
@everywhere using Distributions
@everywhere include("/home/pfoley/globesRepository/julia/globesFunctions.jl")
@everywhere include("/home/pfoley/globesRepository/julia/positioningFunctions.jl")
@everywhere include("/home/pfoley/globesRepository/julia/writeImageForQuaternion.jl")

#  This is ten degrees.  
#  This really ought to be much smaller.  maybe pi/180.  It needs to be smoother.  
smallAngle = pi/180

#  First generate all the quaternions.  
marginalQuaternions = Array(quaternion, 8000)
quaternions         = Array(quaternion, 8000)

for iter = 1:8000

    randAxis = rand(Normal(), 3)
    randAxis ./= norm(randAxis)

    compQuaternion = quaternion( [ cos(smallAngle/2), sin(smallAngle/2) .* randAxis ])
    marginalQuaternions[iter] = compQuaternion

end

quaternions = Array(quaternion, 8000)
quaternions[1] = quaternion([1.0, 1.0, 0.0, 0.0]) # Start with null.
for iter = 2:8000

    quaternions[iter] = marginalQuaternions[iter] * quaternions[iter-1]

end

#  Now I can pull those in parallel.  
@parallel for iter = 1:8000

    resolution = 8000

    #ogName = "/home/pfoley/very_large_upsideDown.jpg"
    ogName = "/home/pfoley/globesRepository/small_sat_peters.jpg"
    outputFolder = "/home/pfoley/smallMovie2/"


    #  Change this to parallel loop.

    #  First loop through the y direction.
    nameNumber = 1000+iter
    new_image_name = "$(outputFolder)image$(nameNumber).png"

    writeImageForQuaternion(quaternions[iter], ogName, new_image_name)

end