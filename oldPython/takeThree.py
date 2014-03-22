from numpy import *
from scipy import *
from scipy.interpolate import griddata
import Image
import cmath

#imGlobe = Image.open("Desktop/peters-political2.jpg")
#imGlobe = Image.open("Desktop/Whole_world_-_land_and_oceans.jpg")
imGlobe = Image.open("Desktop/small_sat_peters.jpg")
imGlobe.show()

#  Set angles
angleX = 0
angleY = pi/3
angleZ = (2*pi)/3


def rotMatrix(x,y,z):
    return(array([
                [cos(y)*cos(z), -cos(x)*sin(z) + sin(x)*sin(y)*cos(z), sin(x)*sin(z) + cos(x)*sin(y)*cos(z)],
                [cos(y)*sin(z), cos(x)*cos(z) + sin(x)*sin(y)*sin(z), -sin(x)*cos(z) + cos(x)*sin(y)*sin(z)],
                [-sin(y), sin(x)*cos(y), cos(x)*cos(y)]]))


def showNewGlobe(petersGlobe, xAngle, yAngle, zAngle):

    nx, ny = petersGlobe.size
    R = nx / (2 * pi)
    gamma = (ny * pi) / (nx)

    xs = range(nx) * ny
    ys = repeat(range(ny),nx)

    #  Center them
    mx = mean(xs)
    xs = xs - mean(xs)
    xs = xs + mx
    ys = ys - mean(ys)

    #  Longitude is -pi to pi.
    #  Latitude is -pi/2 to pi/2.
    longitude = xs / R
    latitude = arcsin(ys / (gamma * R))

    print "The longitude range is ", min(longitude), "to ", max(longitude)
    print "The latitude range is ", min(latitude), "to ", max(latitude)
    
    
    
    #  Get rotation matrix


    rotationMatrix = rotMatrix(angleX, angleY, angleZ)
    print "The rotation matrix is", rotationMatrix

    #  Get xyz from longitude and latitude.  Use r = 1.
    x = cos(latitude) * cos(longitude)
    y = cos(latitude) * sin(longitude)
    z = sin(latitude)
    
    #  Now get the NEW xyz using the rotation matrix.
    xyz = [x, y, z]
    xyzPrime = dot(rotationMatrix, xyz)


    #  Initialize new longitudes and latitudes.
    newLongitude = longitude
    newLatitude = latitude
    
    #  Now you need to get latitude and longitude BACK from xyzPrime.
    for i in range(nx*ny):
        # get longitudePrime and latitudePrime
        x = xyzPrime[0,i]
        y = xyzPrime[1,i]
        z = xyzPrime[2,i]

        newLatitude[i] = arcsin(z)
        newLongitude[i] = cmath.phase(complex(x,y))

        
#  Need a function to put things in longitude space.
#def modularLongitude(l):
#    ans = l
#    if (l < pi) & (l > -pi):
#        ans = l
#    if (l > pi):
#        ans = (2 * pi) - l
#    if (l < pi):
#        ans = l % (2 * pi)
#    return ans

#newLongitude = (longitude + deltaLongitude) % (2*pi)
#for newLong in newLongitude:
#    newLong = modularLongitude(newLong)
#for i in range(len(newLongitude)):
#    newLongitude[i] = modularLongitude(newLongitude[i])
#newLatitude = (latitude + deltaLatitude)

#for i in range(nx*ny):
#    newLat = newLatitude[i]
#    if (newLat < -pi/2):
#        newLongitude[i] = (newLongitude[i] + pi) % (2*pi)
#        difference = (-pi/2) - newLat
#        newLatitude[i] = (-pi/2) + difference
#    if (newLat > pi/2):
#        newLongitude[i] = (newLongitude[i] + pi) % (2*pi)
#        difference = newLat - (pi/2)
#        newLatitude[i] = (pi/2) - difference


        print "The shape of newLatitude is ", shape(newLatitude)
        print "The shape of newLongitude is ", shape(newLongitude)

#deltaLongitude = 0
#deltaLatitude = -pi/3

        print "the range of new longitudes is ", min(newLongitude), " to ", max(newLongitude)
        print "the range of new latitudes is ", min(newLatitude), " to ", max(newLatitude)
        newXs = R * newLongitude
        newYs = gamma * R * sin(newLatitude)

#  This is cheating.
        newXs = newXs - min(newXs)
        
        print "the range of xs is ", min(xs), " to ", max(xs)
        print "the range of ys is ", min(ys), " to ", max(ys)

        print "the range of new xs is ", min(newXs), " to ", max(newXs)
        print "the range of new ys is ", min(newYs), " to ", max(newYs)
        pointLocations = [newXs, newYs]
        pointLocations = transpose(pointLocations)
#pointLocations = reshape(pointLocations, (2, nx*ny))


        values = array(list(petersGlobe.getdata()))

        print "The shape of values is", shape(values)

        redValues = values[:,0]
        greenValues = values[:,1]
        blueValues = values[:,2]

        print "the shape of pointLocations is", shape(pointLocations)

        #if (any(isnan(redValues))):
        #    print "Some original red values are NAN"
        #if (any(isnan(greenValues))):
        #        print "Some original green values are NAN"
        #        if (any(isnan(blueValues))):
    #print "Some original blue values are NAN"

#if (any(isnan(xs))):
#    print "Some xs are NAN"
#if (any(isnan(ys))):
#    print "Some ys are NAN"
#
#if (any(isnan(pointLocations[:,0]))):
#    print "Some new xs are NAN"
#if (any(isnan(pointLocations[:,1]))):
#    print "Some new ys are NAN"


        sMethod = 'nearest'
        interpolatedReds = griddata(pointLocations, redValues, (xs, ys), method = sMethod)
        print "Got reds."
        interpolatedGreens = griddata(pointLocations, greenValues, (xs, ys), method = sMethod)
        print "Got greens."
        interpolatedBlues = griddata(pointLocations, blueValues, (xs, ys), method = sMethod)
        print "Got blues."


#if (any(isnan(interpolatedReds))):
#    print "Some reds are NAN"
#if (any(isnan(interpolatedBlues))):
#    print "Some blues are NAN"
#if (any(isnan(interpolatedGreens))):
#    print "Some greens are NAN"


        pixels = petersGlobe.load()
        print "Starting the pixel es."
        for i in range(nx):
            for j in range(ny):
                index = j*(nx) + i
                pixels[i,j] = (int(interpolatedReds[index]), int(interpolatedGreens[index]), int(interpolatedBlues[index]))



        petersGlobe.show()

        return(1)

print "did it."


#interpolatedPixelValues = griddata(pointLocations, values, (xs, ys), method = 'linear')
