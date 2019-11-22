%clear; clc; close all;
% change for your local path
%addpath('/home/alfonso/libs/casadi')
addpath('/home/alfonso/libs/FORCES_PRO_CLIENT')
%import casadi.*;
%clear_script;
epsilon = 0.001;    
radius = 5 % radius of the circunference which surround drones %0.5
alpha = 0.20;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% SOLVER GENERATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Problem dimensions
model.N = 100;           % horizon length %400
model.nvar = 9;          % number of variables 3 control inputs + 6 state variables  [ax ay az px py pz vx vy vz]
model.neq  = 6;          % number of equality constraints
model.nh = 3;            % number of inequality constraints
model.npar = 14;         % [pfx pfy pfz vxf vyf vzf dx dy tx ty vtx vty dx2 dx3]
                         % [1    2   3   4   5   6  7  8  9  10  11  12  13  14]
%% Objective function 

model.objective = @objfunGlobal_target_model;  %% function objective (included in the same folder)
model.objectiveN = @objfunN; %% N function obective (included in the same folder)

%% Continous model
% We use an explicit RK4 integrator here to discretize continuous dynamics:
m=1; I=1; % physical constants of the model
integrator_stepsize = 0.1;
continuous_dynamics = @(x,u) [x(4);  % v_x
                              x(5);  % v_y
                              x(6);  % v_z
                              u(1);
                              u(2);
                              u(3);
                              ]; 

model.eq = @(z) RK4(z(4:9), z(1:3), continuous_dynamics, integrator_stepsize); % Using CasADi RK4 integrator

model.E = [zeros(6,3) eye(6)];

%% upper/lower variable bounds lb <= x <= ub
model.lb = [-5 -5 -5 -200 -200 0 -1 -1 -1];
model.ub = [+5 +5 5 +200 +200 +50 1 1 1];

%% nonlinear inequalities
% (vehicle_x - obstacle_x)^2 +(vehicle_y - obstacle_y)^2 > r^2
model.ineq = @(z,p)  [(z(4)-p(11))^2 + (z(5)-p(12))^2;
                       (z(4)-p(13))^2 + (z(5)-p(14))^2;
                      atan2(sqrt((z(4)-p(9))^2 + (z(5)-p(10))^2 + epsilon), z(6));] % global pitch constarint
                  %    atan2(p(10)-z(5)+epsilon,p(9)-z(4)+epsilon)-atan2(z(8)+epsilon,z(7)+epsilon)]; % YAW relative constraint
                  
% Upper/lower bounds for inequalities
model.hu = [inf;inf;pi/2;]';
model.hl = [radius^2;radius^2;pi/4]';  %hardcoded for testing r^2 %2*pi/8


%% Initial and final conditions
% Velocity and position of the vehicle as initial constraints
model.xinitidx = 4:9;


%% Define solver options
codeoptions = getOptions('FORCESNLPsolver');
codeoptions.showinfo = 0;
codeoptions.nohash = 1;
codeoptions.overwrite = 1;
codeoptions.cleanup = 0;
codeoptions.maxit = 10000;    % Maximum number of iterations
codeoptions.printlevel = 2; % Use printlevel = 2 to print progress (but not for timings)
codeoptions.optlevel = 3;  % 0: no optimization, 1: optimize for size, 2: optimize for speed, 3: optimize for size & speed
codeoptions.printlevel = 1;


%% Generate forces solver
FORCES_NLP(model, codeoptions);
%target_init = [-8.4 -29.5];
target_init = [-32.99 -19.00];
rot = [cos(-0.9) -sin(-0.9); sin(-0.9) cos(-0.9)]; % -0,9 - rotation from game to map frames

%% environment configuration
% target trajectory
%target_final = [7.65 -55 3];
%target_final = [-7 -46];-18.1799, -39.8365, 0
target_final = [-18 -39];

