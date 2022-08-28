function allp = getpaths(s, t, pos, startpoint, endpoint )

% Euclidian distances
d = sqrt(sum((pos(s,:)-pos(t,:)).^2,2));
A = sparse(s, t, d, size(pos,1), size(pos,1));
A = A+A';
%tempo = 1;
allp = AllPath(A, startpoint, endpoint);
% PlotandAnimation(A, allp, tempo, pos);

% %%
% function PlotandAnimation(A, allp, tempo, pos)
% n = size(A,1);
% nodenames = arrayfun(@(i) sprintf('(%d)', i), 1:n, 'unif', 0);
% % Plot and animation
% figure
% G = graph(A);
% h = plot(G, 'XData', pos(:,1), 'YData', pos(:,2));
% labelnode(h, 1:n, nodenames)
% th = title('');
% colormap([0.6; 0]*[1 1 1]);
% E = table2array(G.Edges);
% E = sort(E(:,1:2),2);
% np = length(allp);
% for k=1:np
%     pk = allp{k};
%     pkstr = nodenames(pk);
%     s = sprintf('%s -> ',pkstr{:});
%     s(end-3:end) = [];
%     i = sub2ind(size(A),pk(1:end-1),pk(2:end));
%     d = full(sum(A(i)));
%     fprintf('%s (d=%g)\n', s, d);
%     Ek = sort([pk(1:end-1); pk(2:end)],1)';
%     b = ismember(E, Ek, 'rows');
%     set(h, 'EdgeCData', b, 'LineWidth', 0.5+1.5*b);
%     set(th, 'String', sprintf('path %d/%d (d=%3.1f)', k, np, d));
%     pause(tempo);
% end
% end

    function p = AllPath(A, s, t)
        % Find all paths from node #s to node #t
        % INPUTS:
        %   A is (n x n) ajadcent matrix (preferable sparse)
        %       it can be symmetric (graph) or unsymmetric (digraph)
        %   s, t are node number, in (1:n)
        %   NOTE: for digraph, if t is NaN, all paths started from s and ended at a
        %       leaf are returned
        % OUTPUT
        %   p is M x 1 cell array, each contains array of
        %   nodes of the path, (it starts with s ends with t)
        %   Nodes are visited at most once.
        
        if isgraph(A)
            % graph
            G = graph(A);
            [~, d] = shortestpath(G, s, t);
            if isfinite(d)
                p = AllPathHelper(A, s, t);
            else
                p = {};
            end
        else
            % digraph
            if nargin < 3 || isempty(t)
                t = NaN;
            end
            tnotprovide = ~isfinite(t);
            if tnotprovide
                % connect the leaf to a single dummy node t
                n = size(A,2);
                [ss,tt] = find(A);
                leaf = setdiff(tt,ss);
                A(n+1,n+1) = 0;
                A(:,n+1) = sparse(leaf, 1, 1, n+1, 1);
                t = n+1;
            end
            G = digraph(A);
            [~, d] = shortestpath(G, s, t);
            if isfinite(d)
                p = AllPathHelper(A.', s, t);
                if tnotprovide
                    % remove the dummy node
                    for k=1:length(p)
                        p{k} = p{k}(1:end-1);
                    end
                end
            else
                p = {};
            end
        end
    end % AllPath

%%
    function tf = isgraph(A)
        A = spones(A);
        tf = nnz(A-A')==0;
    end % isgraph

%%
    function p = AllPathHelper(AT, s, t)
        % Find all paths from node #s to node #t
        % INPUTS:
        %   AT is (n x n) transposed of the ajadcent matrix
        %   s, t are node number, in (1:n)
        % OUTPUT
        %   p is M x 1 cell array, each contains array of
        %   nodes of the path, (it starts with s ends with t)
        %   nodes are visited at most once.
        
        if s == t
            p =  {s};
            return
        end
        p = {};
        As = AT(:,s);
        As(s) = 0;
        if nnz(As)==0
            return
        end
        neig = find(As);
        AT(:,s) = 0;
        AT(s,:) = 0;
        neig = reshape(neig,1,[]);
        for n=neig
            p = [p; AllPathHelper(AT,n,t)]; %#ok
        end
        for k=1:length(p)
            p{k} = [s, p{k}];
        end
    end % AllPathHelper
end