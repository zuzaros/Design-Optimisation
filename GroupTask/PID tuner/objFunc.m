function obj = objFunc(ref,pos)
%define objective funciton based on reference (ref) and actual position (pos)
%signals

%minimum absolute error
% obj = sum(abs(ref.data - pos.data));

%min squared error
obj = sum((ref.data - pos.data).^2);

end

