function nodedetail(in,f1,database_stddev,anchornumber,distError,database_path,database_pos)
figure(f1);

if 1<=in && in<=anchornumber
fprintf('Node %d is an Anchor node! \nLocalization error = 0 m \n',in);
fprintf('--------------------------------------------------------------------\n');
end
stddevinfo=database_stddev{in};
if isempty(stddevinfo)
    fprintf('Localization was not possible for node %d! \n',in);
    fprintf('--------------------------------------------------------------------\n');
elseif isnumeric(cell2mat(stddevinfo(1,5)))
    nearnodes=cell2mat(stddevinfo(1,2:5));
else
    nearnodes=cell2mat(stddevinfo(1,2:4));
end
fprintf('Nearest nodes to node %d are : %s \n',in,num2str(nearnodes));
fprintf('Localization error for node %d is %s m \n',in,num2str(distError(in)));
viscircles([database_pos(in,1) database_pos(in,2)],2.5,'lineWidth',1,'Color','y');
viscircles([database_pos(nearnodes(1),1) database_pos(nearnodes(1),2)],2.5,'lineWidth',1,'Color','r','LineStyle',':');
viscircles([database_pos(nearnodes(2),1) database_pos(nearnodes(2),2)],2.5,'lineWidth',1,'Color','r','LineStyle',':');
viscircles([database_pos(nearnodes(3),1) database_pos(nearnodes(3),2)],2.5,'lineWidth',1,'Color','r','LineStyle',':');
%line([database_pos(in,1) database_pos(nearnodes(1),1)],[database_pos(in,2) database_pos(nearnodes(1),2)],'color','k','LineStyle','--','HandleVisibility','off');
%line([database_pos(in,1) database_pos(nearnodes(2),1)],[database_pos(in,2) database_pos(nearnodes(2),2)],'color','k','LineStyle','--','HandleVisibility','off');
%line([database_pos(in,1) database_pos(nearnodes(3),1)],[database_pos(in,2) database_pos(nearnodes(3),2)],'color','k','LineStyle','--','HandleVisibility','off');
if numel(nearnodes)==4
    viscircles([database_pos(nearnodes(4),1) database_pos(nearnodes(4),2)],2.5,'lineWidth',1,'Color','r','LineStyle',':');
    %line([database_pos(in,1) database_pos(nearnodes(4),1)],[database_pos(in,2) database_pos(nearnodes(4),2)],'color','k','LineStyle','--','HandleVisibility','off');
end
shortestpath=database_path{in,1};
for i=1:numel(shortestpath)-1
    plot([database_pos(shortestpath(i),1) database_pos(shortestpath(i+1),1)],[database_pos(shortestpath(i),2) database_pos(shortestpath(i+1),2)],'color','y','HandleVisibility','off')
end
fprintf('Path to sink: [ %s ] \n',num2str(shortestpath));
fprintf('--------------------------------------------------------------------\n');