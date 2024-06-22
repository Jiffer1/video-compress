function frame=I_decompress(dcencode_Y,dcencode_U,dcencode_V,...
                           acencode_Y,acencode_U,acencode_V,...
                           dcdict_Y,acdict_Y,...
                           dcdict_U,acdict_U,...
                           dcdict_V,acdict_V)

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
 % Q_luminance=int8(Q_luminance);
 % Q_chrominance=int8(Q_chrominance);

% height=2048;weight=2592;
height=720;weight=1280;
Y_quantization=decompress(dcencode_Y,acencode_Y,dcdict_Y,acdict_Y,height,weight);
% height=1024;weight=1296;
height=360;weight=640;
U_quantization=decompress(dcencode_U,acencode_U,dcdict_U,acdict_U,height,weight);
% height=1024;weight=1296;
height=360;weight=640;
V_quantization=decompress(dcencode_V,acencode_V,dcdict_V,acdict_V,height,weight);

Y_quantization=double(Y_quantization);
U_quantization=double(U_quantization);
V_quantization=double(V_quantization);

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

frame=ycbcr2frame(Y_420,U_420,V_420);
end
