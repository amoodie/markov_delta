% in this code we evaluate the markov model in a single stratigraphic column

%% load vars
disp('loading...')
dzs = load(fullfile('..', 'data', 'markov_mat.mat'));
be = mm.be; % bin edges
bc = mm.bc; % bin centers
mm = mm.mm; % markov matrix

%% aux vars
beidx = cumsum(be);
mmcs = cumsum(mm, 1);

%% evaluate the model 1 time
RSLR = 0.25; % need to make sure to add RSLR on each step to make a net aggradation
BL = 0; % base level
z = 0; 
dz = 0; % random value for initial from within interval
for t = 1:900
    cidx = find(dz > be, 1, 'first') - 1; % first greater than minus one is idx

    % generate a random number in interval [0 1]
    rand(1)

    % determine which prob bin it falls in to
    
    % go that far in z
    
    % as RSLR in z
    
    
end



%% evaluate 1000 times and compute stats