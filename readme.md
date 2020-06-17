# Map Projections

This repo contains a few notebooks and some script to generate interesting maps.  The maps are all standard projections, but with new orientations.

[This notebook](map_projections.ipynb) gives a quick overview with examples showing re-oriented cylindrical projections.  [This one](explaining_map_projections.ipynb) is a bit messier but it attempts to walk through all the actual logic and explain it.  It's me working through how to do this. 

[This notebook](Blaueu\_Stereographic.ipynb) is more recent and I think it's pretty cool - it takes Blaueu's _Terrarium Orbis_, one of the first stereographic projection maps, and rotates it.

I would like to
  * add a simple example gif rotating the globe a bit
  * clean up the stuff in projections.py - it's VERY old (5+ years) and is pretty gross
  * also clean up the Blaueu notebook 
  * unify the Blaueu stuff with the other stuff so I can show the Blaueu map with a cylindrical projection

#  Rotating Blaueu's 1664 Terrarium Orbis

![Rotating Blaueu](blaueu_framed.gif)

#  Examples

This code produces maps like these:

![A Normal Map, With the Earth Rotated South](downmap.png)


![Lights Map with a Random Rotation](lights7.jpg)
![Lights Map with a Random Rotation](lights10.jpg)
![Lights Map with a Random Rotation](lights3.jpg)

