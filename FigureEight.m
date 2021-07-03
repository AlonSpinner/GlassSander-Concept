function varargout = FigureEight(varargin)
% FIGUREEIGHT MATLAB code for FigureEight.fig
%      FIGUREEIGHT, by itself, creates a new FIGUREEIGHT or raises the existing
%      singleton*.
%
%      H = FIGUREEIGHT returns the handle to a new FIGUREEIGHT or the handle to
%      the existing singleton*.
%
%      FIGUREEIGHT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIGUREEIGHT.M with the given input arguments.
%
%      FIGUREEIGHT('Property','Value',...) creates a new FIGUREEIGHT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FigureEight_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FigureEight_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FigureEight

% Last Modified by GUIDE v2.5 16-Dec-2018 18:36:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FigureEight_OpeningFcn, ...
                   'gui_OutputFcn',  @FigureEight_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
function FigureEight_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

guidata(hObject, handles);

%Fix UITable - tag='ParTable'
ParTable=handles.ParTable;
ParTable.Data=cellstr(num2str([50;55;200;200;10;100]));
ParTable.ColumnName=ParTable.ColumnName(1);
ParTable.ColumnFormat={[]};
ParTable.ColumnWidth={65};
ParTable.Position(4)=9.2;
function varargout = FigureEight_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
%% Callbacks
function GoPush_Callback(hObject, eventdata, handles)
%Check input
HasEmpty=any(cellfun(@(x) isempty(x),handles.ParTable.Data));
if HasEmpty
    errordlg('Please fill in all the input values','Alon Spinner')
    return
end
%obtain legit input
Par=cellfun(@(x) str2num(x),handles.ParTable.Data);
Lradius=Par(1); Rradius=Par(2); Larm=Par(3); Rarm=Par(4); T=Par(5); w=Par(6);

%reset axes
EightAxes=handles.EightAxes;
cla(EightAxes,'reset');
axis(EightAxes,'equal');
grid(EightAxes,'on'); 
hold(EightAxes,'on'); 
xlabel(EightAxes,'x'); 
ylabel(EightAxes,'y'); 
title(EightAxes,'Them Wheels are rolling')

%constrained ground link length.
x0=Lradius+Rradius; 

%define Theta vectors
LTheta=T*linspace(0,2*pi,100*T); %Define full circle for left gear
if Rradius>Lradius %make sure we make full revolution on both gears
    LTheta=LTheta*Rradius/Lradius;
end
RTheta=-LTheta*Lradius/Rradius;

%Create figure and axes
BoxLength=(Lradius+Rradius+Larm+Rarm)/2;
xlim(EightAxes,[-BoxLength,BoxLength]);
ylim(EightAxes,[-BoxLength,BoxLength]);
%Draw gear boundries %NOTE: (0,0) is set to the center of the left gear
t=linspace(0,2*pi,100);
gearL=Lradius*exp(1i*t);
gearR=x0+Rradius*exp(1i*t); %draws a full circle
plot(EightAxes,gearL,'--','color',[0,0.7,0],'linewidth',3);
plot(EightAxes,gearR,'--','color',[0,0.7,0],'linewidth',3);

%Draw links and animation
[hvLr,hvRr,hvLa,hvRa]=deal(gobjects(1));
for j=1:length(LTheta)
    delete([hvLr,hvRr,hvLa,hvRa]);
    %find angles Lphi and Rphi
    delta=CalculateDelta(Lradius,Rradius,Larm,Rarm,x0,LTheta(j),RTheta(j));
    [Lphi,Rphi]=CalculateBetaGama(Lradius,Rradius,Larm,Rarm,x0,LTheta(j),RTheta(j),delta);
    %Calculate radii and arm vectors
    vLradius=Lradius*exp(1i*LTheta(j));
    vRradius=x0+Rradius*exp(1i*RTheta(j));
    vLarm=vLradius+Larm*exp(1i*Lphi);
    vRarm=vRradius+Rarm*exp(1i*Rphi);
    
    %plot links
    hvLr=plot(EightAxes,[0,vLradius],'b','linewidth',3);
    hvRr=plot(EightAxes,[x0,vRradius],'b','linewidth',3);
    hvLa=plot(EightAxes,[vLradius,vLarm],'r','linewidth',3);
    hvRa=plot(EightAxes,[vRradius,vRarm],'r','linewidth',3);
    
    %scatter a point on track
    plot(EightAxes,vLarm,'marker','o','color','k','markersize',1);
    
    pause(0.1/w);
end
%% Functions
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