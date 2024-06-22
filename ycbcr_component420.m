function [Y_420,U_420,V_420] = ycbcr_component420(I_RGB)

I_YUV=rgb2ycbcr(I_RGB);

%提取Y分量
Y=zeros(size(I_YUV),'uint8');
Y=I_YUV(:,:,1);

%提取U分量
U=zeros(size(I_YUV),'uint8');
U=I_YUV(:,:,2);

%提取V分量
V=zeros(size(I_YUV),'uint8');
V=I_YUV(:,:,3);

[imgHeight,imgWidth,imgDeep] = size(I_YUV);
Y_420=Y;

%将U，V分为2*2的块取平均,并转化为420格式
% for i=1:1080/2
%     for j=1:1920/2
%         subU=U((1+2*(i-1):2*i),(1+2*(j-1):2*j));
%         subV=V((1+2*(i-1):2*i),(1+2*(j-1):2*j));
%         U_420(i,j)=uint8(mean(subU(:)));
%         V_420(i,j)=uint8(mean(subV(:)));
%     end
% end

fun=@(block_struct) uint8(mean2(block_struct.data));
U_420=blockproc(U,[2,2],fun);
V_420=blockproc(V,[2,2],fun);
Y_420=Y;
end