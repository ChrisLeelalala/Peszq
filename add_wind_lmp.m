function [ mpcResult ] = add_wind_lmp( lmpArr,mpcArg,windUnit )
%ADD_WIND_LMP Add 1MW wind unit by LMP
%   Generate mpc struct after adding from the array of
%   LMP and the of mpc struct before

% Find the position for max LMP
[maxLmp,maxPosition] = max(lmpArr);

mpcResult = mpcArg;

% Add wind power by 1MW
mpcResult.gen(maxPosition+33,9) = mpcResult.gen(maxPosition+33,9)+windUnit;
mpcResult.gen(maxPosition+33,4) = mpcResult.gen(maxPosition+33,4)+0.05*windUnit;
mpcResult.gen(maxPosition+33,5) = mpcResult.gen(maxPosition+33,5)-windUnit;
mpcResult.gen(maxPosition+33,8) = 1;

end

