% in this code we do any manipulation of the data needed before any other codes

clear variables


%% load vars
disp('loading...')
% z = load(fullfile('..', 'data', 'TDB_12_Dry_z_SUB.mat')); % this file is a subset to help run faster for dev
z = load(fullfile('..', 'data', 'TDB_12_Dry_z.mat'));
z = z.z; % 900 = t, 455 = x, 391 = y


%% clean out marine elements
disp('removing marine elements...')
sl = (1:900) * 0.25;
T = 0:900; % one element longer than scans
for t = T(2:end)
    slt = sl(t); % sea level at time t
    mart = squeeze( z(t, :, :) < slt ); % what is marine (below sl) at t
    z(t, mart) = NaN; % replace at identified indicies
end


%% determine histogram properties
disp('calculating dz and cleaning histogram...')
dz = z(2:end, :, :) - z(1:end-1, :, :); % vectorized dz
dz = cat(1, zeros(1, size(z, 2), size(z, 3)), dz); % unknown elevation change at time 1

dz16 = quantile(dz(:), 0.16); % 16th percentile
dz84 = quantile(dz(:), 0.84);
dz30 = quantile(dz(:), 0.30);
dz70 = quantile(dz(:), 0.70);
dz05 = quantile(dz(:), 0.05);
dz95 = quantile(dz(:), 0.95);

dz( and(dz <= dz05, dz >= dz95) ) = NaN; % trim the distribution to percentiles

% nbins = 5^2;
% binspacing = (dz95 - dz05) / (nbins);
% hbs = binspacing / 2;
% binedges = dz05-hbs:binspacing:dz95+hbs; % define bin edges manually for central bin on zero
binedges = -0.6875:0.125:1.6875;


%% plot it up
disp('plotting histogram...')
figure()
histogram(dz(randi(numel(dz), 100000, 1)), binedges, 'Normalization', 'probability');
xlabel('\Delta z', 'FontSize', 14)
ylabel('probability', 'FontSize', 14)
print('-dpng', '-r300', fullfile('..', 'figs', 'delta_hist.png'));


%% calculate stratigraphy
disp('looping to calculate stratigraphy')

strat = NaN(size(z)); % preallocate
strat(end, :, :) = z(end, :, :);

for t = T(end-1:-1:2)
    tmat = squeeze(z(t, :, :)); % matrix at t
    tp1mat = squeeze(strat(t+1, :, :)); % matrix from strat at t+1
    strat(t, :, :) = bsxfun(@min, tmat, tp1mat); % solution for elementwise minimum.
end

if false
    figure()
    [x, y] = meshgrid(1:size(z, 3), 1:size(z, 2));
    for t = 1:size(strat, 1)
        surf(x, y, squeeze(z(t, :, :)), 'EdgeColor', 'none')
        view([0 90])
        box on
        axis equal
        xlim([1 400])
        ylim([1 400])
        drawnow
        text(0.8, 0.8, ['t = ' num2str(t) 'h'], 'Units', 'Normalized')
        print('-dpng', '-r200', fullfile('..', 'figs', 'movs', sprintf('%03d.png', t)));
    end
end

%% subsample some random strat columns to save
disp('subsampling strat columns...')

rcols.rxs = randi(size(strat, 2), 100, 1);
rcols.rys = randi(size(strat, 3), 100, 1);

rcols.z = zeros(900, 100);
rcols.strat = zeros(900, 100);
for i = 1:100
    rcols.z(:,i) = z(:,rcols.rxs(i), rcols.rys(i));
    rcols.strat(:,i) = strat(:, rcols.rxs(i), rcols.rys(i));
end

%% prepare data for export and save it
disp('saving data...')
[hc] = histcounts(dz(:), binedges);
dzs.dz = dz;
dzs.hc = hc;
dzs.be = binedges;
save(fullfile('..', 'data', 'dzs.mat'), 'dzs')

save(fullfile('..', 'data', 'strat.mat'), 'strat')

save(fullfile('..', 'data', 'rcols.mat'), 'rcols')