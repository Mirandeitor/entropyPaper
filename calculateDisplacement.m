function displacement = calculateDisplacementAcc(accelerationCorrected,movement1D,frequency)

% This function is going to integrate the accelaration information to obtain
% displacement in three dimensions of as an integrative average dimension.

% Input accelerationCorrected -> the acceleration in Earth domain
% Output -> displacementX -> it will contain the movement for each of the
% dimensions

% V1.0 Creation of the document bu David López Pérez 29.05.2020
% V1.1 The selection of collapsing the data is now given to the function to
% avoid unnecessary messages by David Lopez Perez 01.06.2020
% V1.2 Bug fix movement1D is converted in the main script to improve
% compatibility between functions by David López Pérez 14.10.2020


%Validation of the input parameters
if nargin < 1 || isempty(accelerationCorrected)
   error('The input parameter is empty or has not been provided.')
end

%Filter parameters
Fs = frequency;
Ts = 1/Fs;
L = length(accelerationCorrected);
t = linspace(0, L, L)*Ts;
fc = 0.1/Fs;  % Cut off Frequency
order = 6; % 6th Order Filter

%Go through all the dimensions of the acceleration

% for i = 1:size(accelerationCorrected,2)
%     % Filter  Acceleration Signals
%     [b1 a1] = butter(order,fc,'high');
%     accf=filtfilt(b1,a1,accelerationCorrected(:,i));
%     velocity=cumtrapz(t,accf);
%     [b2 a2] = butter(order,fc,'high');
%     velf = filtfilt(b2,a2,velocity);
%     %Second Integration   (Velocity - Displacement)
%     displacement(:,i)=cumtrapz(t, velf);    
%     clear velocity
% end

displacement = accelerationCorrected;

if movement1D
    displacementAux = sqrt(displacement(:,1).^2 + displacement(:,2).^2 + displacement(:,3).^2);
    clear displacement
    displacement = displacementAux';
end

