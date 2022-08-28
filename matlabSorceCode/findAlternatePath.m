function db_path = findAlternatePath(db_path,db_neighbour,deadnode)

for k=size(db_path,1):-1:1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% size(db_path,1):-1:1??
    if k == deadnode
        continue;
    end
    temp10=db_path{k};
    for m=1:numel(temp10)
        if temp10(m) == deadnode
            %re-find path to sink
            fprintf('Node %s -> Old path       -> [ %s ] \n',num2str(k),num2str(temp10));
            temp1 = k; % temp10(m-1)=previous node of dead node
            temp2 = db_neighbour{temp1,1};
            temp2 = temp2(temp2~=deadnode);
            %temp2 = temp2(temp2~=(i+anchornumber));
            temp3 = zeros(size(temp2,1),1); %sink-path distances of neighbours
            for n=1:size(temp2,1)
                temp3(n) = db_path{temp2(n),2};
            end
            [temp4,temp5] = sort(temp3);
            temp6 = temp2(temp5); %sorted neighbour list wrt low to high path distance
            temp8 = 0;
            for n=1:size(temp6,1)
                temp7=db_path{temp6(n),1};
                for p=1:size(temp7,2)
                    if temp7(p) == deadnode
                        break;
                    end
                    if temp7(p) ~= deadnode && p == size(temp7,2)
                        temp8 = temp7;
                        break;
                    end
                end
                if temp8 ~= 0
                    break;
                end
            end
            temp2 = temp10(1:find(temp10 == temp1));
            temp9 = [temp2 temp8];
            fprintf('        -> Alternate path -> [ %s ] \n',num2str(temp9));
            
            %updating this path in db_path
            db_path(k,1)={temp9};
            temp11=db_neighbour{k,1};
            temp12=db_neighbour{k,2};
            temp13=temp12(temp11 == temp7(1));
            db_path(k,2)={temp4(n)+temp13}; %%%%%%%%%%%%%%%%%% check n here %%%%%%%%%%%%%%%%%%%%%%%
        end
    end
end
end