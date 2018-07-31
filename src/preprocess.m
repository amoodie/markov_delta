% in this code we do any manipulation of the data needed before any other codes

clear variables


%% load vars
disp('loading...')
z = load(fullfile('..', 'data', 'TDB_12_Dry_z_SUB.mat')); % this file is a subset to help run faster for dev
% z = load(fullfile('..', 'data', 'TDB_12_Dry_z.mat'));
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
dz = cat(1, NaN(1, size(z, 2), size(z, 3)), dz); % unknown elevation change at time 1

dz16 = quantile(dz(:), 0.16); % 16th percentile
dz84 = quantile(dz(:), 0.84);
dz30 = quantile(dz(:), 0.30);
dz70 = quantile(dz(:), 0.70);
dz05 = quantile(dz(:), 0.05);
dz95 = quantile(dz(:), 0.95);

dz( and(dz <= dz05, dz >= dz95) ) = NaN; % trim the distribution to percentiles

nbins = 5^2;
binspacing = (dz95 - dz05) / (nbins);
hbs = binspacing / 2;
binedges = dz05-hbs:binspacing:dz95+hbs; % define bin edges manually for central bin on zero


%% plot it up
disp('plotting histogram...')
figure()
histogram(dz(randi(numel(dz), 100000, 1)), binedges);


%% calculate stratigraphy 
disp('looping to calculate stratigraphy')
strat = NaN(size(dz)); % preallocate
strat(end, :, :) = z(end, :, :);
for t = size(z, 1)-1:-1:1
%     strat(t, :, :) = min([squeeze(z(t, :, :)), squeeze(strat(t+1, :, :))]); % not elementwise
    tmat = squeeze(z(t, :, :));
    tp1mat = squeeze(z(t+1, :, :));
    strat(t, :, :) = bsxfun(@min, tmat, tp1mat); % solution for elementwise minimum
end


%% prepare data for export and save it
[hc] = histcounts(dz(:), binedges);
dzs.dz = dz;
dzs.hc = hc;
dzs.be = binedges;
save(fullfile('..', 'data', 'dzs.mat'), 'dzs')

save(fullfile('..', 'data', 'strat.mat'), 'strat')

