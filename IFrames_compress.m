function [DCencode_Y,DCencode_U,DCencode_V,...
    ACencode_Y,ACencode_U,ACencode_V,...
    dcdict_Y,acdict_Y,...
    dcdict_U,acdict_U,...
    dcdict_V,acdict_V] = IFrames_compress(frame);
[Y_420,U_420,V_420]=ycbcr_component420(frame);

%量化表
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

[DCencode_Y,ACencode_Y,dcdict_Y,acdict_Y]=compress(Y_quantization);
[DCencode_U,ACencode_U,dcdict_U,acdict_U]=compress(U_quantization);
[DCencode_V,ACencode_V,dcdict_V,acdict_V]=compress(V_quantization);