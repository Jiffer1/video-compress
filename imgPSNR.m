% Computes motion compensated image's PSNR
%
% Input
%   imgP : The original image 
%   imgComp : The compensated image
%   n : the peak value possible of any pixel in the images
%
% Ouput
%   psnr : The motion compensated image's PSNR
%
% Written by Aroh Barjatya

function psnr = imgPSNR(imgP, imgComp)

[row,col] = size(imgP);
n=255;
err = 0;
err=uint32(err);
imgP=int8(imgP);
imgComp=int8(imgComp);
residue=imgP-imgComp;
residue=double(residue);
for i = 1:row
    for j = 1:col
        err = err + (residue(i,j))^2;
    end
end
err=double(err);
mse = err / (row*col);
n=double(n);
psnr = 10*log10(n*n/mse);