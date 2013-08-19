#  This file contains the following functions that make globe coordinate transfromations
#  and pixel computations.
#
#    coordinateRotationFromXYZ
#    rotationMatrix

#  The following several functions will work to combine each of the others,
#  until I have just one function to get the right pixel value.



function newPixelsFromPixels(pixels, image_size, rotMat)

    longLat = longitudeAndLatitudeFromGallPetersPixels(pixels, image_size)
    spatialCoords = spatialCoordinatesFromLongitudeAndLatitude(longLat)
    newCoords = (rotMat * spatialCoords')'
    newLongLat = longitudeAndLatitudeFromSpatialCoordinates(newCoords)
    newPixels = gallPetersPixels(newLongLat, image_size)

    #  I need to make sure I don't have zeros or maxes.

    for row_i in 1:size(newPixels,1)
        if newPixels[row_i, 1] <= 0
            newPixels[row_i, 1] = 1
        end
        if newPixels[row_i, 1] > image_size[1]
            newPixels[row_i, 1] = image_size[1]
        end
        if newPixels[row_i, 2] <= 0
            newPixels[row_i, 2] = 1
        end
        if newPixels[row_i, 2] > image_size[2]
            newPixels[row_i, 2] = image_size[2]
        end
    end

    return(newPixels)


end



function spatialCoordinatesFromPixels(pixels, image_size)

    longLat = longitudeAndLatitudeFromGallPetersPixels(pixels, image_size)
    spatialCoords = spatialCoordinatesFromLongitudeAndLatitude(longLat)
    return(spatialCoords)

end


function longitudeAndLatitudeFromGallPetersPixels(pixels, image_size)

    #  image_size is nx, ny.
    (nx, ny) = image_size
    #  This computes longitude and latitude for a given pixel value pair.

    longitude =  ((pixels[:,1]* (2*pi/nx)) + pi) % (2*pi)
    latitude = asin( (2*pixels[:,2]/ny) -1)

    return([longitude latitude])

end



function gallPetersPixels(longitudeAndLatitude, image_size)
    (nx, ny) = image_size

#    (longitude, latitude) = longitudeAndLatitude
    #  longitudes are from 0 to 2 pi.
    #  lats are -pi/2 to pi/2.
    longitude = longitudeAndLatitude[:,1]
    latitude = longitudeAndLatitude[:,2]

    longitude = (longitude + 2*pi) % (2*pi)
    latitude = (latitude + 2*pi) % (2*pi)

#println("Size of longitude is", size(longitude))

#  I need to very intentionally treat longitude here.
#    u = ( 0 .<= longitude .<= pi) ? 
#        int( nx * ( 0.5 + (longitude / (2*pi) ) ) ) :
#        int( nx * ( 0 + ((longitude - pi ) / (2*pi))))
 #   u = ones(size(longitude))
    u = 1

    #  I am so sorry.
    #for i = 1:size(longitudeAndLatitude,1)

        if (0 <= longitude[1] <= pi)
            u = int( nx * (0.5 + (longitude / (2*pi))))
        end
        if (pi < longitude[1] <= (2*pi))
            u = int(nx * (longitude - pi) / (2*pi) )
        end
    #end


#    u =  int( longitude * (nx/(2*pi)))
    v =  int( (ny/2)* (sin(latitude)+1))

    return [u v]

end



function spatialCoordinatesFromLongitudeAndLatitude(longitudeAndLatitude)

    #  This returns a row matrix (n_pixel rows, 3 columns) with 
    #  positions in three dimensional space.

    longitude = longitudeAndLatitude[:,1]
    latitude = longitudeAndLatitude[:,2]

    x = cos(longitude) .* cos(latitude)
    y = sin(longitude) .* cos(latitude)
    z = sin(latitude)

    return [x y z]

end



function longitudeAndLatitudeFromSpatialCoordinates( xyz )

    # (x, y, z) = xyz
    x = xyz[:,1]
    y = xyz[:,2]
    z = xyz[:,3]


    latitude = asin(z)
    longitude = atan2(y, x)

    longitude = (longitude + 2*pi ) % (2*pi)

    return [longitude latitude]

end





function coordinateRotationFromXYZ(angleX, angleY, angleZ)

    Rx = rotationMatrix([1 0 0], angleX)
    Ry = rotationMatrix([0 1 0], angleY)
    Rz = rotationMatrix([0 0 1], angleZ)

    return Rx * Ry * Rz

end





function rotationMatrix(axisVector, angle)

    #  First check if the vector is a unit vector.
    axisVector /= sqrt(sum(axisVector.^2))
    (x, y, z) = axisVector


    #  Now just plug in values from
    #  en.wikipedia.org/wiki/Rotation_matrix#Roataion matrix from axis and angle
    tensor_product_matrix = [ x^2     x*y    x*z ;
                             x*y     y^2    y*z ;
                             x*z     y*z    z^2 ]
    cross_product_matrix = [ 0    -z    y ;
                             z     0   -x ;
                            -y     x    0 ]
    R = eye(3)*cos(angle) + 
        sin(angle)*cross_product_matrix + 
        (1-cos(angle))*tensor_product_matrix

    return R

end