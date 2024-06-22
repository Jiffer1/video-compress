function frame=ycbcr2frame(Y_420,U_420,V_420)
[YH,YL] = size(Y_420);
[CbH,CbL] = size(U_420);
y = uint8(Y_420);
cb = zeros(YH,YL);
cr = zeros(YH,YL);
for i=1:CbH
    for j=1:CbL
        [cb(2*i,2*j),cb(2*i-1,2*j),cb(2*i,2*j-1),cb(2*i-1,2*j-1)] = deal(U_420(i,j)); %每一个值都要填充一个2×2的小块
        [cr(2*i,2*j),cr(2*i-1,2*j),cr(2*i,2*j-1),cr(2*i-1,2*j-1)] = deal(V_420(i,j));
    end
end
cb = uint8(cb);
cr = uint8(cr);
frame= cat(3,y,cb,cr);
frame=ycbcr2rgb(frame);
end