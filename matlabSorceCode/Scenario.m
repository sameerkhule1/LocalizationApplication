function[anchor,anchornumber,sink,node,p0,p1] = Scenario(networkSize,nodenumber,rangeAnchor,networkShape,deployment)
global f1
f1=figure;
title('Deployment of nodes in network area');
grid on; hold on; box on

if (strcmp(networkShape,'square'))
    %create nodes
    temp1=2;    %node deployment: 1=random, 2=manual, 3=load pre-saved
    if temp1==1
        node=[networkSize(1)*round(rand(nodenumber,1),4) networkSize(2)*round(rand(nodenumber,1),4)];
    elseif temp1==2
        node=[70 30; 90 10];
        nodenumber = size(node,1);
        node=round(node,2);
    elseif temp1==3
        load('savednodes.mat', 'savednodes')
        node=savednodes(1:nodenumber,:);
        node=[networkSize(1)*node(:,1) networkSize(2)*node(:,2)];
    end
    if  (strcmp(deployment,'grid'))
        %create anchors
        xlim([0 networkSize(1)]);  ylim([0 networkSize(2)]);
        temp1=linspace(0,networkSize(1),ceil((networkSize(1)/rangeAnchor)+1));
        temp2=linspace(0,networkSize(2),ceil((networkSize(2)/rangeAnchor)+1));
        temp3=1;
        for i= 1:size(temp1,2)
            for j=1:size(temp2,2)
                anchor(temp3,:) = [temp1(i) temp2(j)]; %#ok<*AGROW,*SAGROW>
                p1=plot (temp1(i),temp2(j),'b^','MarkerSize',5,'lineWidth',2,'MarkerFaceColor','b');
                temp3=temp3+1;
            end
        end
        % anchor=[0 0; 0 100; 100 0; 100 100];  %manual anchors
        % p1=plot(anchor(:,1),anchor(:,2),'bo','MarkerSize',5,'lineWidth',2,'MarkerFaceColor','b');
        
    elseif (strcmp(deployment,'random'))
        temp1=ceil((networkSize(1)/rangeAnchor)+1);
        temp1=temp1*temp1;
        anchor=[networkSize(1)*round(rand(temp1,1),4) networkSize(2)*round(rand(temp1,1),4)];
        p1=plot (anchor(:,1),anchor(:,2),'b^','MarkerSize',5,'lineWidth',2,'MarkerFaceColor','b');
    end
    anchornumber=size(anchor,1);
    
    %naming all nodes
    temp1 = cellstr(num2str((1:size(anchor))'));
    for i=1:size(anchor)
        text(anchor(i,1)+1,anchor(i,2)+1, temp1(i));
    end
    %select sink
    for j=1:anchornumber
        if anchor(j,:)==networkSize/2 %anchor present at centre, assign that anchor as sink
            sink=j;
            break;
        else %no anchor present at centre, find nearest anchor to centre and  assign that anchor as sink
            temp2=0;
            for temp1 = 1 : anchornumber
                temp2(temp1,:)=norm(  networkSize/2  -  [anchor(temp1,1) anchor(temp1,2)]  );
            end
            sink=find(temp2==min(temp2));
            if numel(sink)>1 %to remove error for 4 anchors
                sink=sink(1);
            end
        end
    end
    %plot sink
    p0=plot((anchor(sink,1)),(anchor(sink,2)),'k^','MarkerSize',5,'lineWidth',2,'MarkerFaceColor','k');
    
elseif (strcmp(networkShape,'Hexagon'))
    if (strcmp(deployment,'Grid'))
        %create nodes
        temp1=3;    %node deployment: 1=random, 2=manual, 3=load pre-saved
        if temp1==1
            node=[networkSize(1)*round(rand(nodenumber,1),4) networkSize(2)*round(rand(nodenumber,1),4)];
        elseif temp1==2
            node=[20 20;20 80;80 80;80 20; 50 50];
            nodenumber = size(node,1);
            node=round(node,2);
        elseif temp1==3
            load('savednodes.mat', 'savednodes')
            node=savednodes(1:nodenumber,:);
            node=[networkSize(1)*node(:,1) networkSize(2)*node(:,2)];
        end
        h.xmin = 0;
        h.ymin = 0;
        h.xmax = networkSize(1);
        h.ymax = networkSize(2);
        h.xorigin = 0;
        h.yorigin = 0;
        h.side = 25;
        
        anchor = hexagonalGrid([h.xmin h.ymin h.xmax h.ymax], [h.xorigin h.yorigin], h.side);
        anchornumber=size(anchor,1);
        p1=plot (anchor(:,1),anchor(:,2),'b^','MarkerSize',5,'lineWidth',2,'MarkerFaceColor','b');
        %naming all nodes
        temp1 = cellstr(num2str((1:size(anchor))'));
        for i=1:size(anchor)
            text(anchor(i,1)+1,anchor(i,2)+1, temp1(i));
        end
        %select sink
        for j=1:anchornumber
            if anchor(j,:)==networkSize/2 %anchor present at centre, assign that anchor as sink
                sink=j;
                break;
            else %no anchor present at centre, find nearest anchor to centre and  assign that anchor as sink
                temp2=0;
                for temp1 = 1 : anchornumber
                    temp2(temp1,:)=norm(  networkSize/2  -  [anchor(temp1,1) anchor(temp1,2)]  );
                end
                sink=find(temp2==min(temp2));
                if numel(sink)>1 %to remove error for 4 anchors
                    sink=sink(1);
                end
            end
        end
        %plot sink
        p0=plot((anchor(sink,1)),(anchor(sink,2)),'k^','MarkerSize',5,'lineWidth',2,'MarkerFaceColor','k');
        
    elseif (strcmp(deployment,'Single hexagon - center sink'))
        %https://de.mathworks.com/matlabcentral/answers/33593-generate-uniformly-distributed-points-inside-a-hexagon
        side = rangeAnchor;
        centerx = networkSize(1)/2;
        centery = networkSize(2)/2;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        m = 3;
        X = rand(m-1,nodenumber) .^ (1./(m-1:-1:1)');
        X = cumprod([ones(1,nodenumber);X]).*[ones(m,nodenumber)-[X;zeros(1,nodenumber)]]; %#ok<NBRAK>
        z6 = exp(2i*pi/6);
        Z = [0, 1, z6]*X;
        Z = Z .* (z6.^floor(6*rand(1,nodenumber)));
        x = centerx+side*real(Z);
        y = centery+side*imag(Z);
        axis equal
        %plot nodes
        node = [x(:),y(:)];
        %plot(x,y,'go','MarkerSize',3,'lineWidth',2,'MarkerFaceColor','g')
        % plot sides
        v_x = side * cos((0:6)*pi/3)+centerx;
        v_y = side * sin((0:6)*pi/3)+centery;
        plot(v_x,v_y,'k');
        %plot anchors
        anchor=[v_x' v_y'];
        anchor=anchor(1:6,:);
        anchor=[anchor; centerx centery];   %adding centre of hexagone as an anchor
        anchornumber=size(anchor,1);
        p1=plot(anchor(:,1),anchor(:,2),'b^','MarkerSize',5,'lineWidth',2,'MarkerFaceColor','b');
        %naming all nodes
        temp1 = cellstr(num2str((1:size(anchor))'));
        for i=1:size(anchor)
            text(anchor(i,1)+1,anchor(i,2)+1, temp1(i));
        end
        %plot sink
        sink=7; %centre of hexagon is sink (node 7)
        p0=plot(centerx,centery,'k^','MarkerSize',5,'lineWidth',2,'MarkerFaceColor','y');
    end
end
legend([p0 p1],{'Sink','Primary anchor'})
end

function varargout = hexagonalGrid(bounds, origin, size, varargin)
%   usage:
%   PTS = hexagonalGrid(BOUNDS, ORIGIN, SIZE)
%   generate points, lying in the window defined by BOUNDS (=[xmin ymin
%   xmax ymax]), starting from origin with a constant step equal to size.
%   SIZE is constant and is equals to the length of the sides of each
%   hexagon.
size = size(1);
dx = 3*size;
dy = size*sqrt(3);
% consider two square grids with different centers
pts1 = squareGrid(bounds, origin + [0 0],        [dx dy], varargin{:});
pts2 = squareGrid(bounds, origin + [dx/3 0],     [dx dy], varargin{:});
pts3 = squareGrid(bounds, origin + [dx/2 dy/2],  [dx dy], varargin{:});
pts4 = squareGrid(bounds, origin + [-dx/6 dy/2], [dx dy], varargin{:});
% gather points
pts = [pts1;pts2;pts3;pts4];
% eventually compute also edges, clipped by bounds
% TODO : manage generation of edges
if nargout > 1
    edges = zeros([0 4]);
    x0 = origin(1);
    y0 = origin(2);
    % find all x coordinate
    x1 = bounds(1) + mod(x0-bounds(1), dx);
    x2 = bounds(3) - mod(bounds(3)-x0, dx);
    lx = (x1:dx:x2)';
    % horizontal edges : first find y's
    y1 = bounds(2) + mod(y0-bounds(2), dy);
    y2 = bounds(4) - mod(bounds(4)-y0, dy);
    ly = (y1:dy:y2)';
    
    % number of points in each coord, and total number of points
    ny = length(ly);
    nx = length(lx);
    
    if bounds(1)-x1+dx < size
        disp('intersect bounding box');
    end
    
    if bounds(3)-x2 < size
        disp('intersect 2');
        edges = [edges;repmat(x2, [ny 1]) ly repmat(bounds(3), [ny 1]) ly];
        x2 = x2-dx;
        lx = (x1:dx:x2)';
        nx = length(lx);
    end
    
    for i = 1:length(ly)
        ind = (1:nx)';
        tmpEdges = zeros(length(ind), 4);
        tmpEdges(ind, 1) = lx;
        tmpEdges(ind, 2) = ly(i);
        tmpEdges(ind, 3) = lx+size;
        tmpEdges(ind, 4) = ly(i);
        edges = [edges; tmpEdges];
    end
    
end
% process output arguments
if nargout > 0
    varargout{1} = pts;
    
    if nargout > 1
        varargout{2} = edges;
    end
end
end

function varargout = squareGrid(bounds, origin, size)
%   PTS = squareGrid(BOUNDS, ORIGIN, SIZE)
%   generate points, lying in the window defined by BOUNDS (=[xmin ymin
%   xmax ymax]), starting from origin with a constant step equal to size.
%   Example
%   PTS = squareGrid([0 0 10 10], [3 3], [4 2])
%   will return points :
%   [3 1;7 1;3 3;7 3;3 5;7 5;3 7;7 7;3 9;7 9];
% find all x coordinate
x1 = bounds(1) + mod(origin(1)-bounds(1), size(1));
x2 = bounds(3) - mod(bounds(3)-origin(1), size(1));
lx = (x1:size(1):x2)';
% find all y coordinate
y1 = bounds(2) + mod(origin(2)-bounds(2), size(2));
y2 = bounds(4) - mod(bounds(4)-origin(2), size(2));
ly = (y1:size(2):y2)';
% number of points in each coord, and total number of points
ny = length(ly);
nx = length(lx);
np = nx*ny;
% create points
pts = zeros(np, 2);
for i=1:ny
    pts( (1:nx)'+(i-1)*nx, 1) = lx;
    pts( (1:nx)'+(i-1)*nx, 2) = ly(i);
end
% process output
if nargout>0
    varargout{1} = pts;
end
end