## This script takes in:
##     * originalImage - some png or jpeg globe
##     * newName       - a string / file location for the new image.
##     * location1     - a (longitude, latitude) tuple
##     * location2     - a (longitude, latitude) tuple
## And produces a new image.

using Images
include("/home/pfoley/globesRepository/julia/globesFunctions.jl")
include("/home/pfoley/globesRepository/julia/writeImageForQuaternion.jl")
include("/home/pfoley/globesRepository/julia/positioningFunctions.jl")

function writeImageForTwoLocations(location1, location2, originalImage, newName)

    (longA, latA) = location1
    (longB, latB) = location2

    quaternion = quaternionFromLongitudesAndLatitudes(
        longA, latA, longB, latB)

    writeImageForQuaternion(quaternion, originalImage, newName)
end