function [indx,pcount] = eqAreaSubs(lon,lat,nsph,npts,pcount)
  % nsph is how many cells
  % npts is how many points per cell wanted

  % pcount is how many points per cell counted from full data
  % indx is vector showing yes or no
  
  if nargin<5
    pcount = split2cells(lon,lat,nsph);
  end

  indx = (rand(length(lon),1)<=  npts./pcount);
