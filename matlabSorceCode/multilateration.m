function[x_approx,y_approx,stddevinfo] = multilateration(nearnodes,dist,database_pos)
stddev=1;
stddevinfo = create_stddev_cell();
stddevinfo(1,2:5)=num2cell(nearnodes');
%fprintf('Four nearest nodes within range : %s \n',num2str(nearnodes'));

combxy = nchoosek(nearnodes,3);
stddevinfo(3:6,1:3)=num2cell(combxy);

combdist = nchoosek(dist,3);
temp3=zeros(4,2);
for j=1:4
    [temp3(j,1),temp3(j,2)]=trilateration(combxy(j,:),combdist(j,:),database_pos);
end
temp3=round(temp3,2);
stddevinfo(3:6,4:5)=num2cell(temp3);
tempx=temp3(:,1);
tempy=temp3(:,2);

%---standard deviation---%
stddevmat = std(temp3); %calculating std. deviation
stddevinfo(7,4:5)=num2cell(stddevmat);  %for updating database

if numel(unique(tempx))==3 || numel(unique(tempx))==2 || numel(unique(tempx))==1   %if one of four x_approx values in approx is repeated
    %fprintf('>>values repeated in tempx.\n');
    [temp1,temp2]=unique(tempx); %#ok<*ASGLU>
    temp2=setxor(temp2,1:numel(tempx));
    x_approx=tempx(temp2); %x_approx=repeated value
    if numel(x_approx)==2 || numel(x_approx)==3
        %fprintf('>>numel(x_approx)==2||numel(x_approx)==3 \n');
        x_approx=mean(tempx,'omitnan');
    end
    stddevinfo(12,5)=num2cell(x_approx);
else
    combx=nchoosek(tempx,3);    %get all possible 3 values combinations in 4 given values
    combx=round(combx,2);
    stddevinfo(9:12,1:3)=num2cell(combx);
    combxstd = std(combx,0,2);  %row-wise std  dev
    combxstd = round(combxstd,2);
    stddevinfo(9:12,4)=num2cell(combxstd);
        
    if numel(unique(combxstd))==4 || (numel(unique(combxstd))==2 || numel(unique(combxstd))==3)     %no values repeated in combxstd
        if numel(unique(combxstd))==4
            %fprintf('>>no values repeated in combxstd.\n');
        elseif (numel(unique(combxstd))==2 || numel(unique(combxstd))==3)
            %fprintf('>>values repeated in combxstd.\n');
        end
        if min(combxstd) > stddev
            %fprintf('>>min std dev for combxstd is high.\n');
            tempx=combx(combxstd == min(combxstd),:);
            if size(tempx,1)>1
                %fprintf('>>min std dev for combxstd is repeated.\n');
                temp1=zeros(size(tempx,1),2);
                for temp2=1:size(temp1,1)
                    combx=nchoosek(tempx(temp2,:),2);
                    combxstd = std(combx,0,2);
                    temp1(temp2,1)=min(combxstd);
                    temp1(temp2,2)=mean(combx(combxstd == min(combxstd),:));
                end
                combx=temp1(:,2);
                combxstd=temp1(:,1);
                x_approx = mean(combx(combxstd == min(combxstd),:));
                stddevinfo(9:8+size(tempx,1),1:3)=num2cell(tempx);
                stddevinfo(9:8+size(tempx,1),4)=num2cell(combxstd);
                stddevinfo(9+size(tempx,1):12,1:4)={''''''''''''''''''''''''''''};
            else
                combx=nchoosek(tempx,2);
                combxstd = std(combx,0,2);
                stddevinfo(9:11,1:2)=num2cell(combx);
                stddevinfo(9:11,4)=num2cell(combxstd);
                stddevinfo(12,1:4)={''''''''''''''''''''''''''''};
                stddevinfo(9:11,3)={''''''''''''''''''''''''''''};
                x_approx = mean(combx(combxstd == min(combxstd),:));
                if min(combxstd)>2.5*stddev && stddevmat(1)>15*stddev
                    %fprintf('>>x_approx value may have high errors.\n');
                end
            end
        else
            x_approx = mean(combx(combxstd == min(combxstd),:));
        end
        if numel(x_approx)>1
            x_approx=mean(x_approx,'omitnan');
        end
    elseif numel(unique(combxstd))==1 % if all values in combxstd are same
        %fprintf('>>all values in combxstd are same.\n');
        x_approx = mean(tempx,'omitnan');
    end
    stddevinfo(8+find(combxstd == min(combxstd)),5)=num2cell(x_approx);
end

if numel(unique(tempy))==3 || numel(unique(tempy))==2 || numel(unique(tempy))==1 %if one of four y_approx values in approx is repeated
    %fprintf('>>values repeated in tempy.\n');
    [temp1,temp2]=unique(tempy);
    temp2=setxor(temp2,1:numel(tempy));
    y_approx=tempy(temp2); %y_approx=repeated value
    if numel(y_approx)==2 || numel(y_approx)==3
        %fprintf('>>numel(y_approx)==2||numel(y_approx)==3 \n');
        y_approx=mean(tempy,'omitnan');
    end
    stddevinfo(17,5)=num2cell(y_approx);
    
else
    comby = nchoosek(tempy,3);    %get all possible 3 values combinations in 4 given values
    comby=round(comby,2);
    stddevinfo(14:17,1:3)=num2cell(comby);
    combystd = std(comby,0,2);  %row-wise std  dev
    combystd = round(combystd,2);
    stddevinfo(14:17,4)=num2cell(combystd);

    if numel(unique(combystd))==4 || (numel(unique(combystd))==2 || numel(unique(combystd))==3)     %no values repeated in combystd
        if numel(unique(combystd))==4
            %fprintf('>>no values repeated in combystd.\n');
        elseif (numel(unique(combystd))==2 || numel(unique(combystd))==3)
            %fprintf('>>values repeated in combystd.\n');
        end
        if min(combystd) > stddev
            %fprintf('>>min std dev for combystd is high.\n');
            tempy=comby(combystd == min(combystd),:);
            if size(tempy,1)>1
                %fprintf('>>min std dev for combystd is repeated.\n');
                temp1=zeros(size(tempy,1),2);
                for temp2=1:size(temp1,1)
                    comby=nchoosek(tempy(temp2,:),2);
                    combystd = std(comby,0,2);
                    temp1(temp2,1)=min(combystd);
                    if numel(nonzeros(combystd == min(combystd)))>1
                        for j=1:numel(combystd)
                           if combystd(j) == min(combystd)
                              temp1(temp2,2)=comby(j);
                              break;
                           end
                        end
                    else
                        temp1(temp2,2)=mean(comby(combystd == min(combystd),:));
                    end
                end
                comby=temp1(:,2);
                combystd=temp1(:,1);
                y_approx = mean(comby(combystd == min(combystd),:));
                stddevinfo(14:13+size(tempy,1),1:3)=num2cell(tempy);
                stddevinfo(14:13+size(tempy,1),4)=num2cell(combystd);
                stddevinfo(14+size(tempx,1):17,1:4)={''''''''''''''''''''''''''''};
            else
                comby=nchoosek(tempy,2);
                combystd = std(comby,0,2);
                stddevinfo(14:16,1:2)=num2cell(comby);
                stddevinfo(14:16,4)=num2cell(combystd);
                stddevinfo(17,1:4)={''''''''''''''''''''''''''''};
                stddevinfo(14:16,3)={''''''''''''''''''''''''''''};
                y_approx = mean(comby(combystd == min(combystd),:));
                if min(combystd)>2.5*stddev  && stddevmat(2)>15*stddev
                    %fprintf('>>y_approx value may have high errors.\n');
                end
            end
        else
            y_approx = mean(comby(combystd == min(combystd),:));
        end
        if numel(y_approx)>1
            y_approx=mean(y_approx,'omitnan');
        end
    elseif numel(unique(combystd))==1 % if all values in combystd are same
        %fprintf('>>all values in combystd are same.\n');
        y_approx = mean(tempy,'omitnan');
    end
    stddevinfo(13+find(combystd == min(combystd)),5)=num2cell(y_approx);
end
x_approx=round(x_approx,2);
y_approx=round(y_approx,2);
end
