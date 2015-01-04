function [ outMatrix ] = main_out( mpcArg )
%MAINOUT The main output generated function
%   Generates the matrix of every point in 3D graph
%   including the following parameters: carbon tax, 
%   amount of wind unit, carbon emission, and cost.
%   mpcArg should be case24_ieee_rts

% Constant definition
minCarbonTax = 0; % $/tonne
maxCarbonTax = 0;
carbonTaxIncre = 5;

thermalBid = 50; % $/MWh
hydroBid = 0.001;
nuclearBid = 7;
windBid = 100;

thermalCarbon = 0.9; % tonne/MWh

windUnit = 1; % MW
maxWindNum = 100; % Number of units
% End constant definiton

% Read gen, gencost, and carbon emission data 
[genData,genText] = xlsread('gen');
[gencostData,gencostText] = xlsread('gencost');
[branchData,branchText] = xlsread('branch');
[carbonData,carnbonText] = xlsread('carbonEmission');

% Variables
mpcInit = mpcArg;
genNum = size(genData,1);
genCarbonArr = carbonData';

% mpcInit initialization
mpcInit.gen = genData;
mpcInit.gencost = gencostData;
mpcInit.branch = branchData;

mpcInitCopy =mpcInit;

% Output file
outputDci = cell(21000+1,4);
outputDci{1,1}='carbon tax';
outputDci{1,2}='wind capacity';
outputDci{1,3}='emission(t/h)';
outputDci{1,4}='cost($/h)';
outputMci = outputDci;
outputLmp = outputDci;

outputCarbon = cell(21000+1,74);
outputCarbon{1,1} = 'carbon tax';
outputCarbon{1,2} = 'wind capacity';
for i=3:74
    outputCarbon{1,i} = mod(i-2,24);
end

outputNodalWind = cell(21000+1,74);
outputNodalWind{1,1} = 'carbon tax';
outputNodalWind{1,2} = 'capacity';
for i=3:74
    outputNodalWind{1,i} = mod(i-2,24);
end

outputNodalWind_1=outputNodalWind;
outputNodalWind_2=outputNodalWind;
outputNodalWind_3=outputNodalWind;
outputNodalWind_4=outputNodalWind;


% Flags
dciRow = 2;
mciRow = 2;
lmpRow = 2;
carbonRow = 2;
nodalWindRow = 2;
nodalWindRow_1 = 2;
nodalWindRow_2 = 2;
nodalWindRow_3 = 2;
nodalWindRow_4 = 2;

for i=minCarbonTax:carbonTaxIncre:maxCarbonTax % Carbon tax iteration
    % Add cost data by carbon tax
    mpcInit = mpcInitCopy; % Initialize
    for j=1:genNum
        mpcInit.gencost(j,6) = mpcInit.gencost(j,6)+i*genCarbonArr(j);
    end
    
    % Three mpc structs
    mpcDci = mpcInit;
    mpcMci = mpcInit;
    mpcLmp = mpcInit;
    
    for j=1:maxWindNum % Wind unit iteration
        % Run opf and calculate emission and cost
        resultsDci = runopf(mpcDci);
        resultsMci = runopf(mpcMci);
        resultsLmp = runopf(mpcLmp);
        [emissionDci,costDci] = emission_and_cost(resultsDci,genCarbonArr);
        [emissionMci,costMci] = emission_and_cost(resultsMci,genCarbonArr);
        [emissionLmp,costLmp] = emission_and_cost(resultsLmp,genCarbonArr);
        
        % Write data
        outputDci{dciRow,1} = i;
        outputDci{dciRow,2} = j-1;
        outputDci{dciRow,3} = emissionDci;
        outputDci{dciRow,4} = costDci;
        
        outputMci{mciRow,1} = i;
        outputMci{mciRow,2} = j-1;
        outputMci{mciRow,3} = emissionMci;
        outputMci{mciRow,4} = costMci;
        
        outputLmp{lmpRow,1} = i;
        outputLmp{lmpRow,2} = j-1;
        outputLmp{lmpRow,3} = emissionLmp;
        outputLmp{lmpRow,4} = costLmp;
        
        % Add row by 1
        dciRow = dciRow+1;
        mciRow = mciRow+1;
        lmpRow = lmpRow+1;
        
        % Calculate dci, mci, lmp of each node
        dciArray = direct_carbon_intensity(resultsDci,genCarbonArr);
        mciArray = marginal_carbon_intensity(mpcMci,resultsMci,genCarbonArr);
        lmpArray = locational_marginal_price(resultsLmp);
        
        % Write carbon intensity file
        outputCarbon{carbonRow,1} = i;
        outputCarbon{carbonRow,2} = j;
        for k=3:26
            outputCarbon{carbonRow,k} = dciArray(k-2);
        end
        for k=27:50
            outputCarbon{carbonRow,k} = mciArray(k-26);
        end
        for k=51:74
            outputCarbon{carbonRow,k} = lmpArray(k-50);
        end
        carbonRow = carbonRow+1;
        
        % Add wind unit
        mpcDci = add_wind_dci(dciArray,mpcDci,windUnit);
        mpcMci = add_wind_mci(mciArray,mpcMci,windUnit);
        mpcLmp = add_wind_lmp(lmpArray,mpcLmp,windUnit);
        
        % Write wind data for each node when all wind added
        if mod(j,20)==0
            outputNodalWind{nodalWindRow,1} = i;
            outputNodalWind{nodalWindRow,2} = j;
            for k=3:26
                outputNodalWind{nodalWindRow,k} = mpcDci.gen(k+31,9);
            end
            for k=27:50
                outputNodalWind{nodalWindRow,k} = mpcMci.gen(k+7,9);
            end
            for k=51:74
                outputNodalWind{nodalWindRow,k} = mpcLmp.gen(k-17,9);
            end
            nodalWindRow = nodalWindRow+1;
        end
        
