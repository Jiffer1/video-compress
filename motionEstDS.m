% Computes motion vectors using Diamond Search method
%
% Based on the paper by Shan Zhu, and Kai-Kuang Ma
% IEEE Trans. on Image Processing
% Volume 9, Number 2, February 2000 :  Pages 287:290
%
% Input
%   imgP : The image for which we want to find motion vectors
%   imgI : The reference image
%
% Ouput
%   motionVect : the motion vectors for each integral macroblock in imgP
%   residue : residual image



function [motionVect,img_predict,psnr]= motionEstDS(img_target, img_anchor)
tic
mbSize=8;   %   mbSize : Size of the macroblock
p=7;        %   p : Search parameter  (read literature to find what this means)
[row col] = size(img_anchor);

vectors = zeros(2,row*col/mbSize^2);
costs = ones(1, 9) * 65537;


% The index points for Large Diamond search pattern
LDSP(1,:) = [ 0 -2];
LDSP(2,:) = [-1 -1]; 
LDSP(3,:) = [ 1 -1];
LDSP(4,:) = [-2  0];
LDSP(5,:) = [ 0  0];
LDSP(6,:) = [ 2  0];
LDSP(7,:) = [-1  1];
LDSP(8,:) = [ 1  1];
LDSP(9,:) = [ 0  2];

% The index points for Small Diamond search pattern
SDSP(1,:) = [ 0 -1];
SDSP(2,:) = [-1  0];
SDSP(3,:) = [ 0  0];
SDSP(4,:) = [ 1  0];
SDSP(5,:) = [ 0  1];


% we start off from the top left of the image
% we will walk in steps of mbSize
% for every marcoblock that we look at we will look for
% a close match p pixels on the left, right, top and bottom of it

computations = 0
residue=img_target-img_anchor;
fun=@(block_struct) sum(block_struct.data(:));
residue_sum=blockproc(residue,[8,8],fun);
%[block_row,block_col]=size(residue_sum);

% %寻找需要运动估计的块
% for i=1:block_row
%     for j=1:block_col
%         if residue_sum(i,j)>150;
%             motionblock_pointer=[motionblock_pointer;[i,j]];
%         end
%     end
% end

