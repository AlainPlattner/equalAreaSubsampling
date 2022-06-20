function testeqAreaSubs(nsph,npts)
  % nsph is how many cells
  % npts is how many points per cell

  regular = false

  if regular
    reslon = 1;
    reslat = 1;
    lonedge = 0:reslon:360;
    colaedge = reslat:reslat:180-reslat;
    [lon,cola] = meshgrid(lonedge,colaedge);
    lon = lon(:);
    cola = cola(:);
    lat = 90-cola(:);
  else
    dat = load('synth_Mars_noise10pc_gmtloc.txt');
    lon = dat(:,1);
    lat = dat(:,2);
  end
    
  [indx,pcount] = eqAreaSubs(lon,lat,nsph,npts);

  figure(1)
  subplot(2,1,1)
  plot(lon,lat,'.')
  subplot(2,1,2)
  plot(lon(indx),lat(indx),'.')

  % figure(2)
  % [x,y,z] = sph2cart(deg2rad(lon(indx)),deg2rad(lat(indx)),1);
  % plot3(x,y,z,'.')

  sum(indx)/length(indx)

  % Difficulties:
  % 1. The larger the triangles (lower nsph), the greater issues
  %    with too many points at the edge of finite regions.
  %    This can be resolved by either using smaller triangles,
  %    or by using points from outside to do the subselection and then only
  %    take the points within the region
  % 2. If the triangles are too small, there may be a risk that the same points
  %    are picked too often??? Although, it is possible to have zero points
  %    in a cell...
