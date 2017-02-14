function [sys,x0,str,ts] = SVM2(t,x,u,flag)

switch flag

  case 0
    [sys,x0,str,ts]=mdlInitializeSizes;
    
  case 3
    sys=mdlOutputs(t,x,u);

  case 4
    sys=mdlGetTimeOfNextVarHit(t,x,u);
    
  case {1, 2, 9}
        sys = [];

  otherwise
    error(['Unhandled flag = ',num2str(flag)]);
end


function [sys,x0,str,ts]=mdlInitializeSizes

sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 3;
sizes.NumInputs      = 3;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);
x0  = [];
str = [];
ts  = [-2 0];


function sys=mdlOutputs(t,x,u)
global Dutycycle
sys = Dutycycle;


function sys=mdlGetTimeOfNextVarHit(t,x,u)
global Dutycycle
m = u(2);
Angle = u(3) * 180 / pi;  % chage to degree

theta = mod(mod(Angle, 360), 60);  % calculate intersection angle
sector = fix( mod(Angle, 360) / 60) + 1;  % 计算扇区
Dm = m * sind(60 - theta); % 计算占空比
Dn = m * sind(theta);
D0 = (1 - Dm - Dn) / 2;

switch sector
    case 1
        Dutycycle = [D0, Dm + D0, Dm + Dn + D0];
    case 2
        Dutycycle = [Dn + D0, D0, Dm + Dn + D0]; % 考虑到开关次数最少，中间两个向量颠倒
    case 3
        Dutycycle= [Dm + Dn + D0, D0, Dm + D0];
    case 4
        Dutycycle = [Dm + Dn + D0, Dn + D0, D0];
    case 5
        Dutycycle = [Dm + D0, Dm + Dn + D0, D0];
    case 6
        Dutycycle = [D0, Dm + Dn + D0, Dn + D0];
end

sys = t + u(1);