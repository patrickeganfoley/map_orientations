include("coordinates.jl")
include("lazyQuaternion.jl")


phxLatitude = (33 + (27/60)) * (pi/180)
phxLongitude = - (112 + (4/60))*(pi/180)

ugaLatitude = - (0 + (42 + (36/60)/60)) * (pi / 180)
ugaLongitude = (31 + (24 + (18/60)/60)) * (pi /180)

phoenix = SphCoords(phxLatitude, phxLongitude)
uganda  = SphCoords(ugaLatitude, ugaLongitude)


centeringQuaternion(position::SphCoords) = 
    centeringQuaternion(SpatialCoords(position))

function centeringQuaternion(position::SpatialCoords)
    #  This brings a location ("position") to the center of the map,
    #  where the Gulf of Guinea would be on a normal map, (1,0,0), or
    #  φ = 0, λ = 0.  

    center_coordinates  = [1, 0, 0]
    spatial_coordinates = [position.x, position.y, position.z]

    #  The dot product of center w/ anything else is just the x coordinate.
    angle = acos(0.5*spatial_coordinates[1])    
    crossProduct = cross(spatial_coordinates, center_coordinates)

    #  Then you can say R is rotating about crossprod by angle.  But I don't have that yet.  I guess I do, w quaternions.  
    q = zeros(4,1)
    q[1] = cos(angle/2)
    q[2] = sin(angle/2)*crossProduct[1]
    q[3] = sin(angle/2)*crossProduct[2]
    q[4] = sin(angle/2)*crossProduct[3]

    return(quaternion(q))
end

function centeringQuaternion(x::Array{Real, 2})
    if length(x) == 2
        ##  Assume it's a (φ, λ) pair
        return(centeringQuaternion(SphCoords(x[1], x[2])))
    elseif length(x) == 3
        ##  Assume it's a spatial location
        return(centeringQuaternion(SpatialCoords(x[1], x[2], x[3])))
    else
        error("You tried to obtain a centering quaternion from an array with length not two or three.")
    end
end


function pushPointsToHorizontalQuaternion(position::SphCoords)
    φ = position.φ

    #  This quaternion is just rotating about the CENTER axis (x, in this case)
    #  by the latitude of one of the points.  AFTER it's been moved.  
    q = zeros(4,1)
    q[1] = cos(φ/2)
    q[2] = sin(φ/2)

    #  The others are both zero, since we're rotating about [1 0 0 ]    
    return(quaternion(q))
end


function quaternionForTwoLocations(positionA::SphCoords, positionB::SphCoords)

    #  First obtain the midpoint between the two points.
    #  I don't see any problems w/ pushing out the secant.
    midPoint = SpatialCoords(positionA) + SpatialCoords(positionB)

    #  Now obtain the quaternion that rotates the globe to put that midpoint at center.
    println("The midpoint on the earth's surface is $(midPointOnSurface)")
    q_centering = spatialCoordinatesToCenterQuaternion(midPointOnSurface)
    
    
    #  Now obtain the quaternion pushing both points to the middle horizontal.
    newPointA = rotateByQuaternion(spatial_coordinates1, q_centering)

    newLatitudeA = asin(newPointA[3])

    q_toHorizontal = pushPointsToHorizontalQuaternion(newLatitudeA)
    
      #  multiply them and you're done.
    q = q_toHorizontal * q_centering
    return(q)
end