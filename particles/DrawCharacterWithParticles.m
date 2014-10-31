%[xybpoints] = DrawCharacter
%or
%[xybpoints] = DrawCharacter(maxtime)
%
%Shows a window where the user can draw and returns pen trace data
%
%Usage:
%Calling DrawCharacter displays a square canvas. The user can draw in this
%area by holding the left mouse button while moving the mouse. (Moving
%the mouse while no button is pressed does not leave any marks.)
%
%When the user closes the window, or after maxtime seconds have elapsed,
%the DrawCharacter command returns a matrix of mouse coordinates and
%binary button status variables sampled while the drawing window was shown.
%
%Input:
%maxtime=   Maximum time to show the canvas, in seconds. If this argument is
%           invalid or not provided, the default value 10 seconds is used.
%
%Output:
%xybpoints= Matrix containing mouse information triplets. The first row
%           contains mouse x-coordinates sampled at regular time intervals
%           while the drawing window was shown. The second row contains
%           corresponding y-coordinates, and the third row left mouse
%           button information for each frame; the third element is 1 in
%           frames where the user was drawing, and 0 elsewhere.
%
%Note:
%If the screen resolution is changed while Matlab is running, the mouse
%position and the point of drawing in the canvas may become decoupled.
%Restarting Matlab is likely to fix this problem.
%
%Gustav Eje Henter 2010-08-21 tested
%Gustav Eje Henter 2011-10-24 tested
%Gustav Eje Henter 2012-10-18 documentation updated

function [xybout] = DrawCharacter(maxtime)

global fh ah xybpoints fnum penstatus closeflag Particle_System step_time;

fps = 50; % Drawing frames per second

% Check and sanitize maxtime input
if (nargin < 1) || isempty(maxtime)...
        || (abs(maxtime(1)) <= 1) || (abs(maxtime) > 120),
    maxtime = 10; % Default window lifetime in seconds
else
    maxtime = abs(maxtime(1));
end

% Prepare canvas
Particle_System = particle_system ([0, 0, 0], 1, 1);
step_time = 0.04;

fh = Particle_System.graphics_handle;
axis([0 1 0 1]);
ah = gca;

figpos = get(fh,'Position');
figside = min(figpos(3:4));
set(fh,'Position',[figpos(1:2),[1,1]*figside]);

axis equal;
set(ah,'XTick',[]);
set(ah,'YTick',[]);
box on;
axis manual; % Fixe axis scale
hold on;

set(fh,'Pointer','crosshair');

% Add callbacks
set(fh,'WindowButtonDownFcn',{@penchng,1});
set(fh,'WindowButtonUpFcn',{@penchng,0});
set(fh,'CloseRequestFcn',@closeme);

% Initialize timer
freq = 1/fps;
maxframes = ceil(fps*maxtime);

timeframes = timer('TimerFcn',@addframe,'Period',freq,...
    'TasksToExecute',maxframes,'ExecutionMode','fixedSpacing');

% initialize variables
xybpoints = zeros(3,maxframes);
fnum = 0;
penstatus = 0;
closeflag = false;

start(timeframes); % Start checking mouse movements
waitfor(timeframes); % Wait for timer to stop (while collecting mouse data)

delete(fh); % Close drawing window

% Crop and set output
xybpoints = xybpoints(:,1:fnum);
xybout = xybpoints;

clear global fh ah penstatus closeflag xybpoints;

function addframe(obj,event)
global fh ah xybpoints fnum penstatus closeflag Particle_System step_time;

fnum = fnum + 1;

% If the mouse is pressed, we add particles
if (penstatus == 1)
    current_point = [get_coords(ah) 0];
    velocity = [0 0 0];
    if (fnum > 1)
        velocity = [(xybpoints(1:2, fnum) - xybpoints(1:2, fnum-1))' 0];
    end
    velocity = velocity/2.0 + 0.4 * rand (1, 3);
    Particles{fnum} = particle(Particle_System, 1 , current_point, velocity, false, 0.8);
end

Particle_System.advance_time(step_time);

% Register mouse status
xybpoints(:,fnum) = [get_coords(ah)';penstatus];

% Draw arc segment
if ((penstatus == 1) ...
        && (fnum > 1) ...
        && (xybpoints(3,fnum-1) == 1))
    plot(ah,xybpoints(1,fnum-[1,0]),xybpoints(2,fnum-[1,0]), '-r');
end

if closeflag,
    stop(obj);
end

function penchng(obj,event,newstatus)

global fh penstatus;

if strcmp(get(fh,'SelectionType'),'normal');
    penstatus = newstatus;
end

function closeme(obj,event)

global closeflag;
closeflag = true;

% Global coordinates -> axis coordinates transformation functions
% Adapted from gnovice at StackOverflow.com in a 2010-05-05 post, URL:
% http://stackoverflow.com/questions/2769430/matlab-convert-global
%                                        -coordinates-to-figure-coordinates

function value = get_in_units(hObject,propName,unitType)

oldUnits = get(hObject,'Units'); % Get the current units for hObject
set(hObject,'Units',unitType); % Set the units to unitType
value = get(hObject,propName); % Get the propName property of hObject
set(hObject,'Units',oldUnits); % Restore the previous units

function coords = get_coords(hAxes)

% Get the screen coordinates
coords = get_in_units(0,'PointerLocation','pixels');

% Get the figure position, axes position, and axes limits
hFigure = get(hAxes,'Parent');
figurePos = get_in_units(hFigure,'Position','pixels');
axesPos = get_in_units(hAxes,'Position','pixels');
axesLimits = [get(hAxes,'XLim').' get(hAxes,'YLim').'];

% Compute an offset and scaling for coords
offset = figurePos(1:2)+axesPos(1:2);
axesScale = diff(axesLimits)./axesPos(3:4);

% Apply the offsets and scaling
coords = (coords-offset).*axesScale+axesLimits(1,:);
