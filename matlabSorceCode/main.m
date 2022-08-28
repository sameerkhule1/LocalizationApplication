clear all %#ok<CLALL>
close all
clc
format bank;
% use following function to get all paths between 2 points (say node'5' and sink)
% allpaths=getpaths(connect.g1,connect.g2,db_pos,12,sink)

% use following function to get all paths and all path current consumption from source to sink (say node'10' and 'sink')
% [allpaths allpathenergy]=allpathEnergy(10,sink,connect.g1,connect.g2,db_pos,Eo,packetsizeData,packetsizeWakeup)

% use following function to get node details after run (e.g. node '15')
% nodedetail(15,f1,db_stddev,anchornumber,distError,db_path,db_pos)
% distance estimate between two points (45 & 11): distEstimate(norm([db_pos(45,1) db_pos(45,2)]-[db_pos(11,1) db_pos(11,2)]))
%% INITIALIZATION
networkSize=[100 100];
nodenumber=25;
rangeAnchor=25;
rangeNode=25;
%create scenario
%networkShape= 'square','hexagon'
%anchor deployment= 'random','deterministic'
[anchor,anchornumber,sink,node,p0,p1]=Scenario(networkSize,nodenumber,rangeAnchor,'square','grid');

loc_req=[]; %node ID
Eo=1;%9e-4 %initial energy(J)
packetsizeWakeup=2;   %(byte)
packetsizeData=8;     %(byte)
% packetsizeWakeupReq=2;   %(byte)
% packetsizeWakeupAck=2;   %(byte)
% packetsizeDataLoc=8;     %(byte)
% packetsizeData2sink=8;   %(byte)
packetsizeBroadcast=1;   %(byte)
rangeSearch=[100]; %#ok<*NBRAK> % rangeSearch = percentage of rangeNode in each iteration
% wurxEnergyMonitor=1; %WuRX energy consumption(monitoring)=7.5microWatt per sec=7.5 microJ
wurxEnergyMonitor= 7.5e-6; %WuRX energy consumption(monitoring)=7.5microWatt per sec=7.5 microJ
%wurxDecode=3*2099e-6; %%WuRX energy consumption(decoding)

timesim=nodenumber; %total simulation time (sec), (=nodenumber -> new node comes every 1 sec)
%timesim=10;
prevEvent=0;
event=sort(round(timesim.*rand(nodenumber,1),0)); %auto event setup
%event=[3;4;6;6;7]; %manual event setup
event(:,2)=anchornumber+1:anchornumber+nodenumber;

deadNodeList=[];    %[<nodeid> <event>]
restoreNodeList=[];   %[<nodeid> <event>]
criticalPower = 15;%(critical power in %)

%% CREATE DATABASE
global f1
global db_pos
global db_stddev
global db_path
global db_Eod
global db_Eod2
global db_Etot
global db_Emonitor
global db_ondemand
global db_neighbour
global db_nodestatus
global db_Et;
db_pos = anchor;
db_stddev = cell(anchornumber+nodenumber,1);
db_path = cell(anchornumber+nodenumber,2);
db_Eod = zeros(anchornumber+nodenumber,anchornumber+nodenumber+numel(loc_req));
db_Eod(anchornumber+1:anchornumber+nodenumber,1:anchornumber)=nan;
db_Eod2 = zeros(anchornumber+nodenumber,anchornumber+nodenumber+numel(loc_req));
db_Eod2(anchornumber+1:anchornumber+nodenumber,1:anchornumber)=nan;
db_Etot = zeros(anchornumber+nodenumber,anchornumber+nodenumber+numel(loc_req));
db_Etot(anchornumber+1:anchornumber+nodenumber,1:anchornumber)=nan;
db_Et = zeros(anchornumber+nodenumber,timesim);
db_Et(anchornumber+1:anchornumber+nodenumber,1:timesim)=nan;
db_Emonitor = zeros(anchornumber+nodenumber,anchornumber+nodenumber+numel(loc_req));
db_Emonitor(anchornumber+1:anchornumber+nodenumber,1:anchornumber)=nan;
db_ondemand = zeros(anchornumber+nodenumber,anchornumber+nodenumber);
db_ondemand(1:anchornumber+nodenumber,1:anchornumber)=NaN;
db_neighbour = cell(anchornumber+nodenumber,2);
db_nodestatus = ones(anchornumber+nodenumber,1);  %0=dead, 1=live, 2=pathless, 3=critical power, nan=yet to initialize
db_nodestatus(anchornumber+1:anchornumber+nodenumber,:)=nan;

