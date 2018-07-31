% in this code we determine the matrix used to condition the markov model

clear variables


%% load vars
disp('loading...')
dzs = load(fullfile('..', 'data', 'dzs.mat'));
dz = dzs.dzs.dz; %
be = dzs.dzs.be; % bin edges
hc = dzs.dzs.hc;

bc = cumsum( (be(2:end) - be(1:end-1)) / 2 ); % bin centers

markov_mat = zeros(length(hc)); % rows = to, cols = from

%% loop to determine next state for given bin
for s = 1:length(be)-1
    hcs = bc(s); % current state bin
    sidx = and(dz(1:end-1, :, :) >= be(s), dz(1:end-1, :, :) < be(s+1)); % indicies at current state
    dzsp1 = dz(find(sidx)+1); % dz value for state plus 1
    hcs = histcounts(dzsp1, be); % hist counts
    nhcs = hcs ./ sum(hcs); % normalized histcounts
    markov_mat(:, s) = nhcs'; % into storage
end

figure()
[x, y] = meshgrid(bc, bc);
surface(x, y, markov_mat, 'EdgeColor', 'k')
% image(markov_mat)

