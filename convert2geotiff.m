% This script is developed for reprojecting the raster (transformation in latitude) 
% to standard geographical reference system
% Code by : Kun Zhang, ITPCAS, Beijing
% Date : 2020/12/2
function [target_raster, R] = convert2geotiff(input_data,lat_ori,lon_ori,outname)
% input_data : the original raster need to be reprojected
% lat_ori    : the original latitude
% lon_ori    : the original longitude
% outname    : the output geotiff file
% ---

% define a target georaster (0.25 at global)
[M, N] = size(input_data); 
Lim_lat = [min(lat_ori), max(lat_ori)]; 
Lim_lon = [min(lon_ori), max(lon_ori)]; 


% define a georaster reference
R = georasterref('RasterSize', [M N], ...
    'ColumnsStartFrom', 'north', 'Latlim', Lim_lat, ...
    'Lonlim', Lim_lon); % set the georeference

% construct target raster
spa_res_lat = R.CellExtentInLatitude;
spa_res_lon = R.CellExtentInLongitude;

x1 = spa_res_lat / 2 + Lim_lat(1);
x2 = Lim_lat(2) - spa_res_lat / 2;

y1 = spa_res_lon / 2 + Lim_lon(1);
y2 = Lim_lon(2) - spa_res_lon / 2;

lat_tar = rot90(x1:spa_res_lat:x2);
lon_tar = y1:spa_res_lon:y2;

target_raster = nan(M,N);

input_data = double(input_data);
textprogressbar('Processing :: ');

for i = 1 : length(lat_ori)
    
    lat_i = lat_ori(i);
    
    % find the latitude location in the target raster
    xx = abs(lat_i - lat_tar);
    [p1, ~] = find(xx == min(xx)); % lat loc
    
    if length(p1) > 1 
        p1 = p1(1); 
    end
    
    fg = target_raster(p1, :);
    
    fa = [fg; input_data(i, :)];
    target_raster(p1, :) = mean(fa,1,'omitnan');

    textprogressbar(100*(i/length(lat_ori)));
end
textprogressbar(' Done'); 

% write to selected path as a geotiff file
disp('Write to geotiff ... ')
geotiffwrite(outname, target_raster, R);

end

function textprogressbar(c)

% Initialization
persistent strCR;           %   Carriage return pesistent variable

% Vizualization parameters
strPercentageLength = 10;   %   Length of percentage string (must be >5)
strDotsMaximum      = 10;   %   The total number of dots in a progress bar

% Main 
if isempty(strCR) && ~ischar(c)
    % Progress bar must be initialized with a string
    error('The text progress must be initialized with a string');
elseif isempty(strCR) && ischar(c)
    % Progress bar - initialization
    fprintf('%s',c);
    strCR = -1;
elseif ~isempty(strCR) && ischar(c)
    % Progress bar  - termination
    strCR = [];  
    fprintf([c '\n']);
elseif isnumeric(c)
    % Progress bar - normal progress
    c = floor(c);
    percentageOut = [num2str(c) '%%'];
    percentageOut = [percentageOut repmat(' ',1,strPercentageLength-length(percentageOut)-1)];
    nDots = floor(c/100*strDotsMaximum);
    dotOut = ['[' repmat('.',1,nDots) repmat(' ',1,strDotsMaximum-nDots) ']'];
    strOut = [percentageOut dotOut];
    
    % Print it on the screen
    if strCR == -1
        % Don't do carriage return during first run
        fprintf(strOut);
    else
        % Do it during all the other runs
        fprintf([strCR strOut]);
    end
    
    % Update carriage return
    strCR = repmat('\b',1,length(strOut)-1);
    
else
    % Any other unexpected input
    error('Unsupported argument type');
end

end







