% in this code we calculate statistics of the stratigraphic deposit to compare with the Markov model




%% mean record time? 



%% stasis fraction?
% The average time of the reocrd where there is "no change"
%dz_strat=permute(strat(time,:,:),[2 3 1]);
%dz_strat_prev=permute(z(time-1,:,:),[2 3 1]);
%d_dz_strat=dz_strat-dz_strat_prev;
%dtopo2=dtopo;
%RSLR=0.25-dtopo2;

dz_strat = zeros(size(strat)); % preallocate
d_strat_cond = NaN(size(strat));
d_strat_cond(2, :, :) = strat(2, :, :);

for t = T(3:end-1)
    d_strat = permute(strat(t,:,:),[2 3 1]);
    %dz before is higher than it will not be preserved, 
    %dz after is lower than it will not be preserved
    d_strat_cond = double(and(d_strat(t)>=d_strat(t-1),(d_strat(t)<=d_strat(t+1))));
    dz_strat(t,:,:)= int8(d_strat_cond);
end
  
