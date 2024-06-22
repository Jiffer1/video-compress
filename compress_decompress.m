clc;clear all;close all;

v=VideoReader('dog.mp4');
% v=VideoReader('yundongmubiao.avi');
numFrames=v.NumFrames;
Image=cell(1,numFrames);

for i=1:numFrames
    Image{i}=read(v,i);
    % saveName=['Frame_in\',num2str(i), '.bmp'];
    % imwrite(Image{i},saveName);
    saveName=['Frame_in2\',num2str(i), '.bmp'];
    imwrite(Image{i},saveName);
end

Y=4;  %相邻I帧间隔
%确定I帧位置
I_location = 1;

for i=1:numFrames
    frame = Image{i};
    frameI = Image{I_location};
    if ~(mod(i-1,Y)) %确定I帧位置
        if i+Y<numFrames
            I_location=i+Y;
        else
            I_location=i;
        end
        %I帧进行压缩
        [dcencode_Y,dcencode_U,dcencode_V,...
         acencode_Y,acencode_U,acencode_V,...
         dcdict_Y,acdict_Y,...
         dcdict_U,acdict_U,...
         dcdict_V,acdict_V]=IFrames_compress(Image{I_location});
        saveName=strcat('compressed_image\comp_yundong',num2str(i),'.mat');
        save(saveName,"dcencode_Y","dcencode_U","dcencode_V",...
         "acencode_Y","acencode_U","acencode_V",...
         "dcdict_Y","acdict_Y",...
         "dcdict_U","acdict_U",...
         "dcdict_V","acdict_V");
        %I帧解压缩
        Image_rec{i}=I_decompress(dcencode_Y,dcencode_U,dcencode_V,...
                           acencode_Y,acencode_U,acencode_V,...
                           dcdict_Y,acdict_Y,...
                           dcdict_U,acdict_U,...
                           dcdict_V,acdict_V);
        i
        PSNR(i)=0;
    else
        %P帧进行压缩
        [dcencode_Y,dcencode_U,dcencode_V,...
         acencode_Y,acencode_U,acencode_V,...
         dcdict_Y,acdict_Y,...
         dcdict_U,acdict_U,...
         dcdict_V,acdict_V,motionvect,psnr]=PFrames_compress(Image{i},Image_rec{i-1});
        saveName=strcat('compressed_image\comp_yundong',num2str(i),'.mat');
        save(saveName,"dcencode_Y","dcencode_U","dcencode_V",...
         "acencode_Y","acencode_U","acencode_V",...
         "dcdict_Y","acdict_Y",...
         "dcdict_U","acdict_U",...
         "dcdict_V","acdict_V");
        %P帧解压缩
        Image_rec{i}=P_decompress(dcencode_Y,dcencode_U,dcencode_V,...
                           acencode_Y,acencode_U,acencode_V,...
                           dcdict_Y,acdict_Y,...
                           dcdict_U,acdict_U,...
                           dcdict_V,acdict_V,motionvect,Image_rec{i-1});


       i
       PSNR(i)=psnr; 
    end
end


folder='F:\video compress';
cd(folder);
vidobj=VideoWriter('yundongmubiao_out');
vidobj.FrameRate=20;
open(vidobj);
for i=1:numFrames
    writeVideo(vidobj,Image_rec{i});
end

%画图
PSNR(PSNR==0)=[];
plot(PSNR);

