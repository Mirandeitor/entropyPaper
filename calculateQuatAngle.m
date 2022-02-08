function quaternionAngle = calculateQuatAngle(q1,q2)

%This snipplet is going to calculate the absolute distance between
%quaternions in degrees of orientation

% Input:
    % q1 -> contains the quaternion at time point 1
    % q2 -> contains the quaternion at time point 2
    
% Output:
    % quaternionAngle -> differences in orientation betweem two quaternions

%V1.0 creation of the document by David Lopez 05.04.2020

if nargin<2 || nargin <1    
    error('Not enough parameters');
end

%Calculate the difference between quaternions
q12 = quatmultiply(quatconj(compact(q1)),compact(q2));
quaternionAngle = 2 * atan2(norm(q12(2:4)),q12(1));