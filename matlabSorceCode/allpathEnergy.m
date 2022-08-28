function [allpaths, allpathenergyconsume]= allpathEnergy(startpoint,endpoint,g1,g2,database_pos,Eo,datapacket,wakeuppacket)
allpaths=getpaths(g1, g2, database_pos, startpoint, endpoint);
energyRemain=Eo*ones(size(allpaths,1),1);

for i=1:size(allpaths,1)
    temp5=allpaths{i};  %loading path
    temp4=zeros(numel(temp5)-1,1);  %temp4 = distance between consecutive path nodes
    for j=1:numel(temp4)
        temp4(j,:)=(norm([database_pos(temp5(j),1) database_pos(temp5(j),2)]-[database_pos(temp5(j+1),1) database_pos(temp5(j+1),2)]));
    end
    for j=1:numel(temp5)
        if j==1 %(first node, new node itself)
            [temp1,temp2]=energyConsume(temp4(j),wakeuppacket); %wake-up receiver energy consumption
            [temp3,~]=energyConsume(temp4(j),datapacket); %data transmission energy consumption
            temp3=temp1+temp2+temp3;
            energyRemain(i)=energyRemain(i)-temp3;
        elseif j==numel(temp5)  %(last node, sink)
            [temp1,temp2]=energyConsume(temp4(j-1),wakeuppacket); %wake-up receiver energy consumption
            [~,temp3]=energyConsume(temp4(j-1),datapacket); %data reception energy consumption
            temp3=temp1+temp2+temp3;
            energyRemain(i)=energyRemain(i)-temp3;
        else   %(intermediate path nodess)
            [temp1,temp2]=energyConsume(temp4(j-1),wakeuppacket); %wake-up receiver energy consumption
            [~,temp3]=energyConsume(temp4(j-1),datapacket); %data reception energy consumption
            temp3=temp1+temp2+temp3;
            energyRemain(i)=energyRemain(i)-temp3;
            
            [temp1,temp2]=energyConsume(temp4(j),wakeuppacket); %wake-up receiver energy consumption
            [temp3,~]=energyConsume(temp4(j),datapacket); %data transmission energy consumption
            temp3=temp1+temp2+temp3;
            energyRemain(i)=energyRemain(i)-temp3;
        end
    end
end
allpathenergyconsume=Eo-energyRemain;
[allpathenergyconsume,sortindex]=sort(allpathenergyconsume);
allpaths=allpaths(sortindex);
end