%% FINDING SHORTEST PATH TO SINK FOR ANCHORS
temp3=1;
temp4=zeros(anchornumber,anchornumber);
connect.g1=0;
for j = 1 : anchornumber
    for k = 1 : anchornumber
        if j==k
            temp4(j,k)=inf;
            continue;
        end
        temp4(j,k)=round(norm(  [anchor(j,1) anchor(j,2)]  -  [anchor(k,1) anchor(k,2)]  ),2);
        if temp4(j,k) <= rangeAnchor
            connect.g1(temp3,:)=j;
            connect.g2(temp3,:)=k;
            connect.g3(temp3,:)=temp4(j,k);
            temp3=temp3+1;
            db_neighbour{j,1}=[db_neighbour{j,1}; k];
            db_neighbour{j,2}=[db_neighbour{j,2}; temp4(j,k)];
        end
    end
end
if connect.g1==0
    error('No anchors in range with scenario setup!');
end
G1 = graph(connect.g1,connect.g2,connect.g3);
    
for j = 1 : anchornumber
    [db_path{j,1},db_path{j,2}]=shortestpath(G1,j,sink);
end

%% MAIN SEQUENCE
distError=zeros(anchornumber+nodenumber,1);
icount = 1;
for time = 1:1:timesim
    fprintf('>>time=%s\n',num2str(time));
    
    % check for dead node
    for j=1:size(deadNodeList,1)
        if (time == deadNodeList(j,2) && db_nodestatus(deadNodeList(j,1)) == 1)
            temp1 = deadNodeList(j,1);
            db_nodestatus(temp1)=0;
            db_neighbour{temp1,1}=[];
            db_neighbour{temp1,2}=[];
            db_path{temp1,1}=[];
            db_path{temp1,2}=[];
            db_Etot(temp1,nextEventNode)=nan;
            db_Eod(temp1,nextEventNode)=nan;
            db_Eod2(temp1,nextEventNode)=nan;
            db_Emonitor(temp1,nextEventNode)=nan;
            db_Et(temp1,time) =nan;
            fprintf('--------------------------------------------------------------------\n');
            fprintf('Node %s dead at time=%s (dead node event)\n',num2str(deadNodeList(j,1)),num2str(time));
            fprintf('--------------------------------------------------------------------\n');
        end
    end
    
    %check for low battery power
    if icount < nodenumber
        for j=1:anchornumber+nodenumber
            %temp1 = 100 - db_Etot(j,icount+anchornumber) / Eo * 100; %temp1 = percent remaining power
            temp1 = 100 - db_Et(j,time) / Eo * 100; %temp1 = percent remaining power
            if temp1 <= 0 && j~=sink
                temp2 = j; %temp2= critical/dead node
                db_nodestatus(temp2) = 0; % 0 represents dead status in db_nodestatus
                fprintf('Node %s is Dead at time = %s! \n',num2str(temp2),num2str(time));
                fprintf('--------------------------------------------------------------------\n');
            end
            if j == sink || db_nodestatus(j) == 0 || db_nodestatus(j) == 3 %do not check for sink, dead nodes and already critical nodes
                continue;
            end
            if temp1 <= criticalPower
                temp2 = j; %temp2= critical node
                db_nodestatus(temp2) = 3; % 3 represents critical status in db_nodestatus
                fprintf('--------------------------------------------------------------------\n');
                fprintf('Critical power detected for Node %s! (%0.2f%% at time = %s). \n',num2str(temp2),temp1,num2str(time));
                db_path = findAlternatePath(db_path,db_neighbour,temp2);
                fprintf('--------------------------------------------------------------------\n');
            end
        end
    end
    
    % check for restored node
    for j=1:size(restoreNodeList,1)
        if (time == restoreNodeList(j,2) && (db_nodestatus(restoreNodeList(j,1)) == 0 || db_nodestatus(restoreNodeList(j,1)) == 0))
            fprintf('--------------------------------------------------------------------\n');
            temp1 = restoreNodeList(j,1); %temp1 = restored node
            fprintf('Node %s restored at time=%s (restore node event)\n',num2str(temp1),num2str(time));
            db_nodestatus(temp1)=1;
            db_Etot(temp1,nextEventNode)=0;
            db_Eod(temp1,nextEventNode)=0;
            db_Eod2(temp1,nextEventNode)=0;
            db_Emonitor(temp1,nextEventNode)=0;
            db_Et(temp1,time) = - wurxEnergyMonitor;
            restoredNodeLocalization(temp1);
            fprintf('--------------------------------------------------------------------\n');
        end
    end
    if icount <= nodenumber %to simulate till time=timesim
        if time == event(icount,1)
            for i=icount:nodenumber+numel(loc_req)
                newnodeID = i+anchornumber;
                fprintf('>>(nodeID,event)=(%s,%s)[event]\n',num2str(newnodeID),num2str(event(i,1)));
                db_nodestatus(newnodeID)=1;
                db_Etot(:,newnodeID)=db_Etot(:,newnodeID-1);
                db_Etot(newnodeID,newnodeID)=0;
                db_Emonitor(:,newnodeID)=db_Emonitor(:,newnodeID-1);
                db_Emonitor(newnodeID,newnodeID)=0;
                db_Eod2(:,newnodeID)=db_Eod2(:,newnodeID-1);
                db_Eod2(newnodeID,newnodeID)=0;
                db_Et(newnodeID,time:end)= 0;%initializing newnodeId
                db_Et(newnodeID,time)= - wurxEnergyMonitor;%minus sign for later compasation
                if i>nodenumber
                    fprintf('Localization request from Node %s \n',num2str(loc_req(i-nodenumber)));
                    newnode=node(loc_req(i-nodenumber)-anchornumber,:);
                else
                    fprintf('--------------------------------------------------------------------\n');
                    fprintf('Node %s \n',num2str(newnodeID));
                    newnode= node(i,:);
                end
                p2 = plot(newnode(1),newnode(2),'go','MarkerSize',3,'lineWidth',2,'MarkerFaceColor','g','HandleVisibility','off');
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
                        if i>nodenumber && j==loc_req(i-nodenumber)
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
                nearnodes = nearnodes(1:nodesInRange,1); %nearnodes= all nodes in coverage
                dist = dist(1:nodesInRange,1);
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
                if nodesInRange<= 2
                    fprintf('Localization not possible! \n');
                    fprintf('--------------------------------------------------------------------\n');
                    db_pos(newnodeID,:) = [NaN NaN];
                    db_path(newnodeID,:) = {NaN NaN};
                    distError(newnodeID,:) = NaN;
                    p4 = plot(newnode(1),newnode(2),'rx','MarkerSize',7,'lineWidth',2);
                    continue;
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
                if i>nodenumber
                    distError(loc_req(i-nodenumber),:)=norm([newnode(1) newnode(2)]-[x_approx y_approx]);
                    fprintf('Localization error = %sm \n',num2str(distError(loc_req(i-nodenumber))));
                else
                    distError(newnodeID,:)=norm([newnode(1) newnode(2)]-[x_approx y_approx]);
                    fprintf('Localization error = %sm \n',num2str(distError(newnodeID)));
                end
                fprintf('True Location     :(%s,%s) \nEstimated Location:(%s,%s)\n',num2str(newnode(1)),num2str(newnode(2)),num2str(x_approx),num2str(y_approx));
                
                %% FINDING PATH TO SINK
                distNoisy2=zeros(size(db_pos,1),1);
                for k=1:numel(rangeSearch)
                    for j=1:size(db_pos,1)
                        distNoisy2(j,:)=distEstimate(norm([db_pos(j,1) db_pos(j,2)]-[x_approx y_approx]));
                        if db_nodestatus(j) == 0 || distNoisy2(j) > rangeNode*rangeSearch(k)/100 || isnan(distNoisy2(j))    %check for nodes in SearchRange
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
                if i>nodenumber
                    db_pos(loc_req(i-nodenumber),:) = approxnewnode;
                    db_stddev{loc_req(i-nodenumber)}=stddevinfo;
                    db_path(loc_req(i-nodenumber),1)={shortpath};
                    db_path(loc_req(i-nodenumber),2)={pathdistance};
                else
                    db_pos = [db_pos; approxnewnode]; %#ok<*AGROW>
                    db_stddev{newnodeID}=stddevinfo;
                    db_path(newnodeID,1)={shortpath};
                    db_path(newnodeID,2)={pathdistance};
                    
                    if deadNodeDetected == 1 %updating the prev node of dead node
                        db_path(prevNode,1)={prevNodeUpdatedPath};
                        db_path(prevNode,2)={prevNodeUpdatedPathDistance};
                    end
                end
                
                %updating dead sink-paths
                if deadNodeDetected == 1
                    fprintf('. . . . . . . . . . . . . . . . . . .\n');
                    fprintf('Updating path database: Node %s is dead. \n',num2str(deadnode));
                    db_path = findAlternatePath(db_path,db_neighbour,deadnode);
                end
                fprintf('--------------------------------------------------------------------\n');
                
                %updating g1,g2,g3 (this part is excludable, only for connection demonstration purpose)
                temp1=norm([db_pos(nearnodes(1),1) db_pos(nearnodes(1),2)]-[newnode(1) newnode(2)]);
                temp2=norm([db_pos(nearnodes(2),1) db_pos(nearnodes(2),2)]-[newnode(1) newnode(2)]);
                temp3=norm([db_pos(nearnodes(3),1) db_pos(nearnodes(3),2)]-[newnode(1) newnode(2)]);
                if nodesInRange == 4
                    temp4=norm([db_pos(nearnodes(4),1) db_pos(nearnodes(4),2)]-[newnode(1) newnode(2)]);
                    connect.g1=[connect.g1;nearnodes(1);nearnodes(2);nearnodes(3);nearnodes(4)];
                    connect.g2=[connect.g2;newnodeID;newnodeID;newnodeID;newnodeID];
                    connect.g3=[connect.g3;temp1;temp2;temp3;temp4];
                else
                    connect.g1=[connect.g1;nearnodes(1);nearnodes(2);nearnodes(3)];
                    connect.g2=[connect.g2;newnodeID;newnodeID;newnodeID];
                    connect.g3=[connect.g3;temp1;temp2;temp3];
                end
                
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
                
                %   setting on-demand status (here, extra nodes (>4)in broadcasting are not considered)
                for j=1:numel(nearnodes)
                    db_ondemand(nearnodes(j),newnodeID)=1; %on-demand status for nearnodes
                end
                temp5=db_path{newnodeID,1};  %loading path from database
                if ~isempty(temp5)
                    for j=1:numel(temp5) %here, temp5=path nodes
                        db_ondemand(temp5(j),newnodeID)=1; %on-demand status for path nodes
                    end
                end
                
                %   energy consumption of wurx for monitoring
                for j=1:anchornumber+nodenumber
                    if j ~= newnodeID
                        db_Etot(j,newnodeID)=db_Etot(j,newnodeID)+wurxEnergyMonitor*(event(i,1)-prevEvent);
                        db_Emonitor(j,newnodeID)=db_Emonitor(j,newnodeID)+wurxEnergyMonitor*(event(i,1)-prevEvent);
                        %db_Et(j,time)=db_Et(j,time)+wurxEnergyMonitor;
                    end
                end
                prevEvent=event(i,1);
                if i < nodenumber
                    nextEventNode = event(i+1,2);
                    nextEvent =  event(i+1,1);
                end
                db_ondemand(newnodeID+1:end,newnodeID)=nan;
                db_Eod(newnodeID+1:end,newnodeID)=nan;
                db_Etot(newnodeID+1:end,newnodeID)=nan;
                
                %adding Eod into Etot
                for j=1:anchornumber+nodenumber
                    if db_Eod(j,newnodeID)==0 || isnan(db_Eod(j,newnodeID))
                        continue
                    else
                        db_Etot(j,newnodeID)=db_Etot(j,newnodeID)+db_Eod(j,newnodeID);
                    end
                end
                db_Eod2(:,newnodeID)=db_Eod2(:,newnodeID)+db_Eod(:,newnodeID);
                
                %%  PLOT & LEGEND
                for j=1:size(db_nodestatus,1)
                    if db_nodestatus(j) == 0 && j~=sink
                        if j <= anchornumber
                            p8 = plot (db_pos(j,1),db_pos(j,2),'r^','MarkerSize',5,'lineWidth',2,'MarkerFaceColor','r');
                        else
                            p6 = plot (db_pos(j,1),db_pos(j,2),'ro','MarkerSize',5,'lineWidth',2,'MarkerFaceColor','r');
                        end
                    end
                    if db_nodestatus(j) == 3  && j~=sink
                        if j <= anchornumber
                            p9 = plot (db_pos(j,1),db_pos(j,2),'y^','MarkerSize',5,'lineWidth',2,'MarkerFaceColor','y');
                        else
                            p7 = plot (db_pos(j,1),db_pos(j,2),'yo','MarkerSize',5,'lineWidth',2,'MarkerFaceColor','y');
                        end
                    end
                end
                
                if isnan(x_approx) || isnan(y_approx)
                    p4 = plot(newnode(1),newnode(2),'rx','MarkerSize',5,'lineWidth',2);
                    text(newnode(1)+0.5,newnode(2)+0.5, num2str(newnodeID));
                else
                    p2 = plot(newnode(1),newnode(2),'go','MarkerSize',3,'lineWidth',2,'MarkerFaceColor','g');
                end
                if i>nodenumber
                    p5 = plot(approxnewnode(1),approxnewnode(2),'c+','MarkerSize',7,'lineWidth',2); %plot updated approx location of new node
                    line([newnode(1) approxnewnode(1)],[newnode(2) approxnewnode(2)],'color','c');  %plot line connecting true and updated approx
                else
                    p3 = plot(approxnewnode(1),approxnewnode(2),'m+','MarkerSize',6,'lineWidth',2); %plot approx location of node
                    text(approxnewnode(1)+0.5,approxnewnode(2)+0.5, num2str(newnodeID));   %naming the approx node
                    line([newnode(1) approxnewnode(1)],[newnode(2) approxnewnode(2)],'color','m');  %plot line connecting true and approx
                end
                
                %legend
                f1;
                if exist('p4','var') && exist('p5','var')
                    legend([p0 p1 p2 p3 p4 p5],{'Sink','Primary anchor','True location','Estimated location','Unlocalized node','Updated location'})
                    %%%% p6, p7, p8, p9
                elseif exist('p6','var') && exist('p7','var') && exist('p8','var')
                    legend([p0 p1 p2 p3,p6,p7,p8],{'Sink','Primary anchor','True location','Estimated location','Dead node','Critical node','Dead anchor'})
                elseif exist('p6','var') && exist('p7','var') && exist('p9','var')
                    legend([p0 p1 p2 p3,p6,p7,p9],{'Sink','Primary anchor','True location','Estimated location','Dead node','Critical node','Critical anchor'})
                elseif exist('p6','var') && exist('p8','var') && exist('p9','var')
                    legend([p0 p1 p2 p3,p6,p8,p9],{'Sink','Primary anchor','True location','Estimated location','Dead node','Dead anchor','Critical anchor'})
                elseif exist('p7','var') && exist('p8','var') && exist('p9','var')
                    legend([p0 p1 p2 p3,p7,p8,p9],{'Sink','Primary anchor','True location','Estimated location','Critical node','Dead anchor','Critical anchor'})
                elseif exist('p6','var') && exist('p7','var')
                    legend([p0 p1 p2 p3,p6,p7],{'Sink','Primary anchor','True location','Estimated location','Dead node','Critical node'})
                elseif exist('p6','var') && exist('p8','var')
                    legend([p0 p1 p2 p3,p6,p8],{'Sink','Primary anchor','True location','Estimated location','Dead node','Dead anchor'})
                elseif exist('p6','var') && exist('p9','var')
                    legend([p0 p1 p2 p3,p6,p9],{'Sink','Primary anchor','True location','Estimated location','Dead node','Critical anchor'})
                elseif exist('p7','var') && exist('p8','var')
                    legend([p0 p1 p2 p3,p7,p8],{'Sink','Primary anchor','True location','Estimated location','Critical node','Dead anchor'})
                elseif exist('p7','var') && exist('p9','var')
                    legend([p0 p1 p2 p3,p7,p9],{'Sink','Primary anchor','True location','Estimated location','Critical node','Critical anchor'})
                elseif exist('p8','var') && exist('p9','var')
                    legend([p0 p1 p2 p3,p8,p9],{'Sink','Primary anchor','True location','Estimated location','Dead anchor','Critical anchor'})
                elseif exist('p6','var')
                    legend([p0 p1 p2 p3,p6],{'Sink','Primary anchor','True location','Estimated location','Dead node'})
                elseif exist('p7','var')
                    legend([p0 p1 p2 p3,p7],{'Sink','Primary anchor','True location','Estimated location','CritiCritical anchorl node'})
                elseif exist('p8','var')
                    legend([p0 p1 p2 p3,p8],{'Sink','Primary anchor','True location','Estimated location','Dead anchor'})
                elseif exist('p9','var')
                    legend([p0 p1 p2 p3,p9],{'Sink','Primary anchor','True location','Estimated location','Critical anchor'})
                    %%%%
                elseif exist('p5','var')
                    legend([p0 p1 p2 p3 p5],{'Sink','Primary anchor','True location','Estimated location','Updated location'})
                elseif exist('p4','var')
                    legend([p0 p1 p2 p3 p4],{'Sink','Primary anchor','True location','Estimated location','Unlocalized node'})
                elseif exist('p3','var')
                    legend([p0 p1 p2 p3],{'Sink','Primary anchor','True location','Estimated location'})
                end
                if event(icount+1) == event(icount)
                    icount=icount+1;
                    continue
                else
                    break
                end
            end
            icount=i+1;
        end
    end
    db_Et(:,time) = db_Et(:,time)+wurxEnergyMonitor;
    if time < timesim
        db_Et(:,time+1) = db_Et(:,time);
    end   
