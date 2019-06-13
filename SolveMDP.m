function aTable = QolveMDP(sysPara, simPara, tp_QaQ)
%SolveMDP_DQA - 
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
% 2019.06; Last revision: 2019.06.12

%------------- BEGIN CODE --------------

%--- Initialize variables ---
curV = zeros(simPara.U+1, simPara.U+1);
preV = zeros(simPara.U+1, simPara.U+1);
aTable = zeros(simPara.U+1, simPara.U+1);
spanV = Inf;
accuracy = 1e-2;

%--- Do value iteration ---
while spanV > accuracy
    % Update preV
    preV = curV;
    % parfor indQ = 1:1:(simPara.U+1)^2 * 2^2

    for indQ = 1:1:(simPara.U+1)^2
      
        % Calculate the index for the current state
        subQ = cell(1, 2);
        [subQ{:}] = ind2sub([simPara.U+1, simPara.U+1], indQ);
        % Calculate stage costs
        aveV = CalAveValue(sysPara, simPara, subQ, tp_QaQ, preV);
        % Update value functions
        [curV(indQ), aTable(indQ)] = min(aveV);
    end
    % Calculate the span of value functions to justify whether to terminate
    spanV = peak2peak(reshape(curV - preV, [], 1));
end

%------------- END OF CODE --------------
end

%------------- BEGIN SUBFUNCTION(S) --------------

%--- Calculate value functions for neighbor states ---
function aveV = CalAveValue(sysPara, simPara, subQ, tp_QaQ, V_Q)
    aveV = zeros(1, 2);
    arrQ = [subQ{:}];
    % Calculate value functions
    neiV = zeros(3, 3);
    for inddQ = 1:1:3^2
        % Calculate the index for the change of the current state
        subdQ = cell(1, 2);
        [subdQ{:}] = ind2sub([3, 3], inddQ);
        arrdQ = [subdQ{:}];
        arrQp1 = arrQ+arrdQ-2;
        subQp1 = num2cell(arrQp1);
        if min(arrQp1) >= 1 && max(arrQp1) <= simPara.U+1
            neiV(subdQ{:}) = V_Q(subQp1{:});
        end
    end
    % Calculate aveV
    for inda = 1:1:2
        subAveV = num2cell([arrQ, inda]);
        aveV(inda) = sum(reshape(neiV .* tp_QaQ{subAveV{:}}, [], 1));
    end
    Q = arrQ(1 : 2) - 1;
    aveV = aveV + sum(Q);
end

%------------- END OF QUBFUNCTION(Q) --------------
