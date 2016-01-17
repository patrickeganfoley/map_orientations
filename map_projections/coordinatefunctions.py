#  P Foley
#  Dec 28 2015
#  Translation of globesFunctions.jl.  Couldn't get new Images or ImageView 
#  to work due to tcl-tk problems.  
#  Contains functions to reorient cylindrical projection maps
import numpy as np


def newPixelsFromPixels(pixels, image_size, rotMat):
    
    longLat = longitudeAndLatitudeFromGallPetersPixels(pixels, image_size)
    spatialCoords = spatialCoordinatesFromLongitudeAndLatitude(longLat)
    newCoords = np.transpose((rotMat * np.transpose(spatialCoords)))
    newLongLat = longitudeAndLatitudeFromSpatialCoordinates(newCoords)
    newPixels = gallPetersPixels(newLongLat, image_size)

    #  I need to make sure I don't have zeros or maxes.

    for row_i in 0:newPixels.shape[0]
        if newPixels[row_i, 0] <= 0
            newPixels[row_i, 0] = 1
        end
        if newPixels[row_i, 0] > image_size[1]
            newPixels[row_i, 0] = image_size[1]
        end
        if newPixels[row_i, 2] <= 0
            newPixels[row_i, 2] = 1
        end
        if newPixels[row_i, 2] > image_size[2]
            newPixels[row_i, 2] = image_size[2]
        end
    end

    return(newPixels)


