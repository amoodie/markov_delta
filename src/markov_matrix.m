% in this code we determine the matrix used to condition the markov model

clear variables


%% load vars
disp('loading...')
dzs = load(fullfile('..', 'data', 'dzs.mat'));
dz = dzs.dzs.dz; %
be = dzs.dzs.be; % bin edges
hc = dzs.dzs.hc;

bc = be(1) + cumsum( (be(2:end) - be(1:end-1)) / 2 ); % bin centers

markov_mat = zeros(length(hc)); % rows = to, cols = from
neldz = numel(dz);

%% loop to determine next state for given bin
for s = 1:length(be)-1
    hcs = bc(s); % current state bin
    sidx = and(dz >= be(s), dz < be(s+1)); % indicies at current state
    sidxp1 = find(sidx)+1;
    sidxp1 = sidxp1(sidxp1 <= neldz);
    dzsp1 = dz(sidxp1); % dz value for state plus 1
    hcs = histcounts(dzsp1, be); % hist counts
    nhcs = hcs ./ sum(hcs); % normalized histcounts
    markov_mat(:, s) = nhcs'; % into storage
end

figure()
[x, y] = meshgrid(bc, bc);
surface(x, y, markov_mat, 'EdgeColor', 'k')
% image(markov_mat)

