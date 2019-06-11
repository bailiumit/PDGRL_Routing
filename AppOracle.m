function a_t = AppOracle(sysPara, S_t)
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
Q_t = S_t(1 : sysPara.D);
con_t = S_t(sysPara.D+1 : sysPara.D+sysPara.D);
switch 10*con_t(1) + con_t(2)
    case 0
        a_t = 1;
    case 1
        a_t = 2;
    case 10
        a_t = 1;
    case 11
        if Q_t(2) == 0
            a_t = 1;
        else
            a_t = 2;
        end
    otherwise
        disp('Error in AppOracle');
end

%------------- END OF CODE --------------
end
