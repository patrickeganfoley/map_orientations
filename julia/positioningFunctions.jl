include("lazyQuaternion.jl")

phxLatitude = (33 + (27/60)) * (pi/180)
phxLongitude = - (112 + (4/60))*(pi/180)

ugaLatitude = - (0 + (42 + (36/60)/60)) * (pi / 180)
ugaLongitude = (31 + (24 + (18/60)/60)) * (pi /180)


function longitudeAndLatitudeToCenterQuaternion(longitude, latitude)
    #  This function takes a point, specified by longitude and latitude, and returns a
    #  rotation matrix that places that point on the center of a map.
    spatial_coordinates = 
        [cos(longitude)*cos(latitude) sin(longitude)*cos(latitude) sin(latitude)]

    return(spatialCoordinatesToCenterQuaternion(spatial_coordinates))
end


function spatialCoordinatesToCenterQuaternion(spatial_coordinates)
    center_coordinates = [1 0 0]
    center_coordinates  = reshape(center_coordinates,  3)
    spatial_coordinates = reshape(spatial_coordinates, 3)

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


function pushPointsToHorizontalQuaternion(latitude)
    #  I don't think I actually need both.  
    #  Really I think I only need one latitude. 
    
    #  This quaternion is just rotating about the CENTER axis (x, in this case)
    #  by the latitude of one of the points.  AFTER it's been moved.  
    q = zeros(4,1)
    q[1] = cos(latitude/2)
    q[2] = sin(latitude/2)
    #  The others are both zero, since we're rotating about [1 0 0 ]
    
    return(quaternion(q))
    
end


function quaternionFromLongitudesAndLatitudes(
    longitudeA, latitudeA, 
    longitudeB, latitudeB)
    #  First obtain the midpoint between the two points.
    #  I don't see any problems w/ pushing out the secant.
    spatial_coordinates1 = 
      [cos(longitudeA)*cos(latitudeA) sin(longitudeA)*cos(latitudeA) sin(latitudeA)]
    spatial_coordinates2 = 
      [cos(longitudeB)*cos(latitudeB) sin(longitudeB)*cos(latitudeB) sin(latitudeB)]
    
    midPointInEarth = (1/2) * (spatial_coordinates1 + spatial_coordinates2)
    
    midPointOnSurface = midPointInEarth / (sqrt(sum(midPointInEarth.^2)))
    
    
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