iptsetpref('ImshowAxesVisible','on');
load('Depth.mat');
load('Image.mat');

depth = Us_image_depth;
numframes = size(US_images.signals.values,3);

% Contour plot
figure('Color', 'k');
subplot(2,2,1); title('Object Contour', 'Color', 'w'); axis off;
zlim([0.3 0.65])
hold on

% Object Coordinates
x = [];
y = [];
z = [];

for k = 54:85
    
    % Normalize depth data
    depth(k) = depth(k)/200.0;
    
    % Resize
    img(:,:,k) = imresize(US_images.signals.values(200:920,260:860,k), 0.5);
    
    % Binary transformation
    img(:,:,k) = im2bw(img(:,:,k), 0.001);
    
    % Remove small noise
    img(:,:,k) = bwareaopen(img(:,:,k), 3000);
    
    % Fill holes
    img(:,:,k) = imfill(img(:,:,k), 'holes');
    
    % Circular filter
        for i = 1:5
            img(:,:,k) = imopen(img(:,:,k), strel('disk', 40));
        end
    
    if img(:,:,k) == 0
        continue
    else

        % Median filter
        img(:,:,k) = medfilt2(img(:,:,k), [20 20]);
        
        % Plot object
        C = contour3(img(:,:,k), [depth(k) depth(k)]);
        % fprintf('%d\n', k);
        
        [a b c] = C2xyz(C);
        
        for i = 1:size(a{1}, 2)
            x = [x a{1}(i)];
            y = [y b{1}(i)];
            z = [z depth(k)];
        end
    end
end

% Get xy projection
subplot(2,2,2); title('xy - Projection', 'Color', 'w'); 
plot3(x,y,z); view(0,90); axis off;
F = getframe;
proj_xy = im2bw(F.cdata, 0.1);
proj_xy = imfill(proj_xy, 'holes');

% Median filter
proj_xy = medfilt2(proj_xy, [50 50]);

% Display projection
subplot(2,2,3); title('Projection Contour', 'Color', 'w');  
visboundaries(proj_xy); axis off;


    