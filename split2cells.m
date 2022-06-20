function  pcount = split2cells(lon,lat,nsph)
  % npin = split2cells(lon,lat,nsph)
  %
  % Creates equal-area triangulation of the sphere, then determines
  % for each location lon/lat, how many other points are in the same cell.
  %
  % INPUT:
  %
  % lon     longitudinal coordinates of the data points [degrees]
  % lat     latitudinal coordinates of the data points [degrees]
  % nsph    parameter for number of cells. Larger number -> more cells
  %
  % OUTPUT:
  %
  % pcount    vector with same length as lon and lat, indicating how many
  %           points were in the same cell as the lon/lat point of that index
  %
  % Last modified by plattner-at-alumni.ethz.ch, 06/20/2022

  % For testing purposes
  %showit=true;
  showit=false;

  % Create triangulate mesh
  [vMat, fMat] = spheretri(nsph);
  [phi,theta] = cart2sph(vMat(:,1), vMat(:,2), vMat(:,3));
  lonmesh = phi*180/pi;
  latmesh = theta*180/pi;
  cellnr = 1:length(fMat); % Need this because we will remove cells
  npin = nan(size(fMat,1),1); % number of points inside that cell
  whichcell = nan(length(lon),1); % cell indices for each point
  
  %% First run for -180 to 180
  lon(lon>180) = lon(lon>180) - 360;
  %leftout = 1:length(lon);% Still need to do all points
  % Remove wrap-around cells
  % identify cells with absolute lon differences greater than 180
  wraparound = max(abs(diff(lonmesh(fMat),1,2)),[],2) > 270;
  
  cellnra = cellnr(~wraparound);
  [npin, whichcell] = points2cells(lon,lat,lonmesh,latmesh,fMat,cellnra,npin,whichcell);

  % Second run for 0 to 360
  lonmesh = mod(lonmesh,360);
  lon = mod(lon,360);
  % Remove wrap around
  wraparound = max(abs(diff(lonmesh(fMat),1,2)),[],2) > 270;
  cellnrb = cellnr(~wraparound);
%%% This could be optimized by only running this over cells that weren't used before
%%% May even be quite an easy implementation, just remove those cells from 'cellnrb',
%%% which were used before
  [npin, whichcell] = points2cells(lon,lat,lonmesh,latmesh,fMat,cellnrb,npin,whichcell);

  % Now need to distribute count numbers to each point
  pcount = nan(size(lon));
  for i=1:length(pcount)
    pcount(i) = npin(whichcell(i));
  end

  
  % This is for testing purposes
  if showit
    fMatcut = fMat(~wraparound,:);
    %scatter(lon,lat,[],whichcell,'o','filled')
    scatter(lon,lat,[],pcount,'o','filled')
    hold on
    patch('Vertices',[lonmesh,latmesh],'Faces',fMat,...
          'FaceColor','none','EdgeColor','k');
    hold off
    %keyboard
  end
  
end




function [npin, whichcell] = points2cells(lon,lat,lonmesh,latmesh,fMat,cellnr,npin,whichcell)
  % Distributes the points over the cells.

  % Identify which are the pole cells
  npoleind = find(latmesh==90);
  spoleind = find(latmesh==-90);
  
  for i=cellnr
    if fMat(i,3) == npoleind || fMat(i,3) == spoleind
      longrid = [lonmesh(fMat(i,1)); lonmesh(fMat(i,2)); ...
                 lonmesh(fMat(i,2)); lonmesh(fMat(i,1))];
      latgrid = [latmesh(fMat(i,1)); latmesh(fMat(i,2)); ...
                 latmesh(fMat(i,3)); latmesh(fMat(i,3))];
      in = inpolygon(lon,lat, longrid, latgrid);
    else
      in = inpolygon(lon,lat, lonmesh(fMat(i,:)), latmesh(fMat(i,:)) );
    end
    npin(i) = sum(in);
    whichcell(in) = i;
  end

end
