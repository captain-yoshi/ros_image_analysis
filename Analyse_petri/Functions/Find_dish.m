function [im_crop, im_gray_crop, mask_org, mask_crop, r, center] = Find_dish(image,...
    polarity, radius_range, scan_sens, scale, r_scale, disp_fig)
%Find and isolate petri dish

%-------------------------------------------------------------------------%
%------------------------------Parameters---------------------------------%
%-------------------------------------------------------------------------%
% polarity            Object color 'bright' or 'dark'
% radius_range        Range of radius of petri dish (in pixel)
% scan_sens           Sensibility of scan        
% scale               Scaling factor on image 
% r_scale             Scaling factor on radius
% disp_fig            Bool to display images



%-------------------------------------------------------------------------%
%----------------------Transform image into grayscale---------------------%
%-------------------------------------------------------------------------%
% Adjust parameters to scaling factor
radius_range = ceil(radius_range*scale);


% Scale image
im_scale = imresize(image,scale);

% Gray scale
im_gray_scale = rgb2gray(im_scale);
%-------------------------------------------------------------------------%
%----------------------------Ajust contrast-------------------------------%
%-------------------------------------------------------------------------%
im_adj = imadjust(im_gray_scale);

if disp_fig
    figure
    imshow(im_adj)
end

%-------------------------------------------------------------------------%
%-----------------------Find circles of petri dish------------------------%
%-------------------------------------------------------------------------%
[centers, radii] = imfindcircles(im_adj,radius_range,'sensitivity',...
    scan_sens,'ObjectPolarity',polarity);
if disp_fig
    viscircles(centers, radii,'EdgeColor','r','LineStyle','--');
end

if isempty(radii)
    disp('No circle detected!')
    %Return empty arrays
    im_crop = [];
    im_gray_crop =[];
    mask_crop =[];
    r = [];
    return
end
%-------------------------------------------------------------------------%
%-----------------choose the smallest circle (if more than one)-----------%
%-------------------------------------------------------------------------%
[~,I] = min(radii);
%-------------------------------------------------------------------------%
%---------------------------Make cicular mask-----------------------------%
%-------------------------------------------------------------------------%
inv_scale = 1/scale;
c_x     = round(inv_scale*centers(I,1));
c_y     = round(inv_scale*centers(I,2));
max_x   = size(image,2);
max_y   = size(image,1);
r       = round(inv_scale*radii(I)*r_scale);
[x,y]   = meshgrid(-(c_x-1):(max_x-c_x),-(c_y-1):(max_y-c_y));
mask_org  = ((x.^2+y.^2)<=r^2);

center = [c_x c_y];

%-------------------------------------------------------------------------%
%------------------------------Crop image---------------------------------%
%-------------------------------------------------------------------------%
ymin = c_y-r;
ymax = c_y+r;
xmin = c_x-r;
xmax = c_x+r;
% Gray image
im_gray = rgb2gray(image);
im_gray_crop = im_gray(ymin:ymax, xmin:xmax);
% Color image 
im_crop = image(ymin:ymax, xmin:xmax,:);
% New mask
mask_crop = mask_org(ymin:ymax, xmin:xmax);

if disp_fig
    msk_rgb = uint8(repmat(mask_crop,[1 1 3]));
    figure
    imshow(im_crop .* msk_rgb)
end





