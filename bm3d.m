

function [j] = bm3d()
clear all; clc;
I = imread('1.bmp'); %read an image
% currently processing only one block
%each search block of size 32 * 32
%in each search block we select a reference block of size smaller than reference block
%and then search for our blocks similar to reference block
start_row = 1; %start from first row
start_col = 1; %start from first coulmn
end_row = 32;  %end of row
end_col = 32;  %end of column 
lev = 5; %the wavelet transform level
block_size = 32; % block size
no_of_blocks = 8; % number of blocks
block_ = I(start_row:end_row, start_col:end_col); %select first search block of size 32 * 32

x = im2col(block_, [8 8], 'sliding'); %transform the search block into 8*8 blocks
yd = zeros(size(x, 1), size(x, 2)); %used to store inverse 2d transform
distance = zeros(1, size(x, 2)); %distance used to measure difference between search and reference blocks


for i = 1: size(x, 2)
    temp = col2im(x(:, i), [1 1], [8 8]);  %convert the columns to 2d blocks of size 8*8
    yd(:, i) = im2col(denoise_2d(temp), [1 1])'; %take wavelet transform of each block, and convert it back into column
end

for i = 2: size(x, 2)
    distance(:, i) = norm(yd(:, 1) - yd(:, i), 2)/64;   %now assume our first 8*8 block currently in column form 
    %is our reference block. measure the distance between it and other
    %blocks. 
end


[sorted index] = sort(distance); %sort by distance

smallest_16 = index(1:17); %select the blocks with minimal distance

array_3d = zeros(8, 8, 16); %create a 3d array

for ind = 2: length(smallest_16)
    temp = col2im(yd(:, smallest_16(ind)), [1 1], [8 8]); %select the search blocks to use in 3d transform
    array_3d(:, :, ind - 1) = temp; %put them in a 3d array
end

array_3d = wavelet_phase_3d(array_3d, no_of_blocks); %take the 3d transform

wp_hard = zeros(16, 1); %weight of each block

for i = 1: 16
    %calculate weight of each block
    if length(find(array_3d(:, :, i) >= 1)) > 0
        wp_hard(i, :) = 1 / length(find(array_3d(:, :, i) >= 1));
    else
        wp_hard(i, :) = 1;
    end
end


j = 1;


end


function y = wavelet_phase_3d(array_3d, no_of_blocks)
    n = 3;                   % Decomposition Level
    w = 'sym4';              % Near symmetric wavelet
    WT = wavedec3(array_3d, n, w);
    threshold = sqrt(2*log(no_of_blocks.^2));
    for i = 1: length(WT.dec)
        A = WT.dec(i, :, :);
        WT.dec(i, :, :) = mat2cell(wthresh(cell2mat(A), 'h', threshold));
    end
    y = waverec3(WT);
end



function y = denoise_2d(x)    
    % find default values (see ddencmp). 
    [thr,sorh,keepapp] = ddencmp('den','wv',x);
    % de-noise image using global thresholding option. 
    y = wdencmp('gbl',x,'sym4',2,thr,sorh,keepapp);
end

