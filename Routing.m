function [QaTable, simVar] = Routing(sysPara, simPara)
%DynSerAlloc - 
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

%--- Initialize simulation variables ---
QaTable = zeros(simPara.T, 2 + 1);
simVar.k = 1;
simVar.isIni = true;
simVar.isLearn = true;
simVar.N_in = 0;
[simVar.N_Qa, simVar.tP_QaQ, simVar.tp_QaQ] = IniSaS(sysPara, simPara);
simVar.aTable = zeros(simPara.U+1, simPara.U+1);

%--- Begin simulation ---
Q_t = zeros(1, 2);
for t = 1:1:simPara.T
    % Display progress
    if mod(t, simPara.T/100) == 0
        disp(['methodType: ', num2str(simPara.methodType), ', t: ', num2str(t)]);
    end
    % Decide the action to take
    switch simPara.methodType
        case 1
            a_t = StabPolicy(sysPara, Q_t);
        case 2
            [simVar, a_t] = PDGRL(sysPara, simPara, simVar, Q_t);
        case 3
            [simVar, a_t] = TruOracle(sysPara, simPara, simVar, Q_t, t);
        case 4
            a_t = AppOracle(sysPara, Q_t);
        otherwise
            disp('Error in DynSerAlloc');
    end
    % Obtain S_{t+1}
    Q_tp1 = CalNewS(sysPara, Q_t, a_t);
    % Updates
    simVar = CalSimVar(simPara, simVar, t, Q_t, a_t, Q_tp1);
    QaTable(t, : ) = [Q_t, a_t];
    Q_t = Q_tp1;
end

%------------- END OF CODE --------------
end

%------------- BEGIN SUBFUNCTION(S) --------------

%--- Initialize N_Qa and tP_QaQ ---
function [iniN_Qa, initP_QaQ, initp_QaQ] = IniSaS(sysPara, simPara)
    p_QaQ = Calp_QaQ(sysPara, simPara);
    iniN_Qa = zeros(simPara.U+1, simPara.U+1, 2);
    initP_QaQ = cell(simPara.U+1, simPara.U+1, 2);
    [initP_QaQ{:}] = deal(zeros(3, 3));
    initp_QaQ = cell(simPara.U+1, simPara.U+1, 2);
    [initp_QaQ{:}] = deal(zeros(3, 3));
    % Initialize tp_QaQ
    for indQa = 1:1:(simPara.U+1)^2 * 2
        subQa = cell(1, 2 + 1);
        [subQa{:}] = ind2sub([simPara.U+1, simPara.U+1, 2], indQa);
        % Make the positivity of the elements in P_QaQ the same as p_QaQ
        subNonZero = p_QaQ{subQa{:}} > 0;
        initp_QaQ{subQa{:}}(subNonZero) = 1;
        initp_QaQ{subQa{:}} = initp_QaQ{subQa{:}}/sum(reshape(initp_QaQ{subQa{:}}, [], 1));
    end
end

%--- Calculate S_{t+1} ---
function Q_tp1 = CalNewS(sysPara, Q_t, a_t)
    ArrQ = zeros(1, 2);
    SerQ = zeros(1, 2);
    % Calculate arrival
    ArrQ(a_t) = datasample([0, 1], 1, 'Weights', [1 - sysPara.arrRate, sysPara.arrRate]);
    % Calculate service
    arrRegion = zeros(1, 2);
    arrRegion(Q_t<=sysPara.thre) = 1;
    arrRegion(Q_t>sysPara.thre) = 2;
    subRegion = num2cell(arrRegion);
    SerQ(1) = -datasample([0, 1], 1, 'Weights', [1 - sysPara.tranRate{subRegion{:}}(1), sysPara.tranRate{subRegion{:}}(1)]);
    SerQ(2) = -datasample([0, 1], 1, 'Weights', [1 - sysPara.tranRate{subRegion{:}}(2), sysPara.tranRate{subRegion{:}}(2)]);
    % Calculate S_{t+1}
    Q_tp1 = max(Q_t+SerQ, 0) + ArrQ;
end

%--- Update simVar ---
function simVar = CalSimVar(simPara, simVar, t, Q_t, a_t, Q_tp1)
    if max(Q_t) <= simPara.U
        % Update N_Qa and N_in
        subQa = num2cell([Q_t+1, a_t]);
        simVar.N_Qa(subQa{:}) = simVar.N_Qa(subQa{:}) + 1;
        simVar.N_in = simVar.N_in + 1;
        % Update tP_QaQ
        tQ_tp1 = min(Q_tp1, simPara.U);
        dQ_t = tQ_tp1 - Q_t;
        subdS = num2cell(dQ_t+2);
        simVar.tP_QaQ{subQa{:}}(subdS{:}) = simVar.tP_QaQ{subQa{:}}(subdS{:}) + 1;
        % Decide whether to start a new episode & update k and isIni
        if simPara.methodType == 2
            if simVar.N_in > simPara.L*sqrt(simVar.k)
                simVar.isIni = true;
                simVar.k = simVar.k + 1;
                simVar.N_in = 0;
                % Decide whether to explore or exploit
                if rand >= simPara.l*1/sqrt(simVar.k)
                    simVar.isLearn = true;
                else
                    simVar.isLearn = false;
                end
                % Display the learning process
                disp(['t = ' , num2str(t), ', k = ', num2str(simVar.k), ', isLearn = ', num2str(simVar.isLearn)]);
            else
                simVar.isIni = false;
            end
        end
    end 
end

%------------- END OF SUBFUNCTION(S) --------------
