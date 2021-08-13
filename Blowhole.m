clc; clear; close all

% Keep number of wrong detection in W
W=0;
% Replce your path here
path_directory_img='/home/reyhane/Desktop/dataset/MT_Blowhole/Imgs';
path_directory_mask = '/home/reyhane/Desktop/dataset/MT_Blowhole/Masks';
original_files_img = dir([path_directory_img '/*.jpg']); 
original_files_mask = dir([path_directory_mask '/*.png']);
for k=1:length(original_files_img)
    
    % Load image and it's mask
    filename_img=[path_directory_img '/' original_files_img(k).name];
    filename_mask=[path_directory_mask '/' original_files_mask(k).name];
    
    I=im2double(imread(filename_img));
    Mask = im2double(imread(filename_mask)); 
    
    % Image enhancement:
    % Ia(i, j) = (I(i,j)*0.5bm) / Im(i, j)
    % where i and j denote the position of the target pixel,
    % Ia denotes the image after the correction,
    % I denotes the image before the correction,
    % Im denotes the result of applying the median filter to the image before the correction,
    % bm denotes the maximum pixel value (here is 1)
    
    Im = medfilt2(I, [41 41]);
    Ia = zeros(size(I));
    
    for i=1:size(I,1)
        for j=1:size(I,2)
            Ia(i,j) = (I(i,j)*0.5)/Im(i,j);
        end
    end

    % Thresholding image to detect defect
    T = double(Ia<=0.35);
    
    %  Median filter and morphology to remove unwanted pixels
    T = medfilt2(T, [3 3]);
    O = imclose(T, strel('disk', 7));
    O = medfilt2(O);
    
    % Count number of true detected pixels
    counter = 0;
    for i=1:size(O,1)
        for j=1:size(O,2)
            if O(i,j)==1 && Mask(i,j)==1
                counter = counter+1;
            end
        end
    end
    
    if counter==0 && sum(Mask(:))==0 && sum(O(:))<=10
        counter = 10;
    end
    
    % Show final result
    imshow([I Im Ia T O Mask])

    if counter>=10
        title("Correct")
    else
        title("Wrong")
        W = W+1;
    end

    pause();
end

% Calculate percentage of true detected images
Accuracy = (k-W)*100/k;