function [DC_encoded,AC_encoded,dcdict,acdict]=compress(image)
%z字型读取数据顺序
order=[1 9 2 3 10 17 25 18 ...
11 4 5 12 19 26 33 41 ...
34 27 20 13 6 7 14 21 ...
28 35 42 49 57 50 43 36 ...
29 22 15 8 16 23 30 37 ...
44 51 58 59 52 45 38 31 ...
24 32 39 46 53 60 61 54 ...
47 40 48 55 62 63 56 64];

% 将每个8*8 数据块的量化系数排成列向量
Q_col=im2col(image,[8,8],'distinct');
Num_col=size(Q_col,2);

%按z字型顺序重新排列数组
Q_colz=Q_col(order,:);


%编码
%直流编码
dc=zeros(Num_col,1);
dcdpcm=zeros(Num_col,1);
%dc为直流系数表，dcdpcm为直流差值编码表

for i=1:Num_col
    dc(i)=Q_colz(1,i);  %将dc系数存入一个矢量中
end
dcdpcm(1)=dc(1);
for i=2:Num_col
    dcdpcm(i)=dc(i)-dc(i-1);  %求dcDPCM编码
end

table = tabulate(dcdpcm(:));    %统计输入中各个字符出现的概率
dc_symbols = table(:,1);        %字符保存到symbols中
dc_p = table(:,3) ./ 100;       %对应的概率保存到p中
dcdict = huffmandict(dc_symbols,dc_p);  %调用huffmandict函数生成字典
DC_encoded = huffmanenco(dcdpcm,dcdict);    %调用huffmanenco函数根据已有的字典将输入编码
DC_encoded = uint8(DC_encoded);          %默认的huffmanenco得到的comp是用double存储的，这里改为uint8节省空间

%交流编码
ac=Q_colz(2:64,:);
[m,n] = size(ac);
cnt = m*n;
ac_vec=reshape(ac,1,cnt);
zero_cnt = 0;
rlc_table = [];
for i=1:cnt
    if ac_vec(i) == 0 
        zero_cnt = zero_cnt + 1;
    else
        rlc_table = [rlc_table;[zero_cnt,ac_vec(i)]];
        zero_cnt = 0;
    end
end
if zero_cnt~=0
    rlc_table=[rlc_table;[zero_cnt-1,0]];
end
%rlc_table = [rlc_table;[0,0]];  % 表的末行为[0,0]

[m,n]=size(rlc_table);
x=reshape(rlc_table, 1, m*n);
table = tabulate(x(:));     %统计输入中各个字符出现的概率
ac_symbols = table(:,1);        %字符保存到symbols中
ac_p = table(:,3) ./ 100;       %对应的概率保存到p中
acdict = huffmandict(ac_symbols,ac_p);  %调用huffmandict函数生成字典
AC_encoded = huffmanenco(x,acdict);    %调用huffmanenco函数根据已有的字典将输入编码
AC_encoded = uint8(AC_encoded);          %默认的huffmanenco得到的comp是用double存储的，这里改为uint8节省空间

