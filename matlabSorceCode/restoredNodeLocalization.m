function restoredNodeLocalization(newnodeID)
%global f1
global db_pos
global db_stddev
global db_path
global db_Eod
global db_Eod2
global db_Etot
global db_Emonitor
%global db_ondemand
global db_neighbour
global db_nodestatus
global db_Et;

rangeSearch= evalin('base','rangeSearch');
packetsizeBroadcast= evalin('base','packetsizeBroadcast');
node = evalin('base','node');
nextEventNode = evalin('base','nextEventNode');
nextEvent = evalin('base','nextEvent');
time =  evalin('base','time');
rangeNode =  evalin('base','rangeNode');
packetsizeWakeup   = evalin('base','packetsizeWakeup');
packetsizeData  = evalin('base','packetsizeData');
anchornumber  = evalin('base','anchornumber');
nodenumber  = evalin('base','nodenumber');
wurxEnergyMonitor  = evalin('base','wurxEnergyMonitor');
sink = evalin('base','sink');
%  = evalin('base','');
%  = evalin('base','');

if newnodeID > anchornumber
    newnode = node(newnodeID-anchornumber,:); %get true location of restored node
elseif newnodeID <= anchornumber
    newnode = db_pos(newnodeID,:);
end

%to clear previous plot
if newnodeID > anchornumber
    plot (db_pos(newnodeID,1),db_pos(newnodeID,2),'wo','MarkerSize',5,'lineWidth',2,'MarkerFaceColor','w','HandleVisibility','off');
end
fprintf('Node %s \n',num2str(newnodeID));

%% BROADCASTING AND BROADCAST ENERGY CONSUMPTION
%   energy consumption for new node for broadcasting
nodesInRange = 0;  %counter for nodes in current rangeSearch

temp5 = zeros(size(db_pos,1),1);  %temp5 = flag (1=broadcast received, 0=not received yet)
distNoisy=zeros(size(db_pos,1),1);  %preallocating
for k=1:numel(rangeSearch)
    for j=1:size(db_pos,1)
        if temp5(j)==1
            continue;
        end
        distNoisy(j,:)=distEstimate(norm([db_pos(j,1) db_pos(j,2)]-[newnode(1) newnode(2)]));
        if distNoisy(j) > rangeNode*rangeSearch(k)/100 || isnan(distNoisy(j))    %check for nodes in SearchRange
            distNoisy(j)= inf;
        else
            temp5(j)=1;
            nodesInRange=nodesInRange+1;
            [temp1,temp2]=energyConsume(distNoisy(j),packetsizeBroadcast); %wake-up receiver energy consumption for broadcast
            temp3=temp1+temp2;
            %new node broadcast energy consumption
            db_Eod(newnodeID,newnodeID)=db_Eod(newnodeID,newnodeID)+temp3;
            db_Et(newnodeID,time)=db_Et(newnodeID,time)+temp3;
            %neighbour broadcast energy consumption
            db_Eod(j,newnodeID)=db_Eod(j,newnodeID)+temp3;
            db_Et(j,time)=db_Et(j,time)+temp3;
        end
        if db_nodestatus(j) == 0 %check if node is dead
            distNoisy(j)= inf;
        end
    end
    if nodesInRange == 3 && k==numel(rangeSearch) && j==size(db_pos,1) || nodesInRange>=4
        %fprintf('No. of nodes in %sm range= %s \n',num2str(rangeNode*rangeSearch(k)/100),num2str(nodesInRange));
        break;
    end
end
%updating neighbour list
[dist, nearnodes]=sort(distNoisy);
nodesInRange = sum(~isinf(dist));
nearnodes=nearnodes(1:nodesInRange,1); %nearnodes= all nodes in coverage
temp3=dist(1:nodesInRange,1);
db_neighbour{newnodeID,1}=nearnodes;
db_neighbour{newnodeID,2}=temp3;
%updating neighbour list of neighbours(adding current node in theie neighbour list)
for j=1:numel(nearnodes)
    temp2 = db_neighbour{nearnodes(j),1};
    temp2 = [temp2; newnodeID];
    db_neighbour{nearnodes(j),1} = temp2;
    
    temp4 = db_neighbour{nearnodes(j),2};
    temp4 = [temp4; temp3(j)];
    db_neighbour{nearnodes(j),2} = temp4;