%         if j==2000
%             outputNodalWind{nodalWindRow,1} = i;
%             for k=2:25
%                 outputNodalWind{nodalWindRow,k} = mpcDci.gen(k+32,9);
%             end
%             for k=26:49
%                 outputNodalWind{nodalWindRow,k} = mpcMci.gen(k+8,9);
%             end
%             for k=50:73
%                 outputNodalWind{nodalWindRow,k} = mpcLmp.gen(k-16,9);
%             end
%             nodalWindRow = nodalWindRow+1;
%         end
%         if j==100
%             outputNodalWind_1{nodalWindRow_1,1} = i;
%             for k=2:25
%                 outputNodalWind_1{nodalWindRow_1,k} = mpcDci.gen(k+32,9);
%             end
%             for k=26:49
%                 outputNodalWind_1{nodalWindRow_1,k} = mpcMci.gen(k+8,9);
%             end
%             for k=50:73
%                 outputNodalWind_1{nodalWindRow_1,k} = mpcLmp.gen(k-16,9);
%             end
%             nodalWindRow_1 = nodalWindRow_1+1;
%         end
%         if j==500
%             outputNodalWind_2{nodalWindRow_2,1} = i;
%             for k=2:25
%                 outputNodalWind_2{nodalWindRow_2,k} = mpcDci.gen(k+32,9);
%             end
%             for k=26:49
%                 outputNodalWind_2{nodalWindRow_2,k} = mpcMci.gen(k+8,9);
%             end
%             for k=50:73
%                 outputNodalWind_2{nodalWindRow_2,k} = mpcLmp.gen(k-16,9);
%             end
%             nodalWindRow_2 = nodalWindRow_2+1;
%         end
%         if j==1000
%             outputNodalWind_3{nodalWindRow_3,1} = i;
%             for k=2:25
%                 outputNodalWind_3{nodalWindRow_3,k} = mpcDci.gen(k+32,9);
%             end
%             for k=26:49
%                 outputNodalWind_3{nodalWindRow_3,k} = mpcMci.gen(k+8,9);
%             end
%             for k=50:73
%                 outputNodalWind_3{nodalWindRow_3,k} = mpcLmp.gen(k-16,9);
%             end
%             nodalWindRow_3 = nodalWindRow_3+1;
%         end
%         if j==1500
%             outputNodalWind_4{nodalWindRow_4,1} = i;
%             for k=2:25
%                 outputNodalWind_4{nodalWindRow_4,k} = mpcDci.gen(k+32,9);
%             end
%             for k=26:49
%                 outputNodalWind_4{nodalWindRow_4,k} = mpcMci.gen(k+8,9);
%             end
%             for k=50:73
%                 outputNodalWind_4{nodalWindRow_4,k} = mpcLmp.gen(k-16,9);
%             end
%             nodalWindRow_4 = nodalWindRow_4+1;
%         end
        
    end % End wind unit iteration
end % End carbon tax iteration

xlswrite('dci.xlsx',outputDci);
xlswrite('mci.xlsx',outputMci);
xlswrite('lmp.xlsx',outputLmp);
xlswrite('carbon_intensity.xlsx',outputCarbon);
xlswrite('nodal_wind.xlsx',outputNodalWind);
% xlswrite('nodal_wind_1.xlsx',outputNodalWind_1);
% xlswrite('nodal_wind_2.xlsx',outputNodalWind_2);
% xlswrite('nodal_wind_3.xlsx',outputNodalWind_3);
% xlswrite('nodal_wind_4.xlsx',outputNodalWind_4);

end

