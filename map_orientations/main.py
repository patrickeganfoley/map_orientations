import click
import re
from imgcat import imgcat
from imageio import imread
from map_image import MapImage


INVALID_PROJECTION_MSG = "Please choose a projection from 'platecarre' or 'gallpeters'."

@click.command()
@click.option('--map_image_path', help='filepath of input map')
@click.option('--rotation', help='E.G. "(0.0, -0.90, 0.0)"')
def transform_map(map_image_path, rotation, in_projection='platecarre', out_projection='platecarre'):
    
    if map_image_path == None:
        raise ValueError('No Map!')

    x, y, z = re.findall('\d+.\d+', rotation)

    map_image = MapImage(map_image_path, in_projection, out_projection)
    
    map_image.set_grid()
    map_image.set_longitude_latitude()
    map_image.set_new_longitude_latitude(x, y, z)
    map_image.set_new_grid()
    map_image.make_new_map()
    
    imgcat(map_image.new_map)

if __name__ == '__main__':
    transform_map()

