function simVar = SolveMDP(sysPara, simPara, simVar, tp_SaS)
%SolveMDP_DSA - 
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
% 2019.05; Last revision: 2019.06.06

%------------- BEGIN CODE --------------

%--- Initialize variables ---
curV = zeros([(simPara.U+1)*ones(1, sysPara.D), 2*ones(1, sysPara.D)]);
preV = zeros([(simPara.U+1)*ones(1, sysPara.D), 2*ones(1, sysPara.D)]);
aTable = zeros([(simPara.U+1)*ones(1, sysPara.D), 2*ones(1, sysPara.D)]);
spanV = Inf;
accuracy = 1e-2;

%--- Do value iteration ---
while spanV > accuracy
    % Update preV
    preV = curV;
    parfor indS = 1:1:(simPara.U+1)^sysPara.D * 2^sysPara.D
        % Calculate the index for the current state
        subS = cell(1, sysPara.D + sysPara.D);
        [subS{:}] = ind2sub([(simPara.U+1)*ones(1, sysPara.D), 2*ones(1, sysPara.D)], indS);
        % Calculate stage costs
        aveV = CalAveValue(sysPara, simPara, subS, tp_SaS, preV);
        % Update value functions
        [curV(indS), aTable(indS)] = min(aveV);
    end
    % Update aTable
    simVar.aTable = aTable;
    % Calculate the span of value functions to justify whether to terminate
    spanV = peak2peak(reshape(curV - preV, [], 1));
end

%------------- END OF CODE --------------
end

%------------- BEGIN SUBFUNCTION(S) --------------

%--- Calculate value functions for neighbor states ---
function aveV = CalAveValue(sysPara, simPara, subS, tp_SaS, V_S)
    aveV = zeros(1, sysPara.D);
    arrS = [subS{:}];
    % Calculate value functions
    neiV = zeros([3*ones(1, sysPara.D), 2*ones(1, sysPara.D)]);
    for inddS = 1:1:3^sysPara.D * 2^sysPara.D
        % Calculate the index for the change of the current state
        subdS = cell(1, sysPara.D + sysPara.D);
        [subdS{:}] = ind2sub(size(neiV), inddS);
        arrdS = [subdS{:}];
        arrSp1 = arrS+arrdS-2;
        subSp1 = num2cell(arrSp1);
        if min(arrSp1) >= 1 && max(arrSp1) <= simPara.U+1
            neiV(subdS{:}) = V_S(subSp1{:});
        end
    end
    % Calculate aveV
    for inda = 1:1:sysPara.D
        subAveV = num2cell([arrS, inda]);
        aveV(inda) = sum(reshape(neiV .* tp_SaS{subAveV{:}}, [], 1));
    end
    Q = arrS(1 : sysPara.D) - 1;
    aveV = aveV + sum(Q);
end

%------------- END OF SUBFUNCTION(S) --------------
