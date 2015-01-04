function [ mpcResult ] = add_wind_dci( dciArr,mpcArg,windUnit )
%ADD_WIND_DCI Add 1MW wind unit by DCI
%   Generate mpc struct after adding from the array of
%   DCI and the of mpc struct before

% Find the position for max DCI
[maxDci,maxPosition] = max(dciArr);

mpcResult = mpcArg;

% Add wind power by 1MW
mpcResult.gen(maxPosition+33,9) = mpcResult.gen(maxPosition+33,9)+windUnit;
mpcResult.gen(maxPosition+33,4) = mpcResult.gen(maxPosition+33,4)+0.05*windUnit;
mpcResult.gen(maxPosition+33,5) = mpcResult.gen(maxPosition+33,5)-windUnit;
mpcResult.gen(maxPosition+33,8) = 1;

end

