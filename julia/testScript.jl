#  This is a test script to just go, with ONE pixel, from o.g. values through to new values.
include("/home/pfoley/globesRepository/julia/globesFunctions.jl")

#  Fake.
image_size = [1000, 1000]
(nx, ny) = image_size

pixels = [40 100]
threePixels = [40 100 ;
               41 101 ;
               120 240]

thetaX = pi/3
thetaY = 0
thetaZ = 0

rotMat = coordinateRotationFromXYZ(thetaX, thetaY, thetaZ)


# Test for one pixel.
longLat = longitudeAndLatitudeFromGallPetersPixels(pixels, image_size)
spatialCoords = spatialCoordinatesFromLongitudeAndLatitude(longLat)
newSpatialCoords = (rotMat * spatialCoords')'
newLongLat = longitudeAndLatitudeFromSpatialCoordinates(newSpatialCoords)
newPixels = gallPetersPixels(newLongLat, image_size)


# Test for three pixels.
pixels = threePixels
longLat = longitudeAndLatitudeFromGallPetersPixels(pixels, image_size)
spatialCoords = spatialCoordinatesFromLongitudeAndLatitude(longLat)
newSpatialCoords = (rotMat * spatialCoords')'
newLongLat = longitudeAndLatitudeFromSpatialCoordinates(newSpatialCoords)
newPixels = gallPetersPixels(newLongLat, image_size)

println("You did the tests up to three pixels.")

# Test for all the pixels. 
pixels = [ (i,j) for i = 1:nx, j = 1:ny ]
npixels = nx*ny
pixels = zeros(npixels,2)
cur = 1
for i = 1:nx
    for j = 1:ny
        pixels[cur,1] = i
        pixels[cur,2] = j
        cur += 1
     end
end

println("Generated the pixel thing ...")

longLat = longitudeAndLatitudeFromGallPetersPixels(pixels, image_size)
println("Got longitude and latitude")
spatialCoords = spatialCoordinatesFromLongitudeAndLatitude(longLat)
println("Got spatial Coordinates")
newSpatialCoords = (rotMat * spatialCoords')'
println("Rotated them...")
newLongLat = longitudeAndLatitudeFromSpatialCoordinates(newSpatialCoords)
println("Got new longitudes and latitudes")
newPixels = gallPetersPixels(newLongLat, image_size)
println("Got new pixel values")

#  Now I'm going to cheat and set min/max stuff.
for i = 1:npixels
    if newPixels[i,1] < 1
        newPixels[i,1] = 1
    end
    if newPixels[i,2] < 1
        newPixels[i,2] = 1
    end

    if newPixels[i,1] > nx
        newPixels[i,1] = nx
    end
    if newPixels[i,2] > ny
        newPixels[i,2] = ny
    end
end


println("Changed the max and min stuff ...")