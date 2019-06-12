function a_t = AppOracle(sysPara, Q_t)
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
% 2019.06; Last revision: 2019.06.03
%------------- BEGIN CODE --------------

%--- Take action according to the policy ---
% if Q_t(2) == 0 && Q_t(1) >= 2
%     a_t = 2;
% else
%     a_t = 1;
% end

if Q_t(1) > 0 && Q_t(2) <= sysPara.thre
    a_t = 2;
else
    a_t = 1;
end

if max(Q_t) > 10
    a_t = StabPolicy(sysPara, Q_t);
end

%------------- END OF CODE --------------
end
