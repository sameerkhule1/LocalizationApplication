%% ENERGY CONSUMPTION AND LOCALIZATION ERROR WRT ANCHOR NUMBER %%
%function used:
%function [avgLocError, avgCurrentConsumNoSink , anchornumber]= main(networkSize,range_anchor,node)
%savednodes=[round(rand(1000,1),4) round(rand(1000,1),4)]

clear all %#ok<CLALL>
close all
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nodenumber=50;
networkSize=100;
rangeAnchor=[100 75 40 30 20 18 16 14 12 10 9.5 9]; %to get single values of anchornumber
%rangeAnchor=[100:-1:12 11.5:-.5:9];
runcount=1;
maxErrorCount=50;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Simulations=zeros(numel(rangeAnchor),7);
node=networkSize*[round(rand(nodenumber,1),4) round(rand(nodenumber,1),4)];
%load('savednodes.mat', 'savednodes')
%node=networkSize*savednodes(1:nodenumber,:);

for i=1:numel(rangeAnchor)
    for errorResult=0:maxErrorCount
        if errorResult==maxErrorCount
            fprintf('Max Error Count reached! \n');
            sound(sin(1:3000));
            return
        end
        try
            iteration=zeros(runcount,3);
            for m=1:runcount
                [iteration(m,1),iteration(m,2),iteration(m,3)]=main17(networkSize,rangeAnchor(i),node);
            end
            if iteration(m,1)==inf || iteration(m,2)==inf
                continue
            end
            Simulations(i,1)=nodenumber;               %no. of nodes
            Simulations(i,2)=mean(iteration(:,3));     %no. of anchors
            Simulations(i,3)=networkSize;              %networksize
            Simulations(i,4)=rangeAnchor(i);           %range
            Simulations(i,5)=mean(iteration(:,2),'omitnan');         %avg.energy consumption
            Simulations(i,6)=mean(iteration(:,1),'omitnan');         %avg.error
            Simulations(i,7)=Simulations(i,6)/Simulations(i,4)*100;  %error:range ratio (%)
            break
        catch
            continue
        end
    end
end

figure;
hold on; grid on; box on;
title('Energy Consumption vs No. of anchors');
xlabel('No. of anchors')
%yyaxis left
ylabel('Avg. energy consumption of each node (no sink)(J)')
%temp2=Simulations(:,5);
%ylim([min(temp2(~isinf(temp2)))  max(temp2(~isinf(temp2)))]);
plot (Simulations(:,2),Simulations(:,5),'ko','MarkerFaceColor','k','LineStyle','--')

% yyaxis right
% ylabel('Anchor range (m)')
% ylim([min(rangeAnchor)  max(rangeAnchor)]);
% plot (Simulations(:,2),Simulations(:,4),'ro','MarkerSize',1,'lineWidth',2,'MarkerFaceColor','r')

figure;
hold on; grid on; box on;
title('Localization error vs No. of anchors');
xlabel('No. of anchors')
%yyaxis left
ylabel('Avg. localization error (m)')
%temp2=Simulations(:,6);
%ylim([min(temp2(~isinf(temp2)))  max(temp2(~isinf(temp2)))]);
plot (Simulations(:,2),Simulations(:,6),'ko','MarkerFaceColor','k','LineStyle','--')
% yyaxis right
% ylabel('Node range (m)')
% ylim([min(rangeAnchor)  max(rangeAnchor)]);

% figure;
% hold on
% grid on
% title('Energy Consumption vs Range of anchors');
% xlabel('Range of anchors (m)')
% %yyaxis left
% ylabel('Avg. energy consumption of each node (no sink)(J)')
% temp2=Simulations(:,5);
% %ylim([min(temp2(~isinf(temp2)))  max(temp2(~isinf(temp2)))]);
% plot (Simulations(:,4),Simulations(:,5),'bo','MarkerSize',2,'lineWidth',2,'MarkerFaceColor','b')

% figure;
% hold on
% grid on
% title('Localization error vs Range of anchors');
% xlabel('Range of anchors (m)')
% %yyaxis left
% ylabel('Avg. localization error (m)')
% %temp2=Simulations(:,6);
% %ylim([min(temp2(~isinf(temp2)))  max(temp2(~isinf(temp2)))]);
% plot (Simulations(:,4),Simulations(:,6),'bo','MarkerSize',2,'lineWidth',2,'MarkerFaceColor','b')

fprintf('Done! \n');
sound(sin(1:3000));


% temp1=0;
% for k=1:numel(Simulations(:,2))
%     if Simulations(k,2)~=temp1
%       text(Simulations(k,2),Simulations(k,6),['( ' num2str(Simulations(k,2)) ' , ' num2str(Simulations(k,6)) ' )']);
%       temp1=Simulations(k,2);
%     else
%         continue;
%     end
% end

% for k=1:numel(Simulations(:,2))
%       text(Simulations(k,2),Simulations(k,5),['( ' num2str(Simulations(k,2)) ' , ' num2str(Simulations(k,5)) ' )']);
% end
