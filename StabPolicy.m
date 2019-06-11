function a_t = StabPolicy(sysPara, Q_t)
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
% 2019.05; Last revision: 2019.05.23

%------------- BEGIN CODE --------------

%--- Always take S->2 ---
a_t = 2;

%------------- END OF CODE --------------
end