end
%% PRINT RESULTS
%fprintf('--------------------------------------------------------------------\n');
fprintf('Network size: %sm x %sm \n',num2str(networkSize(1)),num2str(networkSize(2)));
fprintf('Anchor node range = %sm\n',num2str(rangeAnchor));
fprintf('Normal node range = %sm\n',num2str(rangeNode));
fprintf('Total number of anchor nodes = %s \n',num2str(anchornumber));
fprintf('Total number of normal nodes = %s \n',num2str(size(node,1)));
fprintf('Total number of unlocalized nodes = %s \n',num2str(sum(isnan(db_pos(:,1)+db_pos(:,2)))));
fprintf('Avg. localization error = %sm \n',num2str(mean(distError(anchornumber+1:size(distError,1)),'omitnan')));

Econsume=db_Et(:,end);
temp1=Econsume;
temp1(sink)=0;  %to exclude sink current consumption for calculation
EconsumeNoSink=temp1;
fprintf('Avg. energy consumption = %s J (with sink) \n',num2str(mean(nonzeros(Econsume),'omitnan')));
fprintf('Avg. energy consumption = %s J (no sink) \n',num2str(mean(nonzeros(EconsumeNoSink),'omitnan')));
fprintf('--------------------------------------------------------------------\n');

%% GRAPHS
% figure;
% hold on; grid on
% title(['Avg. Localization error = ',num2str(mean(distError(anchornumber+1:size(distError,1)),'omitnan')),' m']);
% xlabel('Node ID')
% ylabel('Avg. localization error (m)')
% bar((anchornumber+1:size(db_pos,1)),distError(anchornumber+1:size(distError,1)),0.7);
%
% figure;
% hold on; grid on
% title(['Avg. Energy Consumption (No sink) = ',num2str(mean(nonzeros(EconsumeNoSink))),' J']);
% xlabel('Node ID')
% ylabel('Avg. energy consumption of each node (no sink)(J)')
% xticks(1:1:anchornumber+nodenumber)
% bar(1:anchornumber+nodenumber,Econsume,0.7)

