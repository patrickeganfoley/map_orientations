from numpy import *
from scipy import *
import Image

im = Image.open("Desktop/peters-political2.jpg")
im.show()

nx, ny = im.size

values = list(im.getdata())
xs = range(nx) * (ny)
ys = list(repeat(range(ny),nx))

print len(xs), len(ys), len(values)

#  Now we've got the values and positions - in Peters-projection coordinates.
#  We need to interpolate stuff based on longitude and lattitude.
#  First we'll test the interpolate method with non-integer locations.

xs = array(xs)
ys = array(ys)
values = array(values)

#longitudes = xs * (2 * pi / max(xs))
#  May remove the / 2 here.
#lattitudes = arcsin(2*(ys / max(ys)) - 1 )
longitudes = linspace(0, 2*pi, nx)
lattitudes = arcsin(linspace(-1, 1, ny))

#  longitudes and lattitudes are now in (0 to 2 pi ) and ( 0 to pi )
lambdaStar = pi/4
phiStar = -pi/6

newLongitudes = (longitudes + lambdaStar) % (2*pi)
newLattitudes = (lattitudes + phiStar) % (2*pi)

newXs = newLongitudes
newYs = 2 * sin(newLattitudes)

#  We have now defined the locations for which we have values in the new xspace and yspace.  We need to make these into ... a grid..  err..  put them into 0-999 and 0-633 space instead of what they are now.  And then we interpolate the values at integer locations FROM the values at the other locations.  We get those in a bit list.  Then we change the values of the pixels in the OG picture with something like "getdata".

#  Maybe it will work to get the interpolated values at the old locations.

#interpolatedValues = griddata(pointLocations, values, (xs, ys), method = 'linear')
#pointLocations = 
