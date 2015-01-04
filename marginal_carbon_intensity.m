function [ intensityArr ] = marginal_carbon_intensity( mpcArg,results,genCarbonArr )
%MARGINAL_CARBON_INTENSITY Calculate marginal carbon intensity
%   Generate the array of nodal MCI from the mpc file of 
%   the system, result file and the array of generators' CI.


% Variables
bus = mpcArg.bus;
branch = mpcArg.branch;
gen = mpcArg.gen;
busNum = size(bus,1);
genNum = size(gen,1);
branchNum = size(branch,1);

intensityArr = zeros(1,busNum);

% Determine original emission
startEmission = genCarbonArr*results.gen(:,2);

% Determine the emission increase when 1MW load was added to each bus
for i=1:busNum
    mpcTmp = mpcArg;
    mpcTmp.bus(i,3) = mpcTmp.bus(i,3)+1;
    resultsTmp = runopf(mpcTmp);
    endEmission = genCarbonArr*resultsTmp.gen(:,2);
    intensityArr(i) = endEmission-startEmission;
end

end

