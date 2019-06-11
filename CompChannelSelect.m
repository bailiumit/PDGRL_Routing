function CompChannelSelect(sysPara, simPara)
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
% 2019.06; Last revision: 2019.06.10

%------------- BEGIN CODE --------------

%--- Test π0 ---
Q_Stable = DoSim(sysPara, simPara, 1);

%--- Test PDGRL ---
Q_PDGRL = DoSim(sysPara, simPara, 2);

%--- Test ~π* + π0 ---
Q_TruOracle = DoSim(sysPara, simPara, 3);

%--- Test approximated π* ---
Q_AppOracle = DoSim(sysPara, simPara, 4);

%--- Calculate average queue ---
aveQ_Stable = zeros(simPara.T, 1);
aveQ_PDGRL = zeros(simPara.T, 1);
aveQ_TruOracle = zeros(simPara.T, 1);
aveQ_AppOracle = zeros(simPara.T, 1);
aveQ_Stable(1) = sum(Q_Stable(1, : ));
aveQ_PDGRL(1) = sum(Q_PDGRL(1, : ));
aveQ_TruOracle(1) = sum(Q_TruOracle(1, : ));
aveQ_AppOracle(1) = sum(Q_AppOracle(1, : ));
for t = 2:1:simPara.T
    if mod(t, simPara.T/100) == 0
        disp(['Average calculation at t = ', num2str(t)]);
    end
    aveQ_Stable(t) = (aveQ_Stable(t-1)*(t-1) + sum(Q_Stable(t, : )))/t;
    aveQ_PDGRL(t) = (aveQ_PDGRL(t-1)*(t-1) + sum(Q_PDGRL(t, : )))/t;
    aveQ_TruOracle(t) = (aveQ_TruOracle(t-1)*(t-1) + sum(Q_TruOracle(t, : )))/t;
    aveQ_AppOracle(t) = (aveQ_AppOracle(t-1)*(t-1) + sum(Q_AppOracle(t, : )))/t;
end

%--- Draw the figure ---
tArray = 1:1:simPara.T;
plot(tArray, aveQ_Stable);
hold on;
plot(tArray, aveQ_PDGRL);
hold on;
plot(tArray, aveQ_TruOracle);
hold on;
plot(tArray, aveQ_AppOracle);
xlabel('t','fontsize',10); 
ylabel('Average total queue length up to t','fontsize',10);
legend('$\pi_0$', 'PDGRL', '$\tilde{\pi}^* + \pi_0$', 'Approximated $\pi^*$', 'Interpreter','latex'); 
grid on;

%------------- END OF CODE --------------
end

%------------- BEGIN SUBFUNCTION(S) --------------

%--- Conduct the simulation ---
function sampleQ = DoSim(sysPara, simPara, methodType)
    simPara.methodType = methodType;
    [SaTable, simVar] = Routing(sysPara, simPara);
    sampleQ = SaTable(:, 1:sysPara.D);
end

%------------- END OF SUBFUNCTION(S) --------------