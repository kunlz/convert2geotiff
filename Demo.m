
% Demo
sn = ncread('201610.nc','snow_depth');
lat = ncread('201610.nc','latitude');
if lat(1) < lat(end)
    lat = flipud(lat);
end
lon = ncread('201610.nc','longitude');

outname = '201610.tif'; 
[target_raster, R] = covert2geotiff(sn,lat,lon,outname); 