% figure;
% hold on; grid on
% title(['Avg. Energy Consumption (No sink) = ',num2str(mean(nonzeros(EconsumeNoSink))),' J']);
% xlabel('Time (sec)')
% ylabel('Avg. energy consumption of each node (no sink)(J)')
% %xticks(1:1:anchornumber+nodenumber)
% temp1=Eo-db_Eod(sink,anchornumber+1:end);             %sink
% temp4=Eo-db_Eod(anchornumber+1,anchornumber+1:end);   %1st node
% temp5=Eo-db_Eod(anchornumber+2,anchornumber+1:end);   %2nd node
% temp6=Eo-db_Eod(anchornumber+3,anchornumber+1:end);   %3rd node
% temp3=Eo-db_Eod(1,anchornumber+1:end);                %anchor '1'
% plot(event,temp1,event,temp4,event,temp5,event,temp6,event,temp3)
% % legend('Sink','1st node','Anchor 1','location','northwest');
% legend('Sink','10','11','12','Anchor 1','location','northwest');

% figure;
% hold on; grid on
% title('node 10 energy consumption');
% xlabel('Time (sec)')
% ylabel('Energy consumption(J)')
% xlim([0 timesim]);
% plot(1:timesim,db_Et(11,:),'r.--');

%temp2=db_Etot(anchornumber+1,anchornumber+1:end);
%temp3=db_Emonitor(anchornumber+1,anchornumber+1:end);
%plot(event,temp1,'mo')
%bar(event(:,1),temp1(:,1))
%plot(event(:,1),temp2,'bo')
%plot(event,temp3,'ro')
%legend('Etot','Emon','location','northwest');
%
% figure;
% hold on; grid on
% title(['Energy consumption for Node ',num2str(anchornumber+1)]);
% xlabel('Time (sec)')
% ylabel('Energy consumption(J)')
% temp2=db_Eod2(anchornumber+1,anchornumber+1:end);
% temp1=db_Emonitor(anchornumber+1,anchornumber+1:end);
% temp3=[temp1;temp2];
% bar(anchornumber+1:anchornumber+nodenumber,temp3,'stacked')
% legend('wake-up rx monitoring','on-demand (active)','location','northwest')

