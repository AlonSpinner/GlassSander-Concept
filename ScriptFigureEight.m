%-------USER INPUT PARAMTERS:

%define radii and arms length
%NOTE: L for left and R for Right
%Arms length      Radii length 
Larm=200;           Lradius=50; 
Rarm=200;           Rradius=55;   
%radial velocity of left gear
w=100; %is implemented in pause (forloop)
%amount of cycles
T=10;
%----------------------------

%constrained ground link length.
x0=Lradius+Rradius; 

%define Theta vectors
LTheta=T*linspace(0,2*pi,100*T); %Define full circle for left gear
if Rradius>Lradius %make sure we make full revolution on both gears
    LTheta=LTheta*Rradius/Lradius;
end
RTheta=-LTheta*Lradius/Rradius;

%Create figure and axes
fig=figure;
ax=axes(fig); hold(ax,'on'); grid(ax,'on'); axis(ax,'equal');
BoxLength=(Lradius+Rradius+Larm+Rarm)/2;
xlim(ax,[-BoxLength,BoxLength]);
ylim(ax,[-BoxLength,BoxLength]);
%Draw gear boundries %NOTE: (0,0) is set to the center of the left gear
t=linspace(0,2*pi,100);
gearL=Lradius*exp(1i*t);
gearR=x0+Rradius*exp(1i*t); %draws a full circle
plot(ax,gearL,'--','color',[0,0.7,0],'linewidth',3);
plot(ax,gearR,'--','color',[0,0.7,0],'linewidth',3);

%Draw links and animation
for j=1:length(LTheta)
    %find angles Lphi and Rphi
    delta=CalculateDelta(Lradius,Rradius,Larm,Rarm,x0,LTheta(j),RTheta(j));
    [Lphi,Rphi]=CalculateBetaGama(Lradius,Rradius,Larm,Rarm,x0,LTheta(j),RTheta(j),delta);
    %Calculate radii and arm vectors
    vLradius=Lradius*exp(1i*LTheta(j));
    vRradius=x0+Rradius*exp(1i*RTheta(j));
    vLarm=vLradius+Larm*exp(1i*Lphi);
    vRarm=vRradius+Rarm*exp(1i*Rphi);
    
    %plot links
    hvLr=plot(ax,[0,vLradius],'b','linewidth',3);
    hvRr=plot(ax,[x0,vRradius],'b','linewidth',3);
    hvLa=plot(ax,[vLradius,vLarm],'r','linewidth',3);
    hvRa=plot(ax,[vRradius,vRarm],'r','linewidth',3);
    
    %scatter a point on track
    plot(ax,vLarm,'marker','o','color','k','markersize',1);
    
    pause(0.1/w);
    delete([hvLr,hvRr,hvLa,hvRa]);
end

function delta=CalculateDelta(Lradius,Rradius,Larm,Rarm,x0,LTheta,RTheta)
%Input: 
%a0-a3: numeric values representing links lengt
%alpha: rad degree

%Output:
%delta: rad degree. returns empty if delta isnt real
Px=Rradius*cos(RTheta)-Lradius*cos(LTheta)+x0;
Py=Rradius*sin(RTheta)-Lradius*sin(LTheta);
delta=acos((Larm^2+Rarm^2-Px^2-Py^2)/(2*Rarm*Larm)); %rad
delta=real(delta); %to fix numerical issues
end

function [Rphi,Lphi]=CalculateBetaGama(Lradius,Rradius,Larm,Rarm,x0,LTheta,RTheta,delta)
%calculates angle gama 
Px=Rradius*cos(RTheta)-Lradius*cos(LTheta)+x0;
Py=+Rradius*sin(RTheta)-Lradius*sin(LTheta);
A=[Larm*cos(delta)-Rarm,-Larm*sin(delta);
    Larm*sin(delta),Larm*cos(delta)-Rarm];
b=[Px;Py];
x=A\b; %[cos(beta);sin(beta)]

Lphi=atan2(x(2),x(1));
Rphi=Lphi+delta;
Rphi=real(Rphi); %to fix numerical issues
end