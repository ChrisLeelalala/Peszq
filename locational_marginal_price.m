function [ priceArr ] = locational_marginal_price( results )
%LOCATIONAL_MARGINAL_PRICE Calculate the locational marginal price
%   Generate the array of LMP from the result file of 
%   the system.


% Variables
bus = results.bus;
branch = results.branch;
gen = results.gen;
busNum = size(bus,1);
genNum = size(gen,1);
branchNum = size(branch,1);

priceArr = zeros(1,busNum);

for i=1:busNum
    priceArr(i) = bus(i,14);
end


end

