## This script takes in:
##     * originalImage - some png or jpeg globe
##     * newName       - a string / file location for the new image.
##     * location1     - a (longitude, latitude) tuple
##     * location2     - a (longitude, latitude) tuple
## And produces a new image.

using Images
include("/home/pfoley/globesRepository/julia/globesFunctions.jl")
include("/home/pfoley/globesRepository/julia/positioningFunctions.jl")
include("/home/pfoley/globesRepository/julia/writeImageForQuaternion.jl")


function writeImageForTwoLocationsTest(
    loc1::SphCoords, loc2::SphCoords, originalImage::String, newName::String)

    center = SphCoords(0,0)
    

    spatial_coordinates1 = SpatialCoords(loc1)
    spatial_coordinates2 = SpatialCoords(loc2)
    spatial_coordinates3 = SpatialCoords(center)
    
    midPointOnSurface = spatial_coordinates1 + spatial_coordinates2
    
    
    #  Now obtain the quaternion that rotates the globe to put that midpoint at center.
    println("The midpoint on the earth's surface is $(midPointOnSurface)")

    q_centering = centeringQuaternion(midPointOnSurface)
    q_centering_zero = centeringQuaternion(spatial_coordinates3)
    phxSpatial = spatial_coordinates1
    ugaSpatial = spatial_coordinates2
    q_centering_phx = centeringQuaternion(phxSpatial)
    q_centering_uga = centeringQuaternion(ugaSpatial)
    
    #  Now obtain the quaternion pushing both points to the middle horizontal.
    newPointA = rotateByQuaternion(spatial_coordinates1, q_centering)
    newPointAsph = SphCoords(SpatialCoords(newPointA))

    newLatitudeA = newPointAsph.φ
    q_toHorizontal = pushPointsToHorizontalQuaternion(newPointAsph)
    
      #  multiply them and you're done.
    q = q_toHorizontal * q_centering

    horizontalName = "/home/pfoley/justHorizontal.png"
    zeroName = "/home/pfoley/zeroTest.png"
    centerName = "/home/pfoley/centerTest.png"
    phxName = "/home/pfoley/phxTest.png"
    ugaName = "/home/pfoley/ugaTest.png"

    northName = "/home/pfoley/northTest.png"
    eastName  = "/home/pfoley/eastTest.png"
    clockName = "/home/pfoley/clockTest.png"
    

    cos10 = cos(0.5 * pi/9)
    sin10 = sin(0.5 * pi/9)
    qNorth = quaternion([cos10 0 sin10 0])
    qEast  = quaternion([cos10 0 0 sin10 ])
    qClock = quaternion([cos10 sin10 0 0 ])
    qXAxis = quaternion([1.0,1.0,0,0])
    qYAxis = centeringQuaternion(SpatialCoords(0,1,0))
    qZAxis = centeringQuaternion(SpatialCoords(0,0,1))
    xname = "/home/pfoley/x.png"
    yname = "/home/pfoley/y.png"
    zname = "/home/pfoley/z.png"
    println("About to write images.")
    
    writeImageForQuaternion(qXAxis, originalImage, xname)
    writeImageForQuaternion(qYAxis, originalImage, yname)
    writeImageForQuaternion(qZAxis, originalImage, zname)
    writeImageForQuaternion(qNorth, originalImage, northName)
    writeImageForQuaternion(qEast, originalImage, eastName)
    writeImageForQuaternion(qClock, originalImage, clockName)
    writeImageForQuaternion(q_centering_phx, originalImage, phxName)
    writeImageForQuaternion(q_centering_uga, originalImage, ugaName)
    #writeImageForQuaternion(q_centering_zero, originalImage, zeroName)
    writeImageForQuaternion(q_centering, originalImage, centerName)
    writeImageForQuaternion(q_toHorizontal, originalImage, horizontalName)
    writeImageForQuaternion(q, originalImage, newName)
end