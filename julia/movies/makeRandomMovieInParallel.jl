#  This is a script to make a movie.
include("/home/pfoley/globesRepository/julia/lazyQuaternion.jl")

resolution = 500
quaternionSize = 0.05


quaternions = zeros(resolution, 4)

#  First loop and generate all the quaternions I need.
q = [1 0 0 0]
quaternions[1,:] = q

for i = 2:resolution
    marginalQ = randomVersor(quaternionSize)
    q = multiplyQuaternions(marginalQ, q)
   
    quaternions[i,:] = q
end

@everywhere using Images
@everywhere include("/home/pfoley/globesRepository/julia/writeImageForQuaternion.jl")
@everywhere include("/home/pfoley/globesRepository/julia/lazyQuaternion.jl")

println("Using images everywhere.")

@parallel for i = 1:resolution

    resolution = 500

    ogName = "/home/pfoley/globesRepository/maps/miller_graphical_large.jpg"
    outputFolder = "/home/pfoley/globesRepository/sixthMovie/"

    #  Pull quaternion
    current_q = quaternions[i,:]

    #  First loop through the y direction.
    nameNumber = 100+i
    new_image_name = "$(outputFolder)image$(nameNumber).png"
    writeImageForQuaternion(current_q,ogName,new_image_name)

end