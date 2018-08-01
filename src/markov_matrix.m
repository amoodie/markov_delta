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
neldz = numel(dz); % number of elements in dz
dzp = permute(dz, [3, 2, 1]);

%% loop to determine next state for given bin
disp('determining matrix...')
for s = 1:length(bc)
%     hcs = bc(s); % current state bin
    sidx = and(dzp >= be(s), dzp < be(s+1)); % indicies at current state
    sidxp1a = find(sidx) + numel(dzp(:, :, 1)); % index one slice below
    sidxp1 = sidxp1a(sidxp1a <= neldz);
    dzsp1 = dz(sidxp1); % dz value for state plus 1
    hcs = histcounts(dzsp1, be); % hist counts
    nhcs = hcs ./ sum(hcs); % normalized histcounts
    markov_mat(:, s) = nhcs'; % into storage
end

%% plot the matrix
figure()
[x, y] = meshgrid(bc, bc);
surface(x, y, markov_mat, 'EdgeColor', 'k')
% image(markov_mat)

j=1;