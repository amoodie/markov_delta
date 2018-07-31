% in this code we do any manipulation of the data needed before any other codes

clear variables

%%
disp('loading...')
z = load(fullfile('..', 'data', 'TDB_12_Dry_z.mat'));
z = z.z; % 900 = t, 455 = x, 391 = y

%%
sl = (1:900) .* 0.25; % sea level at each time t
% time = 2:900; % shouldn't time start at 0 and we index it beyond that?
% topo = permute(z(time, :, :), [2, 3, 1]);
% topoprev = permute(z(time-1, :, :),[2, 3, 1]);
% dtopo = topo - topoprev;
% dtopo2 = dtopo;
% RSLR = 0.25 - dtopo2;
% 
% for i = 2:900
%     x = sl(i);
%     topo = permute(z(i,:,:),[2 3 1]);
%     topo(topo(:)<=x)=NaN;
%     toposave(i,:,:)=permute(topo,[3,1,2]);
% end

disp('removing marine elements...')
T = 0:900; % one element longer than scans
for t = T(2:end)
    slt = sl(t); % sea level at time t
    mart = squeeze( z(t, :, :) < slt ); % what is marine (below sl) at t
    z(t, mart) = NaN; % replace at identified indicies
end

%% determine histogram properties
disp('calculating dz and cleaning histogram...')
dz = z(2:end, :, :) - z(1:end-1, :, :); % vectorized dz

dz16 = quantile(dz(:), 0.16); % 16th percentile
dz84 = quantile(dz(:), 0.84);
dz30 = quantile(dz(:), 0.30);
dz70 = quantile(dz(:), 0.70);

dz( and(dz <= dz16, dz >= dz84) ) = NaN; % trim the distribution to percentiles

nbins = 7^2;
binspacing = (dz84 - dz16) / (nbins - 1);
hbs = binspacing / 2;
binedges = [dz16-hbs:binspacing:0-hbs, 0+hbs:binspacing:dz84+hbs]; % define bin edges manually for central bin on zero

%% plot it up
disp('plotting histogram...')
figure()
histogram(dz(randi(numel(dz), 10000, 1)), binedges);

%% calculate stratigraphy 
disp('looping to calculate stratigraphy')
strat = NaN(size(dz)); % preallocate
strat(end, :, :) = z(end, :, :);
for t = size(z, 1)-1:-1:1
%     strat(t, :, :) = min([squeeze(z(t, :, :)), squeeze(strat(t+1, :, :))]); % not elementwise
    tmat = squeeze(z(t, :, :));
    tp1mat = squeeze(z(t+1, :, :));
    strat(t, :, :) = ((tmat+tp1mat) - abs(tmat-tp1mat))/2; % solution for elementwise minimum
end

%% prepare data for export and save it
[hc] = histcounts(dz(:), binedges);

save(fullfile('..', 'data', 'strat.m'), 'strat')


