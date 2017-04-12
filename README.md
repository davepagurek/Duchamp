# Duchamp
Creates a <a href="https://upload.wikimedia.org/wikipedia/en/archive/c/c0/20150719231100%21Duchamp_-_Nude_Descending_a_Staircase.jpg">Nude Descending Staircase</a>-like image given a video file

## Examples
### Without tesselation
<img src="https://github.com/davepagurek/Duchamp/blob/master/examples/1-normal.png?raw=true" width="300" align="middle" /> <img src="https://github.com/davepagurek/Duchamp/blob/master/examples/2-normal.png?raw=true" width="400" align="middle" />

### Tesselated
<img src="https://github.com/davepagurek/Duchamp/blob/master/examples/1-tesselated.png?raw=true" width="300" align="middle" /> <img src="https://github.com/davepagurek/Duchamp/blob/master/examples/2-tesselated.png?raw=true" width="400" align="middle" />

## How it works
### 1. Align the images
The first thing to do is to try to align each image in the sequence next to the previous so that they overlap as much as possible. This is sort of like stitching photos together to make a panorama, except with much less complex blending and parameters.

We want to make sure little colour variations don't mess up the image. We apply a posterize filter to restrict the number of colours per channel on a blurred version of the image to smooth over variations.

<img src="https://github.com/davepagurek/Duchamp/blob/master/examples/intermediate/posterize.png?raw=true" width="400" />

Then, we need to align the filtered versions of the previous and next frame. To do this, we move around image A on top of image B using the `DIFFERENCE` blend mode (where the resulting pixel is defined as `abs(B-A)`) until we have the darkest possible resulting image. Black in the resulting image means the colours stacked on top of each other were the same. We just want to find the x and y offset for the next image such that this difference with the previous image is minimized, but more advanced tools apply bending and adjust other parameters in the alignment.

<img src="https://github.com/davepagurek/Duchamp/blob/master/examples/intermediate/arrange.png?raw=true" width="400" />

We do this for all successive images in the sequence. The shape of the final image is the largest rectangle that contains only image and no empty space. For each frame added, we can take the intersection of the offsetted frame and the previous bounds to get the new bounds to get this.

### 2. Find the interesting parts
We want to have all the moving parts in each frame visible in the final image, so we have to find them. Once our image pairs are aligned, we want to see what regions change from one image to the next so we can redraw those regions on top of the final image. If we just take the difference between frames A and B, we can see what regions changed, but we aren't sure which came from what image. A way to get around this is to subtract the difference between the next frame pair, B and C, from the A-B difference. The `SUBTRACT` blend mode is different than `DIFFERENCE` because it caps the colour at black (so it is defined as `min(B-A, 0)` for images A and B). We end up just removing all parts of the A-B difference also in B-C, effectively leaving just the contributions from A.

We can use a threshold filter on this image to only see regions above a specified difference. This gives nice blob shapes for where movement occurred in the images. We will be using this as a mask, so only the white regions get redrawn on top of the final image. To smooth the edges of the mask, we can blur this.

<img src="https://github.com/davepagurek/Duchamp/blob/master/examples/intermediate/subtract.png?raw=true" width="200" /> <img src="https://github.com/davepagurek/Duchamp/blob/master/examples/intermediate/interesting.png?raw=true" width="200" />

### 3. Merge
The frames get stacked on top of each other according to the offsets from part 1. The interesting regions from part 2 with their smooth-edged masks get drawn on top of this.

### 4. Tesselate
A bunch of random coordinates are generated, weighted so that they're more likely to fall into the white "interesting" regions from the previous step. The image is segmented into a <a href="https://en.wikipedia.org/wiki/Voronoi_diagram">Voronoi diagram</a> around these seed points, where every coordinate contained in a Voronoi region is closer to that region's seed point than to any other seed point. I connect all the vertices of the region to the point in the middle to make triangles and fill them in with the colour of the middle of the region.

<img src="https://github.com/davepagurek/Duchamp/blob/master/examples/intermediate/tesselate.png?raw=true" width="300" />

Depending on how you feel about the look of the image, another option is to draw the interesting regions on top of this tesselation instead of underneath so that they are especially visible at the end.