end

%% LOCALIZATION
if newnodeID <= anchornumber
    x_approx = db_pos(newnodeID,1); %in case of anchor, x_approax and y_approx = true position, no need of localization
    y_approx = db_pos(newnodeID,2);
    stddevinfo = [];
    fprintf('Node type: Anchor (No localization needed)\n');
    fprintf('True Location     :(%s,%s)\n',num2str(x_approx),num2str(y_approx));
else
    if nodesInRange<= 2
        fprintf('Localization not possible! \n');
        fprintf('--------------------------------------------------------------------\n');
        db_pos(newnodeID,:) = [NaN NaN];
        db_path(newnodeID,:) = {NaN NaN};
        distError(newnodeID,:) = NaN;
        plot(newnode(1),newnode(2),'rx','MarkerSize',7,'lineWidth',2,'HandleVisibility','off');
    elseif nodesInRange==3  %trilateration
        [x_approx,y_approx]=trilateration(nearnodes(1:3),dist(1:3),db_pos);
        stddevinfo = create_stddev_cell();
        stddevinfo(18,2)=num2cell(newnode(1));
        stddevinfo(18,3)=num2cell(newnode(2));
        stddevinfo(1,2:4)=num2cell(nearnodes(1:3)');
        stddevinfo(3,1:3)=num2cell(nearnodes(1:3)');
        stddevinfo(3,4:5)=num2cell([x_approx y_approx]);
    elseif nodesInRange>=4 %multilateration with four nodes
        [x_approx,y_approx,stddevinfo] = multilateration(nearnodes(1:4),dist(1:4),db_pos);
        stddevinfo(18,2)=num2cell(newnode(1));
        stddevinfo(18,3)=num2cell(newnode(2));
    end
    %LOCALIZATION ERROR CALCULATION
    distError(newnodeID,:)=norm([newnode(1) newnode(2)]-[x_approx y_approx]);
    fprintf('Localization error = %sm \n',num2str(distError(newnodeID)));
    fprintf('True Location     :(%s,%s) \nEstimated Location:(%s,%s)\n',num2str(newnode(1)),num2str(newnode(2)),num2str(x_approx),num2str(y_approx));
end
%% FINDING PATH TO SINK
distNoisy2=zeros(size(db_pos,1),1);
for k=1:numel(rangeSearch)
    for j=1:size(db_pos,1)
        distNoisy2(j,:)=distEstimate(norm([db_pos(j,1) db_pos(j,2)]-[x_approx y_approx]));
        if j == newnodeID || db_nodestatus(j) == 0 || distNoisy2(j) > rangeNode*rangeSearch(k)/100 || isnan(distNoisy2(j))
            distNoisy2(j)= inf;
        end
    end
end
for j=1:size(db_pos,1)
    if db_nodestatus(j) == 2 %check if node is pathless
        distNoisy2(j)= inf;
    end
end
[temp1, temp2]=sort(distNoisy2);
temp3 = sum(~isinf(temp1));
temp1 = temp1(1:temp3);
temp2=temp2(1:temp3,1); %temp2= all nodes in coverage
pathdistance=zeros(numel(temp2),1);    %path distances of near nodes, temp2 = nearnodes without pathless nodes
for j=1:numel(temp2)
    pathdistance(j)=db_path{temp2(j),2};
end
pathdistance=pathdistance + temp1(1:temp3);
shortpath=db_path{(temp2(pathdistance==min(pathdistance))),1};
pathdistance=pathdistance(pathdistance==min(pathdistance)); %shortest path distance
shortpath=[newnodeID shortpath];   %shortest path to sink
fprintf('Path to Sink: [ %s ] \n',num2str(shortpath));

%check for path validity
deadNodeDetected = 0;
for j=2:size(shortpath,2) %start from j=2 as 1st node in path is the new node itself
    if db_nodestatus(shortpath(j)) == 0
        deadnode = shortpath(j); % shortpath(j)=dead node
        if deadnode == sink
            continue;
        end
        deadNodeDetected = 1;
        fprintf('Node %s is dead in this path! \n',num2str(deadnode));
        prevNode = shortpath(j-1); % shortpath(j-1)=previous node of dead node
        temp2 = db_neighbour{prevNode,1};
        temp2 = temp2(temp2~=deadnode);
        temp2 = temp2(temp2~=(newnodeID));
        temp3 = zeros(size(temp2,1),1);  %sink-path distances of neighbours
        for k=1:size(temp2,1)
            temp3(k) = db_path{temp2(k),2};
        end
        [temp4,temp5] = sort(temp3);
        temp6 = temp2(temp5); %sorted neighbour list wrt low to high path distance
        prevNodeUpdatedPath = 0;
        for k=1:size(temp6,1)
            temp7=db_path{temp6(k),1};
            for m=1:size(temp7,2)
                if temp7(m) == deadnode
                    break;
                end
                if temp7(m) ~= deadnode && m == size(temp7,2)
                    prevNodeUpdatedPath = temp7;
                    prevNodeUpdatedPathDistance = temp4(k);
                    break;
                end
            end
            if prevNodeUpdatedPath ~= 0
                break;
            end
        end
        temp2 = shortpath(1:find(shortpath == prevNode));
        shortpath = [temp2 prevNodeUpdatedPath];
        prevNodeUpdatedPath = [prevNode prevNodeUpdatedPath];
        temp10=db_neighbour{prevNode,1};
        temp11=db_neighbour{prevNode,2};
        temp12=temp11(temp10 == prevNodeUpdatedPath(2));
        prevNodeUpdatedPathDistance = prevNodeUpdatedPathDistance + temp12;
        fprintf('Alternate path: [ %s ] \n',num2str(shortpath));
    end
end
%% UPDATING DATABASE
approxnewnode =[ x_approx y_approx ];
db_pos(newnodeID,:) = approxnewnode; %#ok<*AGROW>
db_stddev{newnodeID}=stddevinfo;
db_path(newnodeID,1)={shortpath};
db_path(newnodeID,2)={pathdistance};
if deadNodeDetected == 1 %updating the prev node of dead node
    db_path(prevNode,1)={prevNodeUpdatedPath};
    db_path(prevNode,2)={prevNodeUpdatedPathDistance};
end

%updating dead sink-paths
if deadNodeDetected == 1
    fprintf('. . . . . . . . . . . . . . . . . . .\n');
    fprintf('Updating path database: Node %s is dead. \n',num2str(deadnode));
    db_path = findAlternatePath(db_path,db_neighbour,deadnode);
end
%fprintf('--------------------------------------------------------------------\n');

%% ENERGY CONSUMPTION CALCULATION
%   energy consumption for new node for communicating near nodes
for j=1:numel(nearnodes)
    [temp1,temp2]=energyConsume(dist(j),packetsizeWakeup); %wake-up receiver energy consumption
    [~,temp3]=energyConsume(dist(j),packetsizeData); %data reception energy consumption
    temp3=temp1+temp2+temp3;
    db_Eod(newnodeID,newnodeID)=db_Eod(newnodeID,newnodeID)+temp3;
    db_Et(newnodeID,time)=db_Et(newnodeID,time)+temp3;
end
%   energy consumption for each near node to communicate with new node
for j=1:numel(nearnodes)
    [temp1,temp2]=energyConsume(dist(j),packetsizeWakeup); %wake-up receiver energy consumption
    [temp3,~]=energyConsume(dist(j),packetsizeData); %data transmission energy consumption
    temp3=temp1+temp2+temp3;
    db_Eod(nearnodes(j),newnodeID)=db_Eod(nearnodes(j),newnodeID)+temp3;
    db_Et(nearnodes(j),time)=db_Et(nearnodes(j),time)+temp3;
end
%   energy consumption for path nodes
temp5=db_path{newnodeID,1};  %loading path from database
if ~isempty(temp5)
    temp4=zeros(numel(temp5)-1,1);  %temp4 = distance between consecutive path nodes
    for j=1:numel(temp4)
        temp4(j,:)=(norm([db_pos(temp5(j),1) db_pos(temp5(j),2)]-[db_pos(temp5(j+1),1) db_pos(temp5(j+1),2)]));
    end
    for j=1:numel(temp5)
        if j==1 %(first node, new node itself)
            [temp1,temp2]=energyConsume(temp4(j),packetsizeWakeup); %wake-up receiver energy consumption
            [temp3,~]=energyConsume(temp4(j),packetsizeData); %data transmission energy consumption
            temp3=temp1+temp2+temp3;
            db_Eod(temp5(j),newnodeID)=db_Eod(temp5(j),newnodeID)+temp3;
            db_Et(temp5(j),time)=db_Et(temp5(j),time)+temp3;
        elseif j==numel(temp5)  %(last node, sink)
            [temp1,temp2]=energyConsume(temp4(j-1),packetsizeWakeup); %wake-up receiver energy consumption
            [~,temp3]=energyConsume(temp4(j-1),packetsizeData); %data reception energy consumption
            temp3=temp1+temp2+temp3;
            db_Eod(temp5(j),newnodeID)=db_Eod(temp5(j),newnodeID)+temp3;
            db_Et(temp5(j),time)=db_Et(temp5(j),time)+temp3;
        else   %(intermediate path nodess)
            [temp1,temp2]=energyConsume(temp4(j-1),packetsizeWakeup); %wake-up receiver energy consumption
            [~,temp3]=energyConsume(temp4(j-1),packetsizeData); %data reception energy consumption
            temp3=temp1+temp2+temp3;
            db_Eod(temp5(j),newnodeID)=db_Eod(temp5(j),newnodeID)+temp3;
            db_Et(temp5(j),time)=db_Et(temp5(j),time)+temp3;
            
            [temp1,temp2]=energyConsume(temp4(j),packetsizeWakeup); %wake-up receiver energy consumption
            [temp3,~]=energyConsume(temp4(j),packetsizeData); %data transmission energy consumption
            temp3=temp1+temp2+temp3;
            db_Eod(temp5(j),newnodeID)=db_Eod(temp5(j),newnodeID)+temp3;
            db_Et(temp5(j),time)=db_Et(temp5(j),time)+temp3;
        end
    end
end
%energy consumption of wurx for monitoring
for j=1:anchornumber+nodenumber
    if j~=newnodeID
        db_Etot(j,newnodeID)=db_Etot(j,newnodeID)+wurxEnergyMonitor*(nextEvent-time);
        db_Emonitor(j,newnodeID)=db_Emonitor(j,newnodeID)+wurxEnergyMonitor*(nextEvent-time);
    end
end
%adding Eod and Etot
for j=1:anchornumber+nodenumber
    %     if db_Eod(j,newnodeID)==0 || isnan(db_Eod(j,newnodeID))
    %         continue
    %     else
    db_Etot(j,nextEventNode)=db_Etot(j,nextEventNode)+db_Eod(j,nextEventNode);
    %     end
end
db_Eod2(:,nextEventNode)=db_Eod2(:,nextEventNode)+db_Eod(:,nextEventNode);

%%  PLOT & LEGEND
if newnodeID > anchornumber
    plot(approxnewnode(1),approxnewnode(2),'m+','MarkerSize',6,'lineWidth',2,'HandleVisibility','off'); %plot approx location of node
    line([newnode(1) approxnewnode(1)],[newnode(2) approxnewnode(2)],'color','m','HandleVisibility','off');  %plot line connecting true and approx
elseif newnodeID <= anchornumber
    plot (db_pos(newnodeID,1),db_pos(newnodeID,2),'b^','MarkerSize',5,'lineWidth',2,'MarkerFaceColor','b','HandleVisibility','off');
end

end