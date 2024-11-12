function [obj] = runDCmotor(X)

%set Kp, Ki and Kd constants in the simulink model
%here the vector X is what the optimiser is changing
set_param('DCmotor/Constant','Value',string(X(1)))
set_param('DCmotor/Constant1','Value',string(X(2)))
set_param('DCmotor/Constant2','Value',string(X(3)))

%grab data from simulink run
simOut = sim('DCmotor');

%get data for the reference (step funciton) and the actual motor position
ref = simOut.ScopeData{2}.Values;
pos = simOut.ScopeData{1}.Values;

%pass ref and pos to the objective function
obj = objFunc(ref,pos); %obj is a single value that's returned to the optimiser


%plot in real time at each iteration
clf()
plot(ref.time, ref.data,'k-')
hold on
plot(pos.time, pos.data, 'b-');
ylim([0, 1.5])
set(gcf,'color','w')
xlabel('time, s','FontSize',14)
ylabel('\theta','FontSize',14)
drawnow

end



