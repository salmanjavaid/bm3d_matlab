clear all; clc;

I = imread('1.bmp');
start_row = 1;
start_col = 1;
end_row = 32;
end_col = 32;
lev = 5;
block_size = 32;
no_of_blocks = 8;
patch_ = I(start_row:end_row, start_col:end_col);

x = im2col(patch_, [8 8], 'sliding');
yd = zeros(size(x, 1), size(x, 2));
distance = zeros(1, size(x, 2));


for i = 1: size(x, 2)
    yd(:, i) = wden(x(:, i),'sqtwolog','s','sln',lev,'sym8');    
    clc;
end

for i = 2: size(x, 2)
    distance(:, i) = norm(yd(:, 1) - yd(:, i), 2)/64;    
end




j = 1;