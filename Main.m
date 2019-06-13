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
sysPara.arrRate = 0.8;
sysPara.tranRate = cell(2, 2);
sysPara.tranRate{1, 1} = [0.9, 0.1];
sysPara.tranRate{1, 2} = [0.1, 0.9];
sysPara.tranRate{2, 1} = [0.9, 0.1];
sysPara.tranRate{2, 2} = [0.1, 0.9];
sysPara.thre = 5;

%--- Set simulation parameters ---
simPara.methodType = 1;
simPara.U = 10;
simPara.l = 0.2;
simPara.L = 50;
simPara.T = 1000;

%--- Do simulation ---
CompChannelSelect(sysPara, simPara);

% [QaTable, simVar] = Routing(sysPara, simPara);

% disp(QaTable);

% tp_QaQ = Calp_QaQ(sysPara, simPara);
% aTable = SolveMDP(sysPara, simPara, tp_QaQ);
% disp(aTable);

% [QaTable, simVar] = Routing(sysPara, simPara);

%--- Stop timing ---
toc;

%------------- END OF CODE --------------
