import click
import re
from imgcat import imgcat
from imageio import imread
from map_image import MapImage

PROJECTIONS = ['platecarre', 'gallpeters']
INVALID_PROJECTION_MSG = "Please choose a projection from 'platecarre' or 'gallpeters'."

@click.command()
@click.option('--map_image_path', help='filepath of input map')
@click.option('--rotation', help='E.G. "(0.0, -0.90, 0.0)"')
@click.option('--in_projection', default='platecarre')
@click.option('--out_projection', default='platecarre')
def transform_map(map_image_path, rotation, in_projection, out_projection):
    
    if map_image_path == None:
        raise ValueError('No Map!')

    rotation = re.findall('\d+.\d+', rotation)
    if len([float(i) for i in rotation]) != 3:
        raise ValueError('Please use a string representing 3 floats E.G. "(0.0, -0.90, 0.0)"')

    if in_projection not in PROJECTIONS or out_projection not in PROJECTIONS:
        raise ValueError(INVALID_PROJECTION_MSG)


    map_image = MapImage(map_image_path, rotation, in_projection, out_projection)
    
    map_image.set_grid()
    map_image.set_longitude_latitude()
    map_image.set_new_longitude_latitude()
    map_image.set_new_grid()
    map_image.make_new_map()
    
    imgcat(map_image.new_map)

if __name__ == '__main__':
    transform_map()