mbCount = 1;
for i = 1 : mbSize : row-mbSize+1
    for j = 1 : mbSize : col-mbSize+1
        if residue_sum(1+floor(i/8),1+floor(i/7))>100 %如果残差很大，使用运动估计
            % the Diamond search starts
            % we are scanning in raster order
        
            x = j;
            y = i;
        
            costs(5) = costFuncMAD(img_target(i:i+mbSize-1,j:j+mbSize-1), ...
                                    img_anchor(i:i+mbSize-1,j:j+mbSize-1),mbSize);
            computations = computations + 1;
        
            % This is the first search so we evaluate all the 9 points in LDSP
            for k = 1:9
                refBlkVer = y + LDSP(k,2);   % row/Vert co-ordinate for ref block
                refBlkHor = x + LDSP(k,1);   % col/Horizontal co-ordinate
                if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                    || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                    continue;
                end

                if (k == 5)
                    continue
                end
                costs(k) = costFuncMAD(img_target(i:i+mbSize-1,j:j+mbSize-1),  ...
                  img_anchor(refBlkVer:refBlkVer+mbSize-1, refBlkHor:refBlkHor+mbSize-1), mbSize);
                computations = computations + 1;
            end
        
            [cost, point] = min(costs);
        
        
            % The SDSPFlag is set to 1 when the minimum
            % is at the center of the diamond           
        
            if (point == 5)
                SDSPFlag = 1;
            else
                SDSPFlag = 0;
                if ( abs(LDSP(point,1)) == abs(LDSP(point,2)) )
                    cornerFlag = 0;
                else
                    cornerFlag = 1; % the x and y co-ordinates not equal on corners
                end
                xLast = x;
                yLast = y;
                x = x + LDSP(point, 1);
                y = y + LDSP(point, 2);
                costs = ones(1,9) * 65537;
                costs(5) = cost;
            end
        
           
            while (SDSPFlag == 0)
                if (cornerFlag == 1)
                    for k = 1:9
                        refBlkVer = y + LDSP(k,2);   % row/Vert co-ordinate for ref block
                        refBlkHor = x + LDSP(k,1);   % col/Horizontal co-ordinate
                        if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                            || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                            continue;
                        end

                        if (k == 5)
                            continue
                        end
            
                        if ( refBlkHor >= xLast - 1  && refBlkHor <= xLast + 1 ...
                                && refBlkVer >= yLast - 1  && refBlkVer <= yLast + 1 )
                            continue;
                        elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                            || refBlkVer > i+p)
                            continue;
                        else
                            costs(k) = costFuncMAD(img_target(i:i+mbSize-1,j:j+mbSize-1), ...
                                       img_anchor(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                            computations = computations + 1;
                        end
                    end
                
                else
                    switch point
                        case 2
                            refBlkVer = y + LDSP(1,2);   % row/Vert co-ordinate for ref block
                            refBlkHor = x + LDSP(1,1);   % col/Horizontal co-ordinate
                            if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                                || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                                % do nothing, outside image boundary
                            elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                                || refBlkVer > i+p)
                                % do nothing, outside search window
                            else 
                                costs(1) = costFuncMAD(img_target(i:i+mbSize-1,j:j+mbSize-1), ...
                                       img_anchor(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                                computations = computations + 1;
                            end
                                   
                            refBlkVer = y + LDSP(2,2);   % row/Vert co-ordinate for ref block
                            refBlkHor = x + LDSP(2,1);   % col/Horizontal co-ordinate
                            if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                                || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                                % do nothing, outside image boundary
                            elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                                || refBlkVer > i+p)
                                % do nothing, outside search window
                            else
                         
                                costs(2) = costFuncMAD(img_target(i:i+mbSize-1,j:j+mbSize-1), ...
                                       img_anchor(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                                    computations = computations + 1;
                            end
                        
                            refBlkVer = y + LDSP(4,2);   % row/Vert co-ordinate for ref block
                            refBlkHor = x + LDSP(4,1);   % col/Horizontal co-ordinate
                            if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                                || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                                % do nothing, outside image boundary
                            elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                                || refBlkVer > i+p)
                                % do nothing, outside search window
                            else
                         
                                costs(4) = costFuncMAD(img_target(i:i+mbSize-1,j:j+mbSize-1), ...
                                       img_anchor(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                                computations = computations + 1;
                            end
                     
                        case 3
                            refBlkVer = y + LDSP(1,2);   % row/Vert co-ordinate for ref block
                            refBlkHor = x + LDSP(1,1);   % col/Horizontal co-ordinate
                            if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                                || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                                % do nothing, outside image boundary
                            elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                                || refBlkVer > i+p)
                                % do nothing, outside search window
                            else
                         
                                costs(1) = costFuncMAD(img_target(i:i+mbSize-1,j:j+mbSize-1), ...
                                       img_anchor(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                                computations = computations + 1;
                            end
                                   
                            refBlkVer = y + LDSP(3,2);   % row/Vert co-ordinate for ref block
                            refBlkHor = x + LDSP(3,1);   % col/Horizontal co-ordinate
                            if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                                || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                            % do nothing, outside image boundary
                            elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                                || refBlkVer > i+p)
                            % do nothing, outside search window
                            else
                            
                                costs(3) = costFuncMAD(img_target(i:i+mbSize-1,j:j+mbSize-1), ...
                                       img_anchor(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                                computations = computations + 1;
                            end
                        
                            refBlkVer = y + LDSP(6,2);   % row/Vert co-ordinate for ref block
                            refBlkHor = x + LDSP(6,1);   % col/Horizontal co-ordinate
                            if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                                || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                                % do nothing, outside image boundary
                            elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                                || refBlkVer > i+p)
                                % do nothing, outside search window
                            else
                             
                                costs(6) = costFuncMAD(img_target(i:i+mbSize-1,j:j+mbSize-1), ...
                                       img_anchor(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                                computations = computations + 1;
                            end
                        
                        
                        case 7
                            refBlkVer = y + LDSP(4,2);   % row/Vert co-ordinate for ref block
                            refBlkHor = x + LDSP(4,1);   % col/Horizontal co-ordinate
                            if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                                || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                                % do nothing, outside image boundary
                            elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                                || refBlkVer > i+p)
                                % do nothing, outside search window
                            
                            else 
                                costs(4) = costFuncMAD(img_target(i:i+mbSize-1,j:j+mbSize-1), ...
                                       img_anchor(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                                computations = computations + 1;
                            end
                                   
                            refBlkVer = y + LDSP(7,2);   % row/Vert co-ordinate for ref block
                            refBlkHor = x + LDSP(7,1);   % col/Horizontal co-ordinate
                            if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                                || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                                % do nothing, outside image boundary
                            elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                                || refBlkVer > i+p)
                                % do nothing, outside search window
                            
                            else 
                                costs(7) = costFuncMAD(img_target(i:i+mbSize-1,j:j+mbSize-1), ...
                                       img_anchor(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                                computations = computations + 1;
                            end
                        
                            refBlkVer = y + LDSP(9,2);   % row/Vert co-ordinate for ref block
                            refBlkHor = x + LDSP(9,1);   % col/Horizontal co-ordinate
                            if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                                || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                                % do nothing, outside image boundary
                            elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                                || refBlkVer > i+p)
                                % do nothing, outside search window
                            
                            else 
                                costs(9) = costFuncMAD(img_target(i:i+mbSize-1,j:j+mbSize-1), ...
                                       img_anchor(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                                computations = computations + 1;
                            end
                        
                    
                        case 8
                            refBlkVer = y + LDSP(6,2);   % row/Vert co-ordinate for ref block
                            refBlkHor = x + LDSP(6,1);   % col/Horizontal co-ordinate
                            if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                                || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                                % do nothing, outside image boundary
                            elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                                || refBlkVer > i+p)
                                % do nothing, outside search window
                            
                            else 
                                costs(6) = costFuncMAD(img_target(i:i+mbSize-1,j:j+mbSize-1), ...
                                       img_anchor(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                                computations = computations + 1;
                            end
                                   
                            refBlkVer = y + LDSP(8,2);   % row/Vert co-ordinate for ref block
                            refBlkHor = x + LDSP(8,1);   % col/Horizontal co-ordinate
                            if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                                || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                                % do nothing, outside image boundary
                            elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                                || refBlkVer > i+p)
                                % do nothing, outside search window
                            
                            else 
                                costs(8) = costFuncMAD(img_target(i:i+mbSize-1,j:j+mbSize-1), ...
                                       img_anchor(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                           computations = computations + 1;
                            end
                        
                            refBlkVer = y + LDSP(9,2);   % row/Vert co-ordinate for ref block
                            refBlkHor = x + LDSP(9,1);   % col/Horizontal co-ordinate
                            if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                                || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                                % do nothing, outside image boundary
                            elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                                || refBlkVer > i+p)
                                % do nothing, outside search window
                            
                            else 
                                costs(9) = costFuncMAD(img_target(i:i+mbSize-1,j:j+mbSize-1), ...
                                       img_anchor(refBlkVer:refBlkVer+mbSize-1, ...
                                          refBlkHor:refBlkHor+mbSize-1), mbSize);
                             computations = computations + 1;
                            end
                        otherwise
                    end
                end
            
                [cost, point] = min(costs);
           
                if (point == 5)
                    SDSPFlag = 1;
                else
                    SDSPFlag = 0;
                    if ( abs(LDSP(point,1)) == abs(LDSP(point,2)) )
                        cornerFlag = 0;
                    else
                        cornerFlag = 1;
                    end
                    xLast = x;
                    yLast = y;
                    x = x + LDSP(point, 1);
                    y = y + LDSP(point, 2);
                    costs = ones(1,9) * 65537;
                    costs(5) = cost;
                end
            
            end  % while loop ends here
        
            % we now enter the SDSP calculation domain
            costs = ones(1,5) * 65537;
            costs(3) = cost;
        
            for k = 1:5
                refBlkVer = y + SDSP(k,2);   % row/Vert co-ordinate for ref block
                refBlkHor = x + SDSP(k,1);   % col/Horizontal co-ordinate
                if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                    || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                    continue; % do nothing, outside image boundary
                elseif (refBlkHor < j-p || refBlkHor > j+p || refBlkVer < i-p ...
                            || refBlkVer > i+p)
                    continue;   % do nothing, outside search window
                end

                if (k == 3)
                    continue
                end
            
                costs(k) = costFuncMAD(img_target(i:i+mbSize-1,j:j+mbSize-1), ...
                              img_anchor(refBlkVer:refBlkVer+mbSize-1, ...
                                  refBlkHor:refBlkHor+mbSize-1), mbSize);
                computations = computations + 1;
                   
            end
         
            [cost, point] = min(costs);
        
            x = x + SDSP(point, 1);
            y = y + SDSP(point, 2);
            vectors(1,mbCount) = y - i;    % row co-ordinate for the vector
            vectors(2,mbCount) = x - j;    % col co-ordinate for the vector
            img_predict(i:i+mbSize-1,j:j+mbSize-1)=img_anchor(y:y+mbSize-1,x:x+mbSize-1);
            mbCount = mbCount + 1;
            costs = ones(1,9) * 65537;
        else  %残差在可接受的范围，不使用运动估计
            vectors(1,mbCount)= -1;
            vectors(2,mbCount)= -1;
            img_predict(i:i+mbSize-1,j:j+mbSize-1)=img_anchor(i:i+mbSize-1,j:j+mbSize-1);
            mbCount = mbCount + 1;
            costs = ones(1,9) * 65537;
        end
    end
end
    
motionVect = vectors;
% residue=img_target-img_predict;
%DScomputations = computations/(mbCount - 1);
psnr=imgPSNR(img_target,img_predict);    

toc
    
