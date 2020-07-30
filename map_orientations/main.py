import click
import numpy as np
import re
from imgcat import imgcat
from imageio import imread, imwrite

from helpers import * 

INVALID_PROJECTION_MSG = "Please choose a projection from 'platecarre' or 'gallpeters'."

@click.command()
@click.option('--map_image_path', help='filepath of input map')
@click.option('--rotation', help='rotation')
def transform_map(map_image_path, rotation, in_projection='platecarre', out_projection='platecarre'):
    
    if map_image_path == None:
        raise ValueError('No Map!')

    x, y, z = re.findall('\d+.\d+', rotation)
    
    map_image = imread(map_image_path)
    ny, nx, _ = map_image.shape
    mapdims = (nx, ny)

    xs, ys = np.meshgrid(np.arange(0, nx), np.arange(0, ny))
    xs = xs.flatten().astype(float)
    ys = ys.flatten().astype(float)

    if in_projection == 'platecarre':
        longs, lats = longitudeAndLatitudeFromPCPixel(xs, ys, mapdims)
    elif in_projection == 'gallpeters':
        longs, lats = longitudeAndLatitudeFromGPPixel(xs, ys, mapdims)
    else:
        raise ValueError(INVALID_PROJECTION_MSG)

    xxs, yys, zzs = spatialCoordinatesFromLongitudeAndLatitude(longs, lats)
    
    rot_mat = rotationFromXYZ(float(x), float(y), float(z))
    new_xxyyzz = np.dot(rot_mat, np.array([xxs, yys, zzs]))

    new_xxs = np.squeeze(np.array(new_xxyyzz[0, :]))
    new_yys = np.squeeze(np.array(new_xxyyzz[1, :]))
    new_zzs = np.squeeze(np.array(new_xxyyzz[2, :]))

    new_longs, new_lats = longitudeAndLatitudeFromSpatialCoordinates(new_xxs, new_yys, new_zzs)

    if out_projection == 'platecarre':
        new_xs, new_ys = pixel_for_plate_carre(new_longs, new_lats, mapdims)
    elif out_projection == 'gallpeters':
        new_xs, new_ys = gall_peters_pixels(new_longs, new_lats, mapdims)
    else:
        raise ValueError(INVALID_PROJECTION_MSG)

    new_xs.shape = (ny, nx)
    new_ys.shape = (ny, nx)

    new_map = np.zeros(dtype=map_image.dtype, shape=map_image.shape)

    new_map[:, :, 0] = map_image[new_ys, new_xs, 0]
    new_map[:, :, 1] = map_image[new_ys, new_xs, 1]
    new_map[:, :, 2] = map_image[new_ys, new_xs, 2]
    
    imgcat(new_map)

if __name__ == '__main__':
    transform_map()
