from scipy import *
from numpy import *
import Image

def roll(image, delta):
    "Roll an image sideways"

    xs, ys = image.size

    "Make a copy."
    fullRegion = (0, 0, xs, ys)
    imageCopy = image.crop(fullRegion)

    delta = delta % xs
    if delta == 0:
        return image

    part1 = imageCopy.crop((0, 0, delta, ys))
    part2 = imageCopy.crop((delta, 0, xs, ys))

    image.paste(part2, (0, 0, xs - delta, ys))
    image.paste(part1, (xs - delta, 0, xs, ys))

    return image


im = Image.open("Desktop/earth-huge.png")

xs, ys = im.size
deltaList = linspace(0, xs, 12)
for delta_i in deltaList:
    delta_i = int(delta_i)
    tempImage = roll(im, delta_i)
    tempImage.show()



###FOR LOOP THING





im2.show()
