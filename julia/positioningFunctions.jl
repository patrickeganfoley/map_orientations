phxLatitude = (33 + (27/60)) * (pi/180)
phxLongitude = - (112 + (4/60))*(pi/180)

ugaLatitude = (0 + (18 + (49/60)/60)) * (pi / 180)
ugaLongitude = (32 + (34 + (52/60)/60)) * (pi /180)


function longitudeAndLatitudeToCenterQuaternion(longitude, latitude)
    #  This function takes a point, specified by longitude and latitude, and returns a
    #  rotation matrix that places that point on the center of a map.


    spatial_coordinates = 
        [cos(longitude)*cos(latitude) sin(longitude)*cos(latitude) sin(latitude)]


    center_coordinates = [1 0 0]

    angle = acos(spatial_coordinates * center_coordinates')
    uv = spatial_coordinates * center_coordinates
    crossprod = [(uv[2,3] - uv[3,2])   (uv[3,1] - uv[1,3])   (uv[1,2] - uv[2,1])]

    #  Then you can say R is rotating about crossprod by angle.  But I don't have that yet.  I guess I do, w quaternions.  
    q = zeros(4,1)
    q[1] = cos(angle/2)
    q[2] = sin(angle/2)*crossprod[1]
    q[3] = sin(angle/2)*crossprod[2]
    q[4] = sin(angle/2)*crossprod[3]


    return q

end


function spatialCoordinatesToCenterQuaternion(spatial_coordinates)

    center_coordinates = [1 0 0]

    angle = acos(spatial_coordinates[1])
    uv = spatial_coordinates * center_coordinates
    crossprod = [(uv[2,3] - uv[3,2])   (uv[3,1] - uv[1,3])   (uv[1,2] - uv[2,1])]

    #  Then you can say R is rotating about crossprod by angle.  But I don't have that yet.  I guess I do, w quaternions.  
    q = zeros(4,1)
    q[1] = cos(angle/2)
    q[2] = sin(angle/2)*crossprod[1]
    q[3] = sin(angle/2)*crossprod[2]
    q[4] = sin(angle/2)*crossprod[3]


    return q

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

return q

end


function quaternionFromLongitudesAndLatitudes(longitudeA, latitudeA, longitudeB, latitudeB)

#  First obtain the midpoint between the two points.

#  I don't see any problems w/ just taking the .... secant and pushing out.
spatial_coordinates1 = 
  [cos(longitudeA)*cos(latitudeA) sin(longitudeA)*cos(latitudeA) sin(latitudeA)]

spatial_coordinates2 = 
  [cos(longitudeB)*cos(latitudeB) sin(longitudeB)*cos(latitudeB) sin(latitudeB)]

midPointInEarth = (1/2) * (spatial_coordinates1 + spatial_coordinates2)
midPointOnSurface = midPointInEarth / (sqrt(sum(midPointInEarth.^2)))


#  Now obtain the quaternion that rotates the globe to put that midpoint at center.
println(midPointOnSurface)
q_centering = spatialCoordinatesToCenterQuaternion(midPointOnSurface)


#  Now obtain the quaternion pushing both points to the middle horizontal.
newPointA = rotateByQuaternion(spatial_coordinates1, q_centering)
newLatitudeA = asin(newPointA[3])
q_toHorizntal = pushPointsToHorizontalQuaternion(newLatitudeA)


#  multiply them and you're done.
q = multiplyQuaternion(q_toHorizontal, q_centering)
return q

end