% figure;
% hold on; grid on
% title('node 10 wurx listening');
% xlabel('Time (sec)')
% ylabel('Avg. energy consumption of each node (no sink)(J)')
% %xticks(1:1:anchornumber+nodenumber)
% temp2=Eo-db_Etot(anchornumber+1,anchornumber+1:end);   %1st node
% plot(event,temp2)
% % legend('Sink','1st node','Anchor 1','location','northwest');
% legend('10','location','northwest');
%
% figure;
% hold on; grid on
% title('node 10 total');
% xlabel('Time (sec)')
% ylabel('Avg. energy consumption of each node (no sink)(J)')
% %xticks(1:1:anchornumber+nodenumber)
% plot(event,temp1+temp2)
% % legend('Sink','1st node','Anchor 1','location','northwest');
% legend('10','location','northwest');

% figure;
% hold on; % grid on
% title('Percentage Energy Remaining plot');
% xlabel('Iteration')
% ylabel('Energy (%)')
% xticks(1:1:anchornumber+nodenumber)
% bar(1:anchornumber+nodenumber,db_Eod(:,end).*100/Eo)

% all path energy consumption
% warning! keep nodenumber less (~3) to avoid longer simulation time
temp1=11; %here, temp1 is the first node in the network
temp2=10; %here, only first 'temp2' paths considered for the plot
 [allpaths,allpathenergy]=allpathEnergy(temp1,sink,connect.g1,connect.g2,db_pos,Eo,packetsizeData,packetsizeWakeup);
figure;
hold on; grid on; box on;
title('Energy Consumption for all paths');
xlabel('Path')
ylabel('Path energy consumption (J)')
bar(1:temp2,allpathenergy(1:temp2,:))

% close all
% figure('Name','Avg. localization error of node/s','NumberTitle','off');
% hold on; grid on;
% xlabel('Time (sec)')
% ylabel('Energy consumption(J)')
% temp1 = [16 17 18 19 20 21];
% for j=1:numel(temp1)
%     temp2=db_Etot(temp1(j),anchornumber+1:end);
%     plot(event(:,1),temp2,'.--','MarkerSize',10,'DisplayName',num2str(temp1(j)));
% end
% legend('Location','northwest');