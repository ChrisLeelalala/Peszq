function [ intensityArr ] = direct_carbon_intensity( results,genCarbonArr )
%DIRECT_CARBON_INTENSITY Calculate direct carbon intensity
%   Generate the array of nodal DCI from the result file of 
%   the system and the array of generators' CI.


% Variables
bus = results.bus;
branch = results.branch;
gen = results.gen;
busNum = size(bus,1);
genNum = size(gen,1);
branchNum = size(branch,1);

pi = zeros(1,busNum);
au = eye(busNum);
pgc = zeros(busNum,1);

% Determine pi array
for i=1:branchNum
    % Add each pt to the end node
    if branch(i,14)>0
        pi(branch(i,2)) = pi(branch(i,2))-branch(i,16);
    else 
        pi(branch(i,1)) = pi(branch(i,1))-branch(i,14);
    end
end

for i=1:genNum
    % Add each pg to the node
    pi(gen(i,1)) = pi(gen(i,1))+gen(i,2);
end

% Determine au array
for i=1:branchNum
    if branch(i,14)>0
        au(branch(i,2),branch(i,1))=branch(i,16)/pi(branch(i,1));
    else
        au(branch(i,1),branch(i,2))=branch(i,14)/pi(branch(i,2));
    end
end

% Determine pgc vector
for i=1:genNum
    pgc(gen(i,1),1)=pgc(gen(i,1),1)+gen(i,2)*genCarbonArr(i);
end

ci = (au^-1)*pgc;
intensityArr = (ci')./pi;

end

