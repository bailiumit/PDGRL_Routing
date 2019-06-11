function tp_SaS = Calp_SaS(sysPara, simPara)
%Calp_SaS - Calculate the transition matrices for the truncated MDP
%
% Syntax:  [~] = Main(curDay)
%
% Inputs:
%    curDay - Current day(args)        
%
% Outputs:
%    none
%
% Example: 
%    none
%
% Other m-files required: turningChoice.mat, complianceRate.mat
% Subfunctions: none
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Laboratory for Information and Decision Systems, Massachusetts Institute of Technology, Cambridge, MA
% E-mail: bailiu@mit.edu
% 2019.06; Last revision: 2019.06.03

%------------- BEGIN CODE --------------

%--- Initialization ---
tp_SaS = cell([(simPara.U+1)*ones(1, sysPara.D), 2*ones(1, sysPara.D), sysPara.D]);

%--- Calculate the transition matrices for the truncated MDP ---
for indSa = 1:1:(simPara.U+1)^sysPara.D * 2^sysPara.D * sysPara.D
    % Decompose indSa
    subSa = cell(1, sysPara.D + sysPara.D + 1);
    [subSa{:}] = ind2sub([(simPara.U+1)*ones(1, sysPara.D), 2*ones(1, sysPara.D), sysPara.D], indSa);
    arrSa = [subSa{:}];
    arrQ = arrSa(1:sysPara.D);
    arrCon = arrSa(sysPara.D+1:sysPara.D + sysPara.D);
    arra = arrSa(sysPara.D + sysPara.D + 1);
    % Calculate the corresponding subsripts under aggregation
    arrAggQ = zeros(1, sysPara.D);
    arrAggQ(arrQ==1) = 1;
    arrAggQ(arrQ>=2 & arrQ<=simPara.U) = 2;
    arrAggQ(arrQ==simPara.U+1) = 3;
    % Calculate unit transition probabilities
    pUnit = CalUnit(sysPara, simPara, arrCon);
    % Calculate the transition probability under the boundary truncation
    trupBd = TruBd(pUnit, arrAggQ, arra);
    % Calculate tp_SaS
    trup = zeros([3 * ones(1, sysPara.D), 2 * ones(1, sysPara.D)]);
    p_Con1 = sysPara.conProb(1);
    p_Con2 = sysPara.conProb(2);
    trup(:, :, 1, 1) = trupBd*(1-p_Con1)*(1-p_Con2);
    trup(:, :, 1, 2) = trupBd*(1-p_Con1)*p_Con2;
    trup(:, :, 2, 1) = trupBd*p_Con1*(1-p_Con2);
    trup(:, :, 2, 2) = trupBd*p_Con1*p_Con2;        
    tp_SaS{subSa{:}} = trup;
end

%------------- END OF CODE --------------
end

%------------- BEGIN SUBFUNCTION(S) --------------

%--- Calculate unit transition probabilities ---
function pUnit = CalUnit(sysPara, simPara, arrCon)
    pUnit = cell(1, 2);
    % Calculate unit transition matrix
    p_Arr1 = sysPara.arrRate(1);
    p_Arr2 = sysPara.arrRate(2);
    p_Suc1 = sysPara.sucProb(1);
    p_Suc2 = sysPara.sucProb(2);
    % Consider the influence of connectivity
    if arrCon(1) == 1
        p_Suc1 = 0;
    end
    if arrCon(2) == 1
        p_Suc2 = 0;
    end
    pUnit{1} = [0, (1-p_Arr1)*p_Suc1*(1-p_Arr2), (1-p_Arr1)*p_Suc1*p_Arr2; ...
            0, (p_Arr1*p_Suc1+(1-p_Arr1)*(1-p_Suc1))*(1-p_Arr2), (p_Arr1*p_Suc1+(1-p_Arr1)*(1-p_Suc1))*p_Arr2; ...
            0, p_Arr1*(1-p_Suc1)*(1-p_Arr2), p_Arr1*(1-p_Suc1)*p_Arr2];
    pUnit{2} = [0, 0, 0; ...
            (1-p_Arr2)*p_Suc2*(1-p_Arr1), (p_Arr2*p_Suc2+(1-p_Arr2)*(1-p_Suc2))*(1-p_Arr1), p_Arr2*(1-p_Suc2)*(1-p_Arr1); ...
            (1-p_Arr2)*p_Suc2*p_Arr1, (p_Arr2*p_Suc2+(1-p_Arr2)*(1-p_Suc2))*p_Arr1, p_Arr2*(1-p_Suc2)*p_Arr1];
end

%--- Calculate the transition probability under the boundary truncation ---
function trupBd = TruBd(pUnit, arrAggQ, arra)
    truTop = [0, 0, 0; 1, 1, 0; 0, 0, 1];
    truBtm = [1, 0, 0; 0, 1, 1; 0, 0, 0];
    truLeft = [0, 1, 0; 0, 1, 0; 0, 0, 1];
    truRight = [1, 0, 0; 0, 1, 0; 0, 1, 0];
    switch 10*arrAggQ(1)+arrAggQ(2)
        case 11
            trupBd = truTop*pUnit{arra}*truLeft;
        case 12
            trupBd = truTop*pUnit{arra};
        case 13
            trupBd = truTop*pUnit{arra}*truRight;
        case 21
            trupBd = pUnit{arra}*truLeft;
        case 22
            trupBd = pUnit{arra};
        case 23
            trupBd = pUnit{arra}*truRight;
        case 31
            trupBd = truBtm*pUnit{arra}*truLeft;
        case 32
            trupBd = truBtm*pUnit{arra};
        case 33
            trupBd = truBtm*pUnit{arra}*truRight;
        otherwise
            disp('Error in Calp_SaS->CaltrupBd');
    end
end

%------------- END OF SUBFUNCTION(S) --------------
