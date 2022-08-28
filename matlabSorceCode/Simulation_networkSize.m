%% ENERGY CONSUMPTION AND LOCALIZATION ERROR WRT NETWORK SIZE %%
%function used:
%function [avgLocError, avgCurrentConsumNoSink , anchornumber]= main(networkSize,range_anchor,node)
%savednodes=[round(rand(1000,1),4) round(rand(1000,1),4)]

clear all %#ok<CLALL>
close all
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nodenumber=50;
networkSize=15:5:100;
rangeAnchor=0; %to keep anchornumber constant, range_anchor changed in every iteration
runcount=1;
maxErrorCount=50;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Simulations=zeros(numel(networkSize),10);
% node=[round(rand(nodenumber,1),4) round(rand(nodenumber,1),4)];
load('savednodes.mat', 'savednodes');
node=savednodes(1:nodenumber,:);

for i=1:numel(networkSize)
    rangeAnchor=networkSize(i)/2;    %to always keep anchornumber=9 (constant)
    node_scaled=networkSize(i)*node;  %scaling w.r.t networkSize
    for errorResult=0:maxErrorCount
        if errorResult==maxErrorCount
            fprintf('Max Error Count reached! \n');
            sound(sin(1:3000));
            return
        end
        try
            iteration=zeros(runcount,3);
            for m=1:runcount
                [iteration(m,1),iteration(m,2),iteration(m,3),iteration(m,4),iteration(m,5),iteration(m,6)]=main18(networkSize(i),rangeAnchor,node_scaled);
            end
            if iteration(m,1)==inf || iteration(m,2)==inf
                continue
            end
            Simulations(i,1)=nodenumber;            %no. of nodes
            Simulations(i,2)=mean(iteration(:,3));     %no. of anchors
            Simulations(i,3)=networkSize(i);              %networksize
            Simulations(i,4)=rangeAnchor;             %range
            Simulations(i,5)=mean(iteration(:,2),'omitnan');         %avg.energy consumption
            Simulations(i,6)=mean(iteration(:,1),'omitnan');                    %avg.error
            Simulations(i,7)=Simulations(i,6)/Simulations(i,4)*100;              %error:range ratio (%)
            Simulations(i,8)=mean(iteration(:,4),'omitnan');    %last node
            Simulations(i,9)=mean(iteration(:,5),'omitnan');    %anchor 1
            Simulations(i,10)=mean(iteration(:,6),'omitnan');   %first node
            break
        catch
            continue
        end
    end
end

figure;
hold on; grid on; box on;
title('Energy Consumption vs Network size');
xlabel('Network size  (m x m)')
ylabel('Avg. energy consumption of each node (no sink)(J)')
plot (networkSize,Simulations(:,5),'ko','MarkerFaceColor','k','LineStyle','--')
legend('Avg','location','northwest');
% plot (networkSize,[Simulations(:,5),Simulations(:,9),Simulations(:,10),Simulations(:,8)])
% legend('Avg','Anchor 1','First node','Last node','location','northwest');

figure;
hold on; grid on; box on;
title('Localization error vs Network size');
xlabel('Network size (m x m)')
ylabel(' Avg. localization error (m)')
plot (networkSize,Simulations(:,6),'ko','MarkerFaceColor','k','LineStyle','--')

fprintf('Done! \n');
sound(sin(1:3000));