t_velxy = 0.5;
t_vel_x = t_velxy*(target_final(1)-target_init(1))/sqrt((target_final(1)-target_init(1))^2+(target_final(2)-target_init(2))^2);
t_vel_y = t_velxy*(target_final(2)-target_init(2))/sqrt((target_final(1)-target_init(1))^2+(target_final(2)-target_init(2))^2);

% target trajectory
tx = [];
ty = [];
for k=1:model.N
    tx = [tx target_init(1)+integrator_stepsize*(k-1)*t_vel_x];
    ty = [ty target_init(2)+integrator_stepsize*(k-1)*t_vel_y];
end
%drone 1 initial pose
% relative_to_target = [0; 15];
% relative_to_target_map = rot*relative_to_target;
% drone_1 = [target_init(1)+relative_to_target_map(1) target_init(2)+relative_to_target_map(2) 7];
drone_1 = [-17,-6,4]
%[-21,-3,3];
% %drone 2 initial pose
% relative_to_target = [0; -15];
% relative_to_target_map = rot*relative_to_target;
% drone_2 = [target_init(1)+relative_to_target_map(1) target_init(2)+relative_to_target_map(2) 10];

%[-45,-22,11];

% %drone 3 initial pose
% relative_to_target = [15; 0];
% relative_to_target_map = rot*relative_to_target;
% drone_3 = [target_init(1)+relative_to_target_map(1) target_init(2)+relative_to_target_map(2) 7];
drone_2 = [-41.2,-6.0,10];
drone_3 = [-46.6,-26.4,7];


%[-42,-1,7]; 

%drone 1 final pose
relative_to_target = [0; 20];
relative_to_target_map = rot*relative_to_target;
drone_1_end = [tx(model.N)+relative_to_target_map(1) ty(model.N)+relative_to_target_map(2) 4];
%drone 2 final pose
relative_to_target = [15; 0];
relative_to_target_map = rot*relative_to_target;
drone_2_end = [tx(model.N)+relative_to_target_map(1) ty(model.N)+relative_to_target_map(2) 10];
%drone 3 final pose
relative_to_target = [0; -15];
relative_to_target_map = rot*relative_to_target;
drone_3_end = [tx(model.N)+relative_to_target_map(1) ty(model.N)+relative_to_target_map(2) 7]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% DRONE 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

final_pose = drone_1_end;
final_vel = [0 0 0];

%calculate the initial velocity of the target

%% Call solver drone 1
% Set initial guess to start solver from:

x0i = model.lb+(model.ub-model.lb)/2+1;
x0=repmat(x0i',model.N,1);
problem.x0=x0;

% parameters
param = zeros(12,model.N);
param(1,:) = repmat(final_pose(1),model.N,1);
param(2,:) = repmat(final_pose(2),model.N,1);
param(3,:) = repmat(final_pose(3),model.N,1);
param(4,:) = repmat(final_vel(1),model.N,1);
param(5,:) = repmat(final_vel(2),model.N,1);
param(6,:) = repmat(final_vel(3),model.N,1);
param(7,:) = repmat(t_vel_x,model.N,1);    % target velocity constant drone 2 pose as static
param(8,:) =  repmat(t_vel_y,model.N,1);
%param(9) = repmat(drone_2(3),model.N,1);
param(9,:) = tx;                            % target trajectory
param(10,:) = ty;
param(11,:) = repmat(drone_2(1),model.N,1);
param(12,:) = repmat(drone_2(2),model.N,1);
param(13,:) = repmat(drone_3(1),model.N,1); % drone 2 pose as static
param(14,:) = repmat(drone_3(2),model.N,1);
aux = [];
for k=1:model.N 
    aux = [aux param(1,k) param(2,k) param(3,k) param(4,k) param(5,k) param(6,k) param(7,k) param(8,k) param(9,k) param(10,k) param(11,k) param(12,k) param(13,k) param(14,k)];

end
problem_1 = aux';
problem.all_parameters= aux';

% Set initial conditions
problem.xinit = [drone_1(1); drone_1(2); drone_1(3); 0; 0; 0;];

% Time to solve the NLP!
[output,exitflag,info] = FORCESNLPsolver(problem);

% Make sure the solver has exited properly.
%assert(exitflag == 1,'Some problem in FORCES solver');
%fprintf('\nFORCES took %d iterations and %f seconds to solve the problem.\n',info.it,info.solvetime);

%% Plot results
TEMP = zeros(model.nvar,model.N);
for i=1:model.N
    if(model.N>=100)
        if (i<100)
          TEMP(:,i) = output.(['x0',sprintf('%02d',i)]);
        else
          TEMP(:,i) = output.(['x',sprintf('%02d',i)]);
        end
    else
      TEMP(:,i) = output.(['x',sprintf('%02d',i)]);
    end

end

%% plotting output
u_x_1 = TEMP(1,:);
u_y_1 = TEMP(2,:);
u_z_1 = TEMP(3,:);
x_1 = TEMP(4,:);
y_1 = TEMP(5,:);
z_1 = TEMP(6,:);
v_x_1 = TEMP(7,:);
v_y_1 = TEMP(8,:);
v_z_1 = TEMP(9,:);


% for k=1:model.N
%    TEMP(12,k) =atan2(ty(k)-y(k),tx(k)-x(k)); %yaw global
%    TEMP(13,k) = atan2(z(k),sqrt((ty(k)-y(k))^2+(tx(k)-x(k))^2));% pitch
%    TEMP(14,k) = atan2(ty(k)-x(k)+epsilon,tx(k)-x(k)+epsilon)-atan2(v_y(k)+epsilon,v_x(k)+epsilon); % YAW  relative 
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% DRONE 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

final_pose = drone_2_end;
final_vel = [0 0 0];

%calculate the initial velocity of the target

%% Call solver drone 1
% Set initial guess to start solver from:

x0i = model.lb+(model.ub-model.lb)/2+1;
x0=repmat(x0i',model.N,1);
problem.x0=x0;

% parameters
param = zeros(12,model.N);
param(1,:) = repmat(final_pose(1),model.N,1);
param(2,:) = repmat(final_pose(2),model.N,1);
param(3,:) = repmat(final_pose(3),model.N,1);
param(4,:) = repmat(final_vel(1),model.N,1);
param(5,:) = repmat(final_vel(2),model.N,1);
param(6,:) = repmat(final_vel(3),model.N,1);
param(7,:) = repmat(t_vel_x,model.N,1); 
param(8,:) = repmat(t_vel_y,model.N,1);
%param(9) = repmat(drone_2(3),model.N,1);
param(9,:) = tx;                            % target trajectory
param(10,:) = ty;
param(11,:) = x_1;   % target velocity constant
param(12,:) = y_1; 
param(13,:) = repmat(drone_3(1),model.N,1); % drone 2 pose as static
param(14,:) = repmat(drone_3(2),model.N,1);

aux = [];
for k=1:model.N 
    aux = [aux param(1,k) param(2,k) param(3,k) param(4,k) param(5,k) param(6,k) param(7,k) param(8,k) param(9,k) param(10,k) param(11,k) param(12,k) param(13,k) param(14,k)];

end
problem.all_parameters= aux';

% Set initial conditions
problem.xinit = [drone_2(1); drone_2(2); drone_2(3); 0; 0; 0;];

% Time to solve the NLP!
[output,exitflag,info] = FORCESNLPsolver(problem);

% Make sure the solver has exited properly.
%assert(exitflag == 1,'Some problem in FORCES solver');
fprintf('\nFORCES took %d iterations and %f seconds to solve the problem.\n',info.it,info.solvetime);

%% Plot results
TEMP = zeros(model.nvar,model.N);
for i=1:model.N
    if(model.N>=100)
        if (i<100)
          TEMP(:,i) = output.(['x0',sprintf('%02d',i)]);
        else
          TEMP(:,i) = output.(['x',sprintf('%02d',i)]);
        end
    else
      TEMP(:,i) = output.(['x',sprintf('%02d',i)]);
    end

end


%% plotting output
u_x_2 = TEMP(1,:);
u_y_2 = TEMP(2,:);
u_z_2 = TEMP(3,:);
x_2 = TEMP(4,:);
y_2 = TEMP(5,:);
z_2 = TEMP(6,:);
v_x_2 = TEMP(7,:);
v_y_2 = TEMP(8,:);
v_z_2 = TEMP(9,:);

% 
% for k=1:model.N
%    TEMP(12,k) =atan2(ty(k)-y(k),tx(k)-x(k)); %yaw global
%    TEMP(13,k) = atan2(z(k),sqrt((ty(k)-y(k))^2+(tx(k)-x(k))^2));% pitch
%    TEMP(14,k) = atan2(ty(k)-x(k)+epsilon,tx(k)-x(k)+epsilon)-atan2(v_y(k)+epsilon,v_x(k)+epsilon); % YAW  relative 
% end
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% DRONE 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

final_pose = drone_3_end;
final_vel = [0 0 0];

%calculate the initial velocity of the target

%% Call solver drone 1
% Set initial guess to start solver from:

x0i = model.lb+(model.ub-model.lb)/2+1;
x0=repmat(x0i',model.N,1);
problem.x0=x0;

% parameters
param = zeros(12,model.N);
param(1,:) = repmat(final_pose(1),model.N,1);
param(2,:) = repmat(final_pose(2),model.N,1);
param(3,:) = repmat(final_pose(3),model.N,1);
param(4,:) = repmat(final_vel(1),model.N,1);
param(5,:) = repmat(final_vel(2),model.N,1);
param(6,:) = repmat(final_vel(3),model.N,1);
param(7,:) =  repmat(t_vel_x,model.N,1);    % target velocity constant
param(8,:) =  repmat(t_vel_y,model.N,1);
%param(9) = repmat(drone_2(3),model.N,1);
param(9,:) = tx;                            % target trajectory
param(10,:) = ty;
param(11,:) = x_1;
param(12,:) = y_1;
param(13,:) = x_2; % drone 2 pose as static
param(14,:) = y_2;

aux = [];
for k=1:model.N 
    aux = [aux param(1,k) param(2,k) param(3,k) param(4,k) param(5,k) param(6,k) param(7,k) param(8,k) param(9,k) param(10,k) param(11,k) param(12,k) param(13,k) param(14,k)];

end
problem.all_parameters= aux';

% Set initial conditions
problem.xinit = [drone_3(1); drone_3(2); drone_3(3); 0; 0; 0;];

% Time to solve the NLP!
[output,exitflag,info] = FORCESNLPsolver(problem);

% Make sure the solver has exited properly.
%assert(exitflag == 1,'Some problem in FORCES solver');
fprintf('\nFORCES took %d iterations and %f seconds to solve the problem.\n',info.it,info.solvetime);

%% Plot results
TEMP = zeros(model.nvar,model.N);
for i=1:model.N
    if(model.N>=100)
        if (i<100)
          TEMP(:,i) = output.(['x0',sprintf('%02d',i)]);
        else
          TEMP(:,i) = output.(['x',sprintf('%02d',i)]);
        end
    else
      TEMP(:,i) = output.(['x',sprintf('%02d',i)]);
    end

end


%% plotting output
u_x_3 = TEMP(1,:);
u_y_3 = TEMP(2,:);
u_z_3 = TEMP(3,:);
x_3 = TEMP(4,:);
y_3 = TEMP(5,:);
z_3 = TEMP(6,:);
v_x_3 = TEMP(7,:);
v_y_3 = TEMP(8,:);
v_z_3 = TEMP(9,:);


% for k=1:model.N
%    TEMP(12,k) =atan2(ty(k)-y(k),tx(k)-x(k)); %yaw global
%    TEMP(13,k) = atan2(z(k),sqrt((ty(k)-y(k))^2+(tx(k)-x(k))^2));% pitch
%    TEMP(14,k) = atan2(ty(k)-x(k)+epsilon,tx(k)-x(k)+epsilon)-atan2(v_y(k)+epsilon,v_x(k)+epsilon); % YAW  relative 
% end

% 
% xlabel('x (m)'); ylabel('y (m)');  zlabel('z (m)');
% r = 1;
% ang=0:0.01:2*pi; 
% xp=r*cos(ang);
% yp=r*sin(ang);
% figure('units','normalized','outerposition',[0 0 1 1])
%     plot(x_3,y_3,'og','MarkerSize',5,'MarkerFaceColor','g'); hold on
%     hold on
%     %legend('Drone 3', 'Flyover','Drone 2','Lateral','Drone 1','Lateral','Target');
%    % h=plot(x_3+xp,y_3+yp,'g','LineStyle',':','LineWidth',3);
%     hold on
%     plot(x_2,y_2,'or','MarkerSize',5,'MarkerFaceColor','r'); hold on
%     hold on
%     %h2=plot(x_2(i)+xp,y_2(i)+yp,'r','LineStyle',':','LineWidth',3);
%     plot(x_1,y_1,'ob', 'MarkerSize',5,'MarkerFaceColor','b'); hold on
%     hold on
%     %h3=plot(x_1+xp,y_1+yp,'b','LineStyle',':','LineWidth',3);
%     plot(tx,ty, 'ok','MarkerSize',5,'MarkerFaceColor','k')
%     leg =legend('Drone 3', 'Flyover','Drone 2','Lateral','Drone 1','Lateral','Target');
%     leg.FontSize = 20;
%     pause(.1)
%     xlim([-15 10])
%     ylim([-50 -20])
%     %F(i) = getframe;
%     %set(h,'Visible','off')
%     %set(h2,'Visible','off')
%     %set(h3, 'Visible', 'off')
%     %set(h4, 'Visible', 'off')

% 
% writerObj = VideoWriter('test2.avi');
% writerObj.FrameRate = 10;
% open(writerObj);
% writeVideo(writer

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xlabel('x (m)'); ylabel('y (m)');  zlabel('z (m)');
r = 3.5;
ang=0:0.01:2*pi; 
xp=r*cos(ang);
yp=r*sin(ang);
figure('units','normalized','outerposition',[0 0 1 1])
plot(x_1,y_1,'ob', 'MarkerSize',5,'MarkerFaceColor','b');
hold on
plot(x_2,y_2,'or','MarkerSize',5,'MarkerFaceColor','r'); 
hold on
plot(tx,ty, 'ok','MarkerSize',5,'MarkerFaceColor','k');
hold on
plot(x_3,y_3, 'ok','MarkerSize',5,'MarkerFaceColor','g');
% for i=1:model.N
%    plot(x_3(i),y_3(i),'og','MarkerSize',5,'MarkerFaceColor','g'); 
%    hold on
%    %legend('Drone 3', 'Flyover','Drone 2','Lateral','Drone 1','Lateral','Target');
%    h=plot(x_3(i)+xp,y_3(i)+yp,'g','LineStyle',':','LineWidth',3);
%    hold on
%    plot(x_2(i),y_2(i),'or','MarkerSize',5,'MarkerFaceColor','r'); hold on
%    hold on
%    h2=plot(x_2(i)+xp,y_2(i)+yp,'r','LineStyle',':','LineWidth',3);
%     plot(x_1(i),y_1(i),'ob', 'MarkerSize',5,'MarkerFaceColor','b'); hold on
%     hold on
%     h3=plot(x_1(i)+xp,y_1(i)+yp,'b','LineStyle',':','LineWidth',3);
%     plot(tx(i),ty(i), 'ok','MarkerSize',5,'MarkerFaceColor','k')
%    % leg =legend('Drone 3', 'Flyover','Drone 2','Lateral','Drone 1','Lateral','Target');
%    % leg.FontSize = 20;
%     %pause(.1)
     xlim([-50 10])
     ylim([-60 0])
%     F(i) = getframe;
%    set(h,'Visible','off')
%    set(h2,'Visible','off')
%    set(h3, 'Visible', 'off')
%    %set(h4, 'Visible', 'off')
% 
% end

csv_1 = [x_1' y_1' z_1'];
csv_1_vel = [v_x_1' v_y_1' v_z_1'];
csvwrite('csv_poses1',csv_1);
csvwrite('csv_vels1',csv_1_vel);

csv_2 = [x_2' y_2' z_2'];
csv_2_vel = [v_x_2' v_y_2' v_z_2'];
csvwrite('csv_poses2',csv_2);
csvwrite('csv_vels2',csv_2_vel);

csv_3 = [x_3' y_3' z_3'];
csv_3_vel = [v_x_3' v_y_3' v_z_3'];
csvwrite('3_pos',csv_3);
csvwrite('3_vel',csv_3_vel);

% writerObj = VideoWriter('test2.avi');
% writerObj.FrameRate = 10;
% open(writerObj);
%writeVideo(writerObj, F)
%close(writerObj);


% shot_duration = 10;
% %metrics(TEMP, obst_x, obst_y, obst_z,radius, [initial_x initial_y initial_z], [final_pose_x final_pose_y final_pose_z], t, shot_duration)
% plot(x_3,y_3,'g', 'LineWidth', 3); hold on
% hold on
% plot(x_2,y_2,'r', 'LineWidth', 3); hold on
% hold on
% plot(x_1,y_1,'b', 'LineWidth', 3); hold on
% hold on
% xlabel('x (m)'); ylabel('y (m)');  zlabel('z (m)');


%% plotting the real no fly zone
% clear x
% x = -13.1:0.1:-2.5;
% 
% y = -1.5802*x-55.25; % recta arriba
% hold on
% plot(x,y)
% clear x
% x = -2.2:0.1:10.77;
% y = -1.457*x-24.01;
% hold on
% plot(x,y)
% 
% clear x
% x = -13.1:0.1:-2.2;
% y = 1.261*x-18.02;
% hold on
% plot(x,y)
% 
% clear x
% x = -2.5:0.1:10.7;
% y = 0.8742*x-49.11;
% hold on
% plot(x,y)

% %circle(x_1(model.N),y_1(model.N),radius)
% hold on 
% 
% hold on
% initial_point = [drone_1(1) drone_1(2)]; 
% final_point = [7.65 -55];
% to_plot= [initial_point; final_point];
% %plot(to_plot(:,1),to_plot(:,2),'b--');
% 
% hold on
% %plot(tx,ty,'rx')
% 
% hold on
% plot(final_pose(1),final_pose(2),'bx', 'MarkerSize',10)
% hold on
% %plot(tx,ty,'k')
% 
% % wo=load('trajectory_wo.mat');
% % 
% % plot(wo.TEMP(4,:),wo.TEMP(5,:),'g--');
% % %%%%%%% calculating yaw diff
% % yaw_diff=[];
% % % vector angle sum
% % for i= 2:49
% %     previous_yaw = atan2((ty-y(i-1)),(tx-x(i-1)));
% %     yaw = atan2((ty-y(i)),(tx-x(i)));
% %     yaw_diff=[yaw_diff;yaw-previous_yaw];
% % end
% % suma = sum(yaw_diff)
% % 
% % clear previous_yaw yaw_diff yaw
% % yaw_diff_wo = [];
% % for j= 2:49
% %     previous_yaw = atan2((ty-wo.TEMP(5,j-1)),(tx-wo.TEMP(4,j-1)));
% %     yaw = atan2((ty-wo.TEMP(5,j)),(tx-wo.TEMP(4,j)));
% %     yaw_diff_wo=[yaw_diff_wo;yaw-previous_yaw];
% % end
% % sum_wo = sum(yaw_diff_wo)
% 
% title('TOP VIEW - FLYOVER')
% legend('Drone 1', 'Drone 2','Drone 3','Target')
% 
% m = [TEMP(4:6,:)'];
% csvwrite('csvlist.csv',m)
% % 
% % time = [0];
% % for i=1:model.N-1
% %     time = [time; time(end)+t];
% % 
% % end

%csvwrite('time.csv',time)