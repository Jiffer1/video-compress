function image=decompress(dcencode,acencode,dcdict,acdict,height,weight)

%反z字形扫描顺序
reorder=[1 3 4 10 11 21 22 36 ...
2 5 9 12 20 23 35 37 ...
6 8 13 19 24 34 38 49 ...
7 14 18 25 33 39 48 50 ...
15 17 26 32 40 47 51 58 ...
16 27 31 41 46 52 57 59 ...
28 30 42 45 53 56 60 63 ...
29 43 44 54 55 61 62 64];

%直流解码
dcdecode=double(huffmandeco(double(dcencode),dcdict));
[num_col,~]=size(dcdecode);
%根据直流解码恢复直流分量，并放入TCM_Q_colZ_Rec的第一行
Q_colZ_Rec(1,1)=dcdecode(1);
for i=2:num_col
    Q_colZ_Rec(1,i)=Q_colZ_Rec(1,i-1)+dcdecode(i);
end
dc=Q_colZ_Rec;

%交流解码
acdecode=double(huffmandeco(double(acencode),acdict));
[~,size_rlctable]=size(acdecode);
size_rlctable=size_rlctable/2;
rlc_table=reshape(acdecode,size_rlctable,2);
ac_vec=zeros(1,63*num_col);
j=1;
for i=1:size_rlctable
    if(rlc_table(i,1)==0)
        ac_vec(j)=rlc_table(i,2);
        j=j+1;
    else
        for k=1:rlc_table(i,1)
            ac_vec(j)=0;
            j=j+1;
        end
    ac_vec(j)=rlc_table(i,2); 
    j=j+1;
    end
end
ac=reshape(ac_vec,63,num_col);

Q_col=[dc;ac];

Q_col_invz=Q_col(reorder,:);
image=col2im(Q_col_invz,[8,8],[height,weight],'distinct');
image=int8(image);
end
