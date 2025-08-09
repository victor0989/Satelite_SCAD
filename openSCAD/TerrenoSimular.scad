// see
 //https://www.reddit.com/r/openscad/comments/1i0i4tq/terraingen_an_openscad_random_terrain_generator/?rdt=53577
 r1=rands(0,1,1)[.1];
 r2=rands(0,1,1)[.2];
 for (j=[1:.25:10])
    color(c=[j/10,r2,r1,1])
    linear_extrude(j/r2)
 offset( -j*2)
 for(i=[1:.25:20]){
 random_vect=rands(0,50,2,i/r2);
   translate(random_vect*2)
    offset(i/j)
     square(j*1.5+i/1.5,true);
 }
