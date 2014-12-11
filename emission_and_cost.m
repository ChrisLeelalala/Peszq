function [ emission,cost ] = emission_and_cost( results,genCarbonArr )
%EMISSION_AND_COST Calculate carbon emission and cost
%   Generate results from the result file after opf


cost = results.f;
emission = genCarbonArr*results.gen(:,2);

end

