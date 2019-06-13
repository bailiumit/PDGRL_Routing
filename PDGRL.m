function [simVar, a_t] = PDGRL(sysPara, simPara, simVar, Q_t)
%PDGRL_DQA - 
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
% 2019.06; Last revision: 2019.06.13

%------------- BEGIN CODE --------------

%--- Learn the optimal estimated policy ---

if simVar.isIni && simVar.isLearn
    % Estimate the trasition probabilities
    simVar = EstQaQ(sysPara, simPara, simVar);
    % Obtain optimal policy for the estimated MDP
    simVar.aTable = SolveMDP(simPara, simVar.tp_QaQ);
    % Save variables
    save('PDGRL_Var.mat', 'simVar');
end

%--- Take action according to the policy ---
Q_t = Q_t(1 : 2);
if max(Q_t) <= simPara.U
    % Decide policy for Q^in
    if simVar.isLearn
        subQ = num2cell(Q_t + 1);
        a_t = simVar.aTable(subQ{:});
    else
        a_t = randi(2);
    end
else
    % Take π0 for states in Q^out
    a_t = StabPolicy(sysPara, Q_t);
end    
    
%------------- END OF CODE --------------
end

%------------- BEGIN SUBFUNCTION(Q) --------------

%--- Estimate the trasition probabilities ---
function simVar = EstQaQ(sysPara, simPara, simVar)
    % Initialize variables
    aggN_Qa = zeros(4, 4, 2);
    aggN_QaQ = cell(4, 4, 2);
    [aggN_QaQ{:}] = deal(zeros(3, 3));
    % Calculate the aggregated values
    for indQ = 1:1:(simPara.U+1)^2
        subQ = cell(1, 2);
        [subQ{:}] = ind2sub([simPara.U+1, simPara.U+1], indQ);
        arrQ = [subQ{:}];
        % Calculate the corresponding subsripts under aggregation
        arrAggQ = zeros(1, 2);
        arrAggQ(arrQ==1) = 1;
        arrAggQ(arrQ>=2 & arrQ<=sysPara.thre+1) = 2;
        arrAggQ(arrQ>=sysPara.thre+2 & arrQ<=simPara.U) = 3;
        arrAggQ(arrQ==simPara.U+1) = 4;
        % Calculate aggN_Qa and aggN_QaQ
        for inda = 1:1:2
            subQa = num2cell([arrQ, inda]);
            subAggQa = num2cell([arrAggQ, inda]);
            aggN_Qa(subAggQa{:}) = aggN_Qa(subAggQa{:}) + simVar.N_Qa(subQa{:});
            aggN_QaQ{subAggQa{:}} = aggN_QaQ{subAggQa{:}} + simVar.tP_QaQ{subQa{:}};            
        end
    end
    % Calculate tp_QaQ
    for indQ = 1:1:(simPara.U+1)^2
        subQ = cell(1, 2);
        [subQ{:}] = ind2sub([simPara.U+1, simPara.U+1], indQ);
        arrQ = [subQ{:}];
        % Calculate the corresponding subsripts under aggregation
        arrAggQ = zeros(1, 2);
        arrAggQ(arrQ==1) = 1;
        arrAggQ(arrQ>=2 & arrQ<=sysPara.thre+1) = 2;
        arrAggQ(arrQ>=sysPara.thre+2 & arrQ<=simPara.U) = 3;
        arrAggQ(arrQ==simPara.U+1) = 4;
        for inda = 1:1:2
            subQa = num2cell([arrQ, inda]);
            subAggQa = num2cell([arrAggQ, inda]);
            if aggN_Qa(subAggQa{:}) > 0
                simVar.tp_QaQ{subQa{:}} = aggN_QaQ{subAggQa{:}}/aggN_Qa(subAggQa{:});
            end
        end
    end
end

%------------- END OF QUBFUNCTION(Q) --------------
