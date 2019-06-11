function [SaTable, simVar] = Routing(sysPara, simPara)
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
% 2019.06; Last revision: 2019.06.11

%------------- BEGIN CODE --------------

%--- Initialize simulation variables ---
SaTable = zeros(simPara.T, 2 + 1);
simVar.k = 1;
simVar.isIni = true;
simVar.isLearn = true;
simVar.N_in = 0;
% [simVar.N_Sa, simVar.tP_SaS] = IniSaS(sysPara, simPara);

    simVar.N_Sa = zeros(simPara.U+1, simPara.U+1, 2);
    simVar.tP_SaS = cell(simPara.U+1, simPara.U+1, 2);
    [simVar.tP_SaS{:}] = deal(zeros(3, 3));

simVar.aTable = zeros(simPara.U+1, simPara.U+1);

%--- Begin simulation ---
S_t = zeros(1, 2);
for t = 1:1:simPara.T
    % Display progress
    if mod(t, simPara.T/100) == 0
        disp(['methodType: ', num2str(simPara.methodType), ', t: ', num2str(t)]);
    end
    % Decide the action to take
    switch simPara.methodType
        case 1
            a_t = StabPolicy(sysPara, S_t);
        case 2
            [simVar, a_t] = PDGRL(sysPara, simPara, simVar, S_t);
        case 3
            [simVar, a_t] = TruOracle(sysPara, simPara, simVar, S_t, t);
        case 4
            a_t = AppOracle(sysPara, S_t);
        otherwise
            disp('Error in DynSerAlloc');
    end
    % Obtain S_{t+1}
    S_tp1 = CalNewS(sysPara, S_t, a_t);
    % Updates
    simVar = CalSimVar(sysPara, simPara, simVar, t, S_t, a_t, S_tp1);
    SaTable(t, : ) = [S_t, a_t];
    S_t = S_tp1;
end

%------------- END OF CODE --------------
end

%------------- BEGIN SUBFUNCTION(S) --------------

%--- Initialize N_Sa and tP_SaS ---
function [iniN_Sa, initP_SaS] = IniSaS(sysPara, simPara)
    p_SaS = Calp_SaS(sysPara, simPara);
    iniN_Sa = zeros(simPara.U+1, simPara.U+1, 2);
    initP_SaS = cell(simPara.U+1, simPara.U+1, 2);
    [initP_SaS{:}] = deal(zeros(3, 3));
    % Calculate N_Sa and tP_SaS
    for indSa = 1:1:(simPara.U+1)^2 * 2
        subSa = cell(1, 2 + 1);
        [subSa{:}] = ind2sub([U+1, U+1, 2], indSa);
        % Make the positivity of the elements in P_SaS the same as p_SaS
        subNonZero = p_SaS{subSa{:}} > 0;
        initP_SaS{subSa{:}}(subNonZero) = 1;
        iniN_Sa(subSa{:}) = sum(reshape(initP_SaS{subSa{:}}, [], 1));
    end
end

%--- Calculate S_{t+1} ---
function S_tp1 = CalNewS(sysPara, S_t, a_t)
    ArrQ = zeros(1, 2);
    SerQ = zeros(1, 2);
    % Calculate arrival
    ArrQ(a_t) = datasample([0, 1], 1, 'Weights', [1 - sysPara.arrRate, sysPara.arrRate]);
    % Calculate service
    arrRegion = zeros(1, 2);
    arrRegion(S_t<=sysPara.thre) = 1;
    arrRegion(S_t>sysPara.thre) = 2;
    subRegion = num2cell(arrRegion);
    SerQ(1) = -datasample([0, 1], 1, 'Weights', [1 - sysPara.tranRate{subRegion{:}}(1), sysPara.tranRate{subRegion{:}}(1)]);
    SerQ(2) = -datasample([0, 1], 1, 'Weights', [1 - sysPara.tranRate{subRegion{:}}(2), sysPara.tranRate{subRegion{:}}(2)]);
    % Calculate S_{t+1}
    S_tp1 = max(S_t+SerQ, 0) + ArrQ;
end

%--- Update simVar ---
function simVar = CalSimVar(sysPara, simPara, simVar, t, S_t, a_t, S_tp1)
    if max(S_t) <= simPara.U
        % Update N_Sa and N_in
        subSa = num2cell([S_t+1, a_t]);
        simVar.N_Sa(subSa{:}) = simVar.N_Sa(subSa{:}) + 1;
        simVar.N_in = simVar.N_in + 1;
        % Update tP_SaS
        tS_tp1 = min(S_tp1, simPara.U);
        dS_t = tS_tp1 - S_t;
        subdS = num2cell(dS_t+2);
        simVar.tP_SaS{subSa{:}}(subdS{:}) = simVar.tP_SaS{subSa{:}}(subdS{:}) + 1;
        % Decide whether to start a new episode & update k and isIni
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
        else
            simVar.isIni = false;
        end
    end 
end

%------------- END OF SUBFUNCTION(S) --------------
