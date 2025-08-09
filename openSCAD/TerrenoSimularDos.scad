// see
 //https://www.reddit.com/r/openscad/comments/1i0i4tq/terraingen_an_openscad_random_terrain_generator/?rdt=53577
r1 = rands(0,1,1)[0.1];
r2 = rands(0,1,1)[0.2];

for (j = [1 : 0.25 : 10])
{
  color([j / 10, r2, r1, 1])
  linear_extrude(j / r2)
  offset(-2 * j)
  difference()
  {
    // Make the base outline.
    for (i = [1 : 0.25 : 20])
    {
      random_vect = rands(0, 50, 2, i / r2);
      
      translate(random_vect * 2)
      offset(i / j)
      square(j * 1.5 + i / 1.5, center = true);
    }
    
    // Make some holes in the base.
    for (i = [1 : 0.5 : 5])
    {
      random_vect = rands(0, 50, 2, i / r2);
      
      translate(random_vect * 2)
      offset(i / j)
      square(j * 1.5 + i / 1.5, center = true);
    }
  }
}