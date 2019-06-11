%Main - Core console
%
% Example: 
%    none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: none

% Author: Bai Liu
% Laboratory for Information and Decision Systems, Massachusetts Institute of Technology, Cambridge, MA
% E-mail: bailiu@mit.edu
% 2019.06; Last revision: --

%------------- BEGIN CODE --------------

%--- Start timing ---
tic;

%--- System setting ---
clc;
clear global;
warning off;

%--- Set system parameters ---
sysPara.arrRate = 1;
sysPara.tranRate = cell(2, 2);
sysPara.tranRate{1, 1} = [0.5, 0];
sysPara.tranRate{1, 2} = [0, 1];
sysPara.tranRate{2, 1} = [0.5, 0];
sysPara.tranRate{2, 2} = [0.25, 0.25];
sysPara.thre = 10;

%--- Set simulation parameters ---
simPara.methodType = 1;
simPara.U = 20;
simPara.l = 0.2;
simPara.L = 200;
simPara.T = 30;

%--- Do simulation ---
% CompChannelSelect(sysPara, simPara);

[SaTable, simVar] = Routing(sysPara, simPara);

disp(SaTable);


%--- Stop timing ---
toc;

%------------- END OF CODE --------------
