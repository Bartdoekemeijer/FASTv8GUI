%% IPC Control
load data
%% IPC control
% Inverse notch filter 1P
k_1p        = 1E-3;        %Scaling Gain
zeta_1p     = 0.5;          %Damping
omega_1p    = (2*pi)/4.95;  %Frequency [rad/s] (~0.2 Hz)
ki_1p       = 0.01;         %Integral gain
% Low-pass filter
omega_L     = 10;           %Frequency [rad/s] (~1.6 Hz)
zeta_L      = 1;            %Damping
% Inverse notch filter 2P
k_2p        = 1E-3;        %Scaling gain
zeta_2p     = 0.3;          %Damping
omega_2p    = (4*pi)/4.95;  %Frequency [rad/s] (~0.4 Hz)
ki_2p       = 0.002;        %Integral gain
% Reverse coleman transformation
delta_1p    = (25*pi)/180;  %Phase offset 1P
delta_2p    = (33*pi)/180;  %Phase offset 2P
% Pitch angle saturation for IPC
IPC_Pitch_max = 5;
IPC_Pitch_min = -5;