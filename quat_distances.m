function [quat_Abs_Dist,quat_angles]  = quat_distances(q1,q2)
    
%This function is going to calculate two different distances between two quaternions:
%- Absolute distance: Find the distance between two quaternions accounting for the sign ambiguity.
                     %This function does not measure the distance on the hypersphere, but it takes into 
                     %account the fact that q and -q encode the same rotation. It is thus a good indicator for rotation similarities.
    
%- Distance in angles: 


% Input:
    % q1 -> contains an array of quaternions or an individual value
    % q2 -> is not mandatory. This is included to 
    
% Output:
    % quat_Abs_Dist -> absolute distance betweem two quaternions
    % quat_angles -> distance in degrees between two consecutive quaternions


%V 1.0 Creation of the document by David Lopez Perez 02.04.2020

    
%Validation of the input parameters    
uniqueArray = 0;

if nargin<1
   error('Not enough data has been provided'); 
end

if nargin <2
    if isempty(q1)
        error('The input array is empty');
    else
        uniqueArray = 1;
    end
end

%Check they are the same size
if nargin==2
    if ~isempty(q1) & ~isempty(q2)
        if size(q1) ~= size(q2)
            error('The sizes of both arrays are different');
        end
    else
        uniqueArray = 0;
    end
end

%Process the data
if uniqueArray
    for iQuat = 1:(length(q1)-1)        
        quat_Abs_Dist(iQuat) = calculateQuatAbsoluteDistace(q1(iQuat),q1(iQuat+1));
        quat_angles(iQuat) =calculateQuatAngle(q1(iQuat),q1(iQuat+1));       
    end
else
    for iQuat = 1:length(q1)
        quat_Abs_Dist(iQuat) =calculateQuatAbsoluteDistace(q1(iQuat),q2(iQuat));  
        quat_angles(iQuat) = calculateQuatAngle(q1(iQuat),q2(iQuat));
    end
end

       