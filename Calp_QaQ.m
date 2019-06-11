function tp_QaQ = Calp_QaQ(sysPara, simPara)
%Calp_QaQ - Calculate the transition matrices for the truncated MDP
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
% 2019.06; Last revision: 2019.06.11

%------------- BEGIN CODE --------------

%--- Initialization ---
tp_QaQ = cell(simPara.U+1, simPara.U+1 , 2);

%--- Calculate the transition matrices for the truncated MDP ---
for indQa = 1:1:(simPara.U+1)^2 * 2
    % Decompose indQa
    subQa = cell(1, 2 + 1);
    [subQa{:}] = ind2sub([simPara.U+1, simPara.U+1 , 2], indQa);
    arrQa = [subQa{:}];
    arrQ = arrQa(1:2);
    arra = arrQa(2 + 1);
    % Calculate the corresponding subsripts under aggregation
    arrAggQ = zeros(1, 2);
    arrAggQ(arrQ==1) = 1;
    arrAggQ(arrQ>=2 & arrQ<=sysPara.thre+1) = 2;
    arrAggQ(arrQ>=sysPara.thre+2 & arrQ<=simPara.U) = 3;
    arrAggQ(arrQ==simPara.U+1) = 4;
    % Calculate unit transition probabilities
    pUnit = CalUnit(sysPara, simPara);
    % Calculate tp_QaQ
    tp_QaQ{subQa{:}} = TruBd(pUnit, arrAggQ, arra);
end

%------------- END OF CODE --------------
end

%------------- BEGIN SUBFUNCTION(S) --------------

%--- Calculate unit transition probabilities ---
function pUnit = CalUnit(sysPara, simPara)
    pUnit = cell(2, 2, 2);
    % Calculate unit transition matrix
    a = sysPara.arrRate;
    for i = 1:1:2
        for j = 1:1:2
            s1 = sysPara.tranRate{i, j}(1);
            s2 = sysPara.tranRate{i, j}(2);
            pUnit{i, j, 1} = [s2*s1*(1-a), (1-s2)*s1*(1-a), 0; ...
                              s2*(s1*a+(1-s1)*(1-a)),(1-s2)*(s1*a+(1-s1)*(1-a)), 0; ...
                              s2*(1-s1)*a, (1-s2)*(1-s1)*a, 0];
            pUnit{i, j, 2} = [s1*s2*(1-a), s1*(s2*a+(1-s2)*(1-a)), s1*(1-s2)*a; ...
                              (1-s1)*s2*(1-a), (1-s1)*(s2*a+(1-s2)*(1-a)), (1-s1)*(1-s2)*a; ...
                              0, 0, 0];
        end
    end
end

%--- Calculate the transition probability under the boundary truncation ---
function trupBd = TruBd(pUnit, arrAggQ, arra)
    truTop = [0, 0, 0; 1, 1, 0; 0, 0, 1];
    truBtm = [1, 0, 0; 0, 1, 1; 0, 0, 0];
    truLeft = [0, 1, 0; 0, 1, 0; 0, 0, 1];
    truRight = [1, 0, 0; 0, 1, 0; 0, 1, 0];
    switch 10*arrAggQ(1)+arrAggQ(2)
        case 11
            trupBd = truTop*pUnit{1, 1, arra}*truLeft;
        case 12
            trupBd = truTop*pUnit{1, 1, arra};
        case 13
            trupBd = truTop*pUnit{1, 2, arra};
        case 14
            trupBd = truTop*pUnit{1, 2, arra}*truRight;
        case 21
            trupBd = pUnit{1, 1, arra}*truLeft;
        case 22
            trupBd = pUnit{1, 1, arra};
        case 23
            trupBd = pUnit{1, 2, arra};
        case 24
            trupBd = pUnit{1, 2, arra}*truRight;
        case 31
            trupBd = pUnit{2, 1, arra}*truLeft;
        case 32
            trupBd = pUnit{2, 1, arra};
        case 33
            trupBd = pUnit{2, 2, arra};
        case 34
            trupBd = pUnit{2, 2, arra}*truRight;
        case 41
            trupBd = truBtm*pUnit{2, 1, arra}*truLeft;
        case 42
            trupBd = truBtm*pUnit{2, 1, arra};
        case 43
            trupBd = truBtm*pUnit{2, 2, arra};
        case 44
            trupBd = truBtm*pUnit{2, 2, arra}*truRight;
        otherwise
            disp('Error in Calp_QaQ->CaltrupBd');
    end
end

%------------- END OF SUBFUNCTION(S) --------------
