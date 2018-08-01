% in this code we determine the matrix used to condition the markov model

clear variables


%% load vars
disp('loading...')
dzs = load(fullfile('..', 'data', 'dzs.mat'));
dz = dzs.dzs.dz; %
be = dzs.dzs.be; % bin edges
hc = dzs.dzs.hc;

bc = be(1) + cumsum( (be(2:end) - be(1:end-1)) ); % bin centers

markov_mat = zeros(length(bc)); % rows = to, cols = from
neldz = numel(dz); % number of elements in dz
dzp = permute(dz, [2, 3, 1]);

%% loop to determine next state for given bin
disp('determining matrix...')
for s = 1:length(bc)
    sidx = and(dzp >= be(s), dzp < be(s+1)); % indicies at current state
    sidxp1a = find(sidx) + numel(dzp(:, :, 1)); % index one slice below
    sidxp1 = sidxp1a(sidxp1a <= neldz);
    dzpsp1 = dzp(sidxp1); % dzp value for state plus 1
    hcs = histcounts(dzpsp1, be); % hist counts
    nhcs = hcs ./ nansum(hcs); % normalized histcounts
    markov_mat(:, s) = nhcs'; % into storage
end

figure()
histogram(dzpsp1, be, 'Normalization', 'probability')

%% plot the matrix
figure()
[x, y] = meshgrid(bc, bc);
surface(x, y, markov_mat, 'EdgeColor', 'k')
hold on;
% plot([min(x), max(x)], [min(y), max(y)], 'LineWidth', 1.5', 'k--')
axis square

%% save the data
mm.mm = markov_mat;
mm.be = be;
mm.bc = bc;
save(fullfile('..', 'data', 'markov_mat.mat'), 'mm')
