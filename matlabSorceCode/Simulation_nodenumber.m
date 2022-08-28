%% ENERGY CONSUMPTION AND LOCALIZATION ERROR WRT ANCHOR NUMBER WRT NODE NUMBER %%
%function used:
%function [avgLocError, avgCurrentConsumNoSink , anchornumber]= main(networkSize,range_anchor,node)
%savednodes=[round(rand(1000,1),4) round(rand(1000,1),4)]

clear all %#ok<CLALL>
close all
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nodenumber=100;  %simulation will run for 1:nodenumber
networkSize=100;
rangeAnchor=50;
runcount=1;
maxErrorCount=50;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Simulations=zeros(numel(nodenumber),10);
node=networkSize*[round(rand(nodenumber,1),4) round(rand(nodenumber,1),4)];
%load('savednodes.mat', 'savednodes')
%node=networkSize*savednodes(1:nodenumber,:);

for i=1:nodenumber
    node2=node(1:i,:);
    for errorResult=0:maxErrorCount
        if errorResult==maxErrorCount
            fprintf('Max Error Count reached! \n');
            sound(sin(1:3000));
            return
        end
        try
            iteration=zeros(runcount,3);
            for m=1:runcount
                [iteration(m,1),iteration(m,2),iteration(m,3),iteration(m,4),iteration(m,5),iteration(m,6)]=main18(networkSize,rangeAnchor,node2);
            end
            Simulations(i,1)=i;                        %no. of nodes
            Simulations(i,2)=mean(iteration(:,3));     %no. of anchors
            Simulations(i,3)=networkSize;              %networksize
            Simulations(i,4)=rangeAnchor;              %range
            Simulations(i,5)=mean(iteration(:,2),'omitnan');         %avg.energy consumption
            Simulations(i,6)=mean(iteration(:,1),'omitnan');         %avg.error
            Simulations(i,7)=Simulations(i,6)/Simulations(i,4)*100;  %error:range ratio (%)
            Simulations(i,8)=mean(iteration(:,4),'omitnan'); %consumption of last node(for now,last node = sink)
            Simulations(i,9)=mean(iteration(:,5),'omitnan'); %consumption of anchor
            Simulations(i,10)=mean(iteration(:,6),'omitnan');%consumption of first node
            break
        catch
            continue
        end
    end
end

figure;
hold on; grid on; box on;
title('Energy Consumption vs No. of nodes');
xlabel('No. of nodes')
ylabel('Avg. energy consumption of each node (no sink)(J)')
plot (1:nodenumber,[Simulations(:,5),Simulations(:,8)],'LineWidth',2)
legend('Avg','Sink','location','northwest');
%plot (1:nodenumber,[Simulations(:,5),Simulations(:,9),Simulations(:,10),Simulations(:,8)])
%legend('Avg','Anchor 1','First node','Last node','location','northwest');

figure;
hold on; grid on; box on;
title('Localization error vs No. of nodes');
xlabel('No. of nodes')
ylabel(' Avg. localization error (m)')
plot (1:nodenumber,Simulations(:,6),'LineWidth',2,'Color','k')

figure; %localization figure at specific node interval (unfined graph)
hold on; grid on; box on;
title('Localization error vs No. of nodes');
xlabel('No. of nodes')
ylabel(' Avg. localization error (m)')
temp1 = 5:5:nodenumber; %this is the interval
Simulations3 = zeros(numel(temp1),10);
for j=1:numel(temp1)
    Simulations3(j,:)=Simulations(temp1(j),:);
end
plot (Simulations3(:,1),Simulations3(:,6),'ko','MarkerFaceColor','k','LineStyle','--')

fprintf('Done! \n');
sound(sin(1:3000));