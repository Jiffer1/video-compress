
for i=1:185
    saveName=['Frame_in\',num2str(i), '.bmp'];
    image{i}=imread(saveName);
end

Q_luminance=[16, 11, 10, 16, 24, 40, 51, 61;
             12, 12, 14, 19, 26, 58, 60, 55;
             14, 13, 16, 24, 40, 57, 69, 56;
             14, 17, 22, 29, 51, 87, 80, 62;
             18, 22, 37, 56, 68, 109, 103, 77;
             24, 35, 55, 64, 81, 104, 113, 92;
             49, 64, 78, 87, 103, 121, 120, 101;
             72, 92, 95, 98, 112, 100, 103, 99;];

Q_chrominance=[17, 18, 24, 47, 99, 99, 99, 99;
               18, 21, 26, 66, 99, 99, 99, 99;
               24, 26, 56, 99, 99, 99, 99, 99;
               47, 66, 99, 99, 99, 99, 99, 99;
               99, 99, 99, 99, 99, 99, 99, 99;
               99, 99, 99, 99, 99, 99, 99, 99;
               99, 99, 99, 99, 99, 99, 99, 99;
               99, 99, 99, 99, 99, 99, 99, 99;];
for i=1:185
    [Y_420,U_420,V_420]=ycbcr_component420(image{i});


%对图像Y、U、V分别进行DCT变换和量化
f1=@(block_struct) dct2(block_struct.data);
f2=@(block_struct) round(block_struct.data./Q_luminance);
f3=@(block_struct) round(block_struct.data./Q_chrominance);
Y_dct=blockproc(Y_420,[8,8],f1);
Y_quantization=blockproc(Y_dct,[8,8],f2);
U_dct=blockproc(U_420,[8,8],f1);
U_quantization=blockproc(U_dct,[8,8],f3);
V_dct=blockproc(V_420,[8,8],f1);
V_quantization=blockproc(V_dct,[8,8],f3);

f1=@(block_struct) uint8(idct2(block_struct.data));
f2=@(block_struct) round(block_struct.data.*Q_luminance);
f3=@(block_struct) round(block_struct.data.*Q_chrominance);

Y_dct=blockproc(Y_quantization,[8,8],f2);
Y_420=blockproc(Y_dct,[8,8],f1);
U_dct=blockproc(U_quantization,[8,8],f3);
U_420=blockproc(U_dct,[8,8],f1);
V_dct=blockproc(V_quantization,[8,8],f3);
V_420=blockproc(V_dct,[8,8],f1);
% Y_420=uint8(Y_420);
% U_420=uint8(U_420);
% V_420=uint8(V_420);

image{i}=ycbcr2frame(Y_420,U_420,V_420);
i
end


folder='F:\video compress';
cd(folder);
vidobj=VideoWriter('yundongmubiao_out1');
vidobj.FrameRate=20;
open(vidobj);
for i=1:185
    writeVideo(vidobj,image{i});
end
