function [simVar, a_t] = TruOracle(sysPara, simPara, simVar, S_t, t)
%StabPolicy_DSA - 
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
% 2019.05; Last revision: 2019.06.04

%------------- BEGIN CODE --------------

%--- Solve the MDP at the beginning ---
if t == 1
    % Obtain the transition matrices for the truncated MDP
    tp_SaS = Calp_SaS(sysPara, simPara);
    % Obtain ~π*
    simVar = SolveMDP(sysPara, simPara, simVar, tp_SaS);
end

%--- Take action according to the policy ---
Q_t = S_t(1 : sysPara.D);
if max(Q_t) <= simPara.U
    % Take ~π* for states in S^in
    subS = num2cell(S_t + 1);
    a_t = simVar.aTable(subS{:});
else
    % Take π0 for states in S^out
    a_t = StabPolicy(sysPara, S_t);
end

%------------- END OF CODE --------------
end
