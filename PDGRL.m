function [simVar, a_t] = PDGRL(sysPara, simPara, simVar, S_t)
%PDGRL_DSA - 
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

%--- Learn the optimal estimated policy ---

if simVar.isIni && simVar.isLearn
    % Estimate the trasition probabilities
    estp_SaS = EstSaS(sysPara, simPara, simVar);
    % Obtain optimal policy for the estimated MDP
    simVar.aTable = SolveMDP(sysPara, simPara, estp_SaS);
    
    save('PDGRL_Var.mat', 'estp_SaS', 'simVar');
end

%--- Take action according to the policy ---
Q_t = S_t(1 : sysPara.D);
if max(Q_t) <= simPara.U
    % Decide policy for S^in
    if simVar.isLearn
        subS = num2cell(S_t + 1);
        a_t = simVar.aTable(subS{:});
    else
        a_t = randi(2);
    end
else
    % Take π0 for states in S^out
    a_t = StabPolicy(sysPara, S_t);
end    
    
%------------- END OF CODE --------------
end

%------------- BEGIN SUBFUNCTION(S) --------------

%--- Estimate the trasition probabilities ---
function estp_SaS = EstSaS(sysPara, simPara, simVar)
    estp_SaS = cell([(simPara.U+1)*ones(1, sysPara.D), 2*ones(1, sysPara.D), sysPara.D]);
    % Initialize variables
    aggN_Sa = zeros([3*ones(1, sysPara.D), 2*ones(1, sysPara.D), sysPara.D]);
    aggN_SaS = cell([3*ones(1, sysPara.D), 2*ones(1, sysPara.D), sysPara.D]);
    [aggN_SaS{:}] = deal(zeros([3 * ones(1, sysPara.D), 2 * ones(1, sysPara.D)]));
    % Calculate the aggregated values
    for indS = 1:1:(simPara.U+1)^sysPara.D * 2^sysPara.D
        subS = cell(1, sysPara.D + sysPara.D);
        [subS{:}] = ind2sub([(simPara.U+1)*ones(1, sysPara.D), 2*ones(1, sysPara.D)], indS);
        arrS = [subS{:}];
        % Calculate the corresponding index in aggN_Sa
        arrAggS = zeros(1, sysPara.D + sysPara.D);
        arrAggS(arrS==1) = 1;
        arrAggS(arrS>=2 & arrS<=simPara.U) = 2;
        arrAggS(arrS==simPara.U+1) = 3;
        % Calculate aggN_Sa and aggN_SaS
        for inda = 1:1:sysPara.D
            subSa = num2cell([arrS, inda]);
            subAggSa = num2cell([arrAggS, inda]);
            aggN_Sa(subAggSa{:}) = aggN_Sa(subAggSa{:}) + simVar.N_Sa(subSa{:});
            aggN_SaS{subAggSa{:}} = aggN_SaS{subAggSa{:}} + simVar.tP_SaS{subSa{:}};            
        end
    end
    % Calculate estp_SaS
    for indS = 1:1:(simPara.U+1)^sysPara.D * 2^sysPara.D
        subS = cell(1, sysPara.D + sysPara.D);
        [subS{:}] = ind2sub([(simPara.U+1)*ones(1, sysPara.D), 2*ones(1, sysPara.D)], indS);
        arrS = [subS{:}];
        arrAggS = zeros(1, sysPara.D + sysPara.D);
        arrAggS(arrS==1) = 1;
        arrAggS(arrS>=2 & arrS<=simPara.U) = 2;
        arrAggS(arrS==simPara.U+1) = 3;
        for inda = 1:1:sysPara.D
            subSa = num2cell([arrS, inda]);
            subAggSa = num2cell([arrAggS, inda]);
            estp_SaS{subSa{:}} = aggN_SaS{subAggSa{:}}/aggN_Sa(subAggSa{:});
        end
    end
end

%------------- END OF SUBFUNCTION(S) --------------
