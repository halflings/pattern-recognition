classdef particle_system < handle
    
    properties
        
        gravity
        drag
        particles
        springs
        attractions
        time = 0
        graphics_handle
        
    end
    
    methods
        
        function Particle_System = particle_system (gravity, drag, limits)
            %PARTICLE_SYSTEM  Particle system object constructor.
            %
            %   Examples
            %
            %   PS = PARTICLE_SYSTEM creates particle system PS with default properties:
            %   gravity: [0 0 0] (no gravity)
            %   drag: 0
            %   (axes) limits: 1
            %
            %   PS = PARTICLE_SYSTEM (G, D, L) creates particle system PS with the following properties:
            %   gravity: G
            %   drag: D
            %   (axes) limits: L
            
            %   Copyright 2008-2008, buchholz.hs-bremen.de
            
            if nargin == 0
                
                gravity = [0, 0, 0];
                
                drag = 0;
                
                limits = 1;
                
            end
            
            Particle_System.gravity = gravity;
            
            Particle_System.drag = drag;
            
            Particle_System.graphics_handle = figure;
            
            set (Particle_System.graphics_handle, 'renderer', 'opengl')
            
            % Arx fatalis background
            a = axes('Position',[0 0 1 1],'Units','Normalized');
            ah = axes('unit', 'normalized', 'position', [0 0 1 1]);
            bg = imread('arx.jpg'); imagesc(bg);
            set(ah,'handlevisibility','off','visible','off')
            set(gcf, 'Color', 'None');
            set(gca, 'Color', 'None');
            uistack(ah, 'bottom');

        end
        
        function advance_time (Particle_System, step_time)
            %ADVANCE_TIME  Advance particle system time.
            %
            %   Example
            %
            %   ADVANCE_TIME (PS, ST) increments the current time property
            %   of the particle system PS for step time ST.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            Particle_System.kill_old_particles;
            
            time_start = Particle_System.time;
            time_end = time_start + step_time;
            
            phase_space_state = Particle_System.get_phase_space_state;
            
            phase_space_states = ode4 (...
                @compute_state_derivative, ...
                [time_start, time_end], ...
                phase_space_state, ...
                Particle_System);
            
            phase_space_state = phase_space_states(2,:);
            
            Particle_System.set_phase_space_state (phase_space_state);
            
            Particle_System.time = time_end;
            
            Particle_System.advance_particles_ages (step_time);
            
            Particle_System.update_graphics_positions;
            
            function Y = ode4(odefun,tspan,y0,varargin)
                %ODE4  Solve differential equations with a non-adaptive method of order 4.
                %   Y = ODE4(ODEFUN,TSPAN,Y0) with TSPAN = [T1, T2, T3, ... TN] integrates
                %   the system of differential equations y' = f(t,y) by stepping from T0 to
                %   T1 to TN. Function ODEFUN(T,Y) must return f(t,y) in a column vector.
                %   The vector Y0 is the initial conditions at T0. Each row in the solution
                %   array Y corresponds to a time specified in TSPAN.
                %
                %   Y = ODE4(ODEFUN,TSPAN,Y0,P1,P2...) passes the additional parameters
                %   P1,P2... to the derivative function as ODEFUN(T,Y,P1,P2...).
                %
                %   This is a non-adaptive solver. The step sequence is determined by TSPAN
                %   but the derivative function ODEFUN is evaluated multiple times per step.
                %   The solver implements the classical Runge-Kutta method of order 4.
                %
                %   Example
                %         tspan = 0:0.1:20;
                %         y = ode4(@vdp1,tspan,[2 0]);
                %         plot(tspan,y(:,1));
                %     solves the system y' = vdp1(t,y) with a constant step size of 0.1,
                %     and plots the first component of the solution.
                %
                
                if ~isnumeric(tspan)
                    error('TSPAN should be a vector of integration steps.');
                end
                
                if ~isnumeric(y0)
                    error('Y0 should be a vector of initial conditions.');
                end
                
                h = diff(tspan);
                if any(sign(h(1))*h <= 0)
                    error('Entries of TSPAN are not in order.')
                end
                
                try
                    f0 = feval(odefun,tspan(1),y0,varargin{:});
                catch
                    msg = ['Unable to evaluate the ODEFUN at t0,y0. ',lasterr];
                    error(msg);
                end
                
                y0 = y0(:);   % Make a column vector.
                if ~isequal(size(y0),size(f0))
                    error('Inconsistent sizes of Y0 and f(t0,y0).');
                end
                
                neq = length(y0);
                N = length(tspan);
                Y = zeros(neq,N);
                F = zeros(neq,4);
                
                Y(:,1) = y0;
                for i = 2:N
                    ti = tspan(i-1);
                    hi = h(i-1);
                    yi = Y(:,i-1);
                    F(:,1) = feval(odefun,ti,yi,varargin{:});
                    F(:,2) = feval(odefun,ti+0.5*hi,yi+0.5*hi*F(:,1),varargin{:});
                    F(:,3) = feval(odefun,ti+0.5*hi,yi+0.5*hi*F(:,2),varargin{:});
                    F(:,4) = feval(odefun,tspan(i),yi+hi*F(:,3),varargin{:});
                    Y(:,i) = yi + (hi/6)*(F(:,1) + 2*F(:,2) + 2*F(:,3) + F(:,4));
                end
                Y = Y.';
                
            end
            
        end
        
        function particles_positions = get_particles_positions (Particle_System)
            %GET_PARTICLES_POSITIONS  Retrieve particle system particles positions.
            %
            %   Example
            %
            %   P = GET_PARTICLES_POSITIONS (PS) returns the vectors of all
            %   particles positions of the particle system PS concatenated
            %   into one long row vector P.
            %
            %   See also get_particles_velocities.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            n_particles = length (Particle_System.particles);
            
            particles_positions = zeros (1, 3*n_particles);
            
            for i_particle = 1 : n_particles
                
                Particle = Particle_System.particles(i_particle);
                
                particles_positions (3*i_particle - 2 : 3*i_particle) = ...
                    Particle.position;
                
            end
            
        end
        
        function particles_velocities = get_particles_velocities (Particle_System)
            %GET_PARTICLES_VELOCITIES  Retrieve particle system particles velocities.
            %
            %   Example
            %
            %   V = GET_PARTICLES_VELOCITIES (PS) returns the vectors of all particles velocities
            %   of the particle system PS concatenated into one long row vector V.
            %
            %   See also get_particle_positions.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            n_particles = length (Particle_System.particles);
            
            particles_velocities = zeros (1, 3*n_particles);
            
            for i_particle = 1 : n_particles
                
                Particle = Particle_System.particles(i_particle);
                
                if Particle.fixed
                    
                    velocity = [0, 0, 0];
                    
                else
                    
                    velocity = Particle.velocity;
                    
                end
                
                particles_velocities (3*i_particle - 2 : 3*i_particle) = ...
                    velocity;
                
            end
            
        end
        
        function kill_attraction (Particle_System, Attraction)
            %KILL_ATTRACTION  Delete attraction from particle system.
            %
            %   Example
            %
            %   KILL_ATTRACTION (PS, A) deletes the attraction A
            %   from the particle system PS.
            %
            %   See also kill_particle, kill_spring.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            index = Particle_System.attractions == Attraction;
            
            Particle_System.attractions(index) = [];
            
            Attraction.delete;
            
        end
        
        function kill_particle (Particle_System, Particle)
            %KILL_PARTICLE  Delete particle from particle system.
            %
            %   Example
            %
            %   KILL_PARTICLE (PS, P) deletes the particle P
            %   from the particle system PS. Additionally, all
            %   attractions and springs that are connected
            %   to the deleted particle are deleted as well.
            %
            %   See also kill_attraction, kill_spring.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            % Initialize the buffer of the attractions to be killed
            attractions_to_be_killed = [];
            
            % Loop over all attractions
            for i_attraction = 1 : length (Particle_System.attractions)
                
                % Extract the current attraction
                Attraction = Particle_System.attractions(i_attraction);
                
                % Extract both connected particles
                Particle_1 = Attraction.particle_1;
                Particle_2 = Attraction.particle_2;
                
                % If the particle to be killed is one of the particles
                % at the ends of the current attraction,
                if Particle == Particle_1 || Particle == Particle_2
                    
                    % the current attraction has to be killed too (-> later).
                    % This can't be done immediatedly
                    % (the handle has to be buffered),
                    % because we are still inside a loop over all attractions
                    attractions_to_be_killed = [attractions_to_be_killed, Attraction];
                    
                end
                
            end
            
            % Loop over all attractions to be killed
            for i_attraction = attractions_to_be_killed
                
                % Kill it
                Particle_System.kill_attraction (i_attraction);
                
            end
            
            % Initialize the buffer of the springs to be killed
            springs_to_be_killed = [];
            
            % Loop over all springs
            for i_spring = 1 : length (Particle_System.springs)
                
                % Extract the current spring
                Spring = Particle_System.springs(i_spring);
                
                % Extract the indices of both connected particles
                % Extract both connected particles
                Particle_1 = Spring.particle_1;
                Particle_2 = Spring.particle_2;
                
                % If the particle to be killed is one of the particles
                % at the ends of the current spring,
                if Particle == Particle_1 || Particle == Particle_2
                    
                    % the current spring has to be killed too (-> later).
                    % This can't be done immediatedly
                    % (the handle has to be buffered),
                    % because we are still inside a loop over all springs
                    springs_to_be_killed = [springs_to_be_killed, Spring];
                    
                end
                
            end
            
            % Loop over all springs to be killed
            for i_spring = springs_to_be_killed
                
                % Kill it
                Particle_System.kill_spring (i_spring);
                
            end
            
            % Find the reference of the particle in the particle system
            % particles property
            index = Particle_System.particles == Particle;
            
            % Delete the particle reference in the particle system
            % particle property
            Particle_System.particles(index) = [];
            
            % Delete the actual particle
            Particle.delete;
            
        end
        
        function kill_spring (Particle_System, Spring)
            %KILL_SPRING  Delete spring from particle system.
            %
            %   Example
            %
            %   KILL_SPRING (PS, S) deletes the spring S
            %   from the particle system PS.
            %
            %   See also kill_attraction, kill_particle.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            index = Particle_System.springs == Spring;
            
            Particle_System.springs(index) = [];
            
            Spring.delete;
            
        end
        
    end
    
    methods  (Access = 'private')
        
        function advance_particles_ages (Particle_System, step_time)
            %ADVANCE_PARTICLES_AGES  Increment the ages of all particles.
            %
            %   Example
            %
            %   ADVANCE_PARTICLES_AGES (PS, ST) increments the age property
            %   of all particles in the particle system PS for step time ST.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            for i_particle = 1 : length (Particle_System.particles)
                
                Particle = Particle_System.particles(i_particle);
                
                Particle.age = Particle.age + step_time;
                
            end
            
        end
        
        function aggregate_attractions_forces (Particle_System)
            %AGGREGATE_ATTRACTIONS_FORCES  Aggregate attraction forces.
            %
            %   Example
            %
            %   AGGREGATE_ATTRACTIONS_FORCES (PS) aggregates the forces of all
            %   attractions in the particle system PS on all particles they are connected to
            %   in the corresponding particle force accumulators.
            %
            %   See also aggregate_forces, aggregate_drag_forces, aggregate_gravity_forces,
            %   aggregate_spring_forces.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            for i_attraction = 1 : length (Particle_System.attractions)
                
                Attraction = Particle_System.attractions(i_attraction);
                
                Particle_1 = Attraction.particle_1;
                Particle_2 = Attraction.particle_2;
                
                position_delta = Particle_2.position - Particle_1.position;
                
                position_delta_norm = norm (position_delta);
                
                if position_delta_norm < Attraction.minimum_distance
                    
                    position_delta_norm = Attraction.minimum_distance;
                    
                end
                
                attraction_force = ...
                    Attraction.strength* ...
                    Particle_1.mass* ...
                    Particle_2.mass* ...
                    position_delta/ ...
                    position_delta_norm/ ...
                    position_delta_norm/ ...
                    position_delta_norm;
                
                Particle_1.add_force (attraction_force);
                Particle_2.add_force (-attraction_force);
                
            end
            
        end
        
        function aggregate_drag_forces (Particle_System)
            %AGGREGATE_DRAG_FORCES  Aggregate drag forces.
            %
            %   Example
            %
            %   AGGREGATE_DRAG_FORCES (PS) aggregates the drag forces
            %   in the particle system PS on all particles
            %   in the corresponding particle force accumulators.
            %
            %   See also aggregate_forces, aggregate_attraction_forces, aggregate_gravity_forces,
            %   aggregate_spring_forces.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            for i_particle = 1 : length (Particle_System.particles)
                
                Particle = Particle_System.particles(i_particle);
                
                drag_force = - Particle_System.drag*Particle.velocity;
                
                Particle.add_force (drag_force);
                
            end
            
        end
        
        function aggregate_forces (Particle_System)
            %AGGREGATE_FORCES  Aggregate forces on all particles.
            %
            %   Example
            %
            %   AGGREGATE_FORCES (PS) aggregates the spring, attraction, drag, and
            %   gravity forces in the particle system PS on all particles
            %   in the corresponding particle force accumulators.
            %
            %   See also aggregate_attraction_forces, aggregate_drag_forces,
            %   aggregate_gravity_forces, aggregate_spring_forces, clear_particle_forces.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            Particle_System.clear_particles_forces;
            
            Particle_System.aggregate_springs_forces;
            Particle_System.aggregate_attractions_forces;
            Particle_System.aggregate_drag_forces;
            Particle_System.aggregate_gravity_forces;
            
        end
        
        function aggregate_gravity_forces (Particle_System)
            %AGGREGATE_GRAVITY_FORCES  Aggregate gravity forces.
            %
            %   Example
            %
            %   AGGREGATE_GRAVITY_FORCES (PS) aggregates the gravity forces
            %   in the particle system PS on all particles
            %   in the corresponding particle force accumulators.
            %
            %   See also aggregate_forces, aggregate_attraction_forces, aggregate_drag_forces,
            %   aggregate_spring_forces.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            for i_particle = 1 : length (Particle_System.particles)
                
                Particle = Particle_System.particles(i_particle);
                
                gravity_force = Particle.mass*Particle_System.gravity;
                
                Particle.add_force (gravity_force);
                
            end
            
        end
        
        function aggregate_springs_forces (Particle_System)
            %AGGREGATE_SPRINGS_FORCES  Aggregate spring forces.
            %
            %   Example
            %
            %   AGGREGATE_SPRINGS_FORCES (PS) aggregates the forces of all
            %   springs in the particle system PS on all particles they are connected to
            %   in the corresponding particle force accumulators.
            %
            %   See also aggregate_forces, aggregate_attraction_forces, aggregate_drag_forces,
            %   aggregate_gravity_forces.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            for i_spring = 1 : length (Particle_System.springs)
                
                Spring = Particle_System.springs(i_spring);
                
                Particle_1 = Spring.particle_1;
                Particle_2 = Spring.particle_2;
                
                position_delta = Particle_2.position - Particle_1.position;
                
                position_delta_norm = norm (position_delta);
                
                % If the user makes the initial positions of two particles identical
                % we have to avoid a "divide by zero" exception
                if position_delta_norm < eps
                    
                    position_delta_norm = eps;
                    
                end
                
                position_delta_unit = position_delta/position_delta_norm;
                
                spring_force = Spring.strength*position_delta_unit*(position_delta_norm - Spring.rest);
                
                Particle_1.add_force (spring_force);
                Particle_2.add_force (-spring_force);
                
                velocity_delta = Particle_2.velocity - Particle_1.velocity;
                
                projection_velocity_delta_on_position_delta = ...
                    dot (position_delta_unit, velocity_delta)*position_delta_unit;
                
                damping_force = Spring.damping*projection_velocity_delta_on_position_delta;
                
                Particle_1.add_force (damping_force);
                Particle_2.add_force (-damping_force);
                
            end
            
        end
        
        function clear_particles_forces (Particle_System)
            %CLEAR_PARTICLES_FORCES  Clear all particle forces.
            %
            %   Example
            %
            %   CLEAR_PARTICLES_FORCES (PS) clears the force accumulators of all particles
            %   in the particle system PS.
            %
            %   See also aggregate_forces.
            %
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            for i_particle = 1 : length (Particle_System.particles)
                
                Particle = Particle_System.particles(i_particle);
                
                Particle.clear_force;
                
            end
            
        end
        
        function state_derivative = compute_state_derivative ...
                (time, phase_space_state, Particle_System)
            %COMPUTE_STATE_DERIVATIVE  Compute state derivative vector.
            %
            %   Example
            %
            %   SD = COMPUTE_STATE_DERIVATIVE (T, SS, PS) returns the 6*N-by-1
            %   phase space state derivative vector SD of the particle system PS at time T.
            %   SS is the current 6*N-by-1 phase space state vector.
            %   N is the number of particles.
            %
            %   See also ode4, set_phase_space_state, aggregate_forces,
            %   get_particles_velocities, get_particles_accelerations.
            %
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            phase_space_state = phase_space_state(:)';
            
            Particle_System.set_phase_space_state (phase_space_state);
            
            Particle_System.aggregate_forces;
            
            velocities = Particle_System.get_particles_velocities;
            
            accelerations = Particle_System.get_particles_accelerations;
            
            state_derivative = [velocities, accelerations]';
            
        end
        
        function accelerations = get_particles_accelerations (Particle_System)
            %GET_PARTICLES_ACCELERATIONS  Retrieve particle accelerations from particle system.
            %
            %   Example
            %
            %   A = GET_PARTICLES_ACCELERATIONS (PS) returns the 1-by-3*N acceleration vector A
            %   of all particles from the particle system PS, where N is the number of
            %   particles.
            %
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            n_particles = length (Particle_System.particles);
            
            accelerations = zeros (1, 3*n_particles);
            
            for i_particle = 1 : n_particles
                
                Particle = Particle_System.particles(i_particle);
                
                if Particle.fixed
                    
                    force = [0 0 0];
                    
                else
                    
                    force = Particle.force;
                    
                end
                
                accelerations (3*i_particle - 2 : 3*i_particle) = ...
                    force/Particle.mass;
                
            end
            
        end
        
        function phase_space_state = get_phase_space_state (Particle_System)
            %GET_PHASE_SPACE_STATE  Retrieve phase space state vector.
            %
            %   Example
            %
            %   SS = GET_PHASE_SPACE_STATE (PS) returns the current 1-by-6*N
            %   phase space state vector SS from the particle system PS.
            %   N is the number of particles.
            %
            %   See also set_phase_space_state.
            %
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            positions = get_particles_positions (Particle_System);
            velocities = get_particles_velocities (Particle_System);
            
            phase_space_state = [positions, velocities];
            
        end
        
        function kill_old_particles (Particle_System)
            %KILL_OLD_PARTICLES  Kill old particles.
            %
            %   Example
            %
            %   KILL_OLD_PARTICLES (PS) kills all particles
            %   in the particle system PS
            %   that are older than their life span.
            %
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            % Initialize the buffer of the particles to be killed
            particles_to_be_killed = [];
            
            for i_particle = 1 : length (Particle_System.particles)
                
                Particle = Particle_System.particles(i_particle);
                
                if Particle.age > Particle.lifespan
                    
                    % the current particle has to be killed too (-> later).
                    % This can't be done immediatedly (the handle has to be buffered),
                    % because we are still inside a loop over all particles
                    particles_to_be_killed = [particles_to_be_killed, Particle];
                    
                end
                
            end
            
            % Loop over all particles to be killed
            for i_particle = particles_to_be_killed
                
                % Kill it
                Particle_System.kill_particle (i_particle);
                
            end
            
        end
        
        function set_phase_space_state (Particle_System, phase_space_state)
            %SET_PHASE_SPACE_STATE  Set phase space state vector.
            %
            %   Example
            %
            %   SET_PHASE_SPACE_STATE (PS, SS) sets the
            %   phase space state vector of the particle system PS to SS.
            %   SS must be a 1-by-6*N vector. N is the number of particles.
            %
            %   See also get_phase_space_state.
            %
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            n_particles = length (Particle_System.particles);
            
            for i_particle = 1 : n_particles
                
                Particle = Particle_System.particles(i_particle);
                
                Particle.position = ...
                    phase_space_state(3*i_particle - 2 : 3*i_particle);
                
                Particle.velocity = ...
                    phase_space_state(3*(i_particle + n_particles) - 2 : 3*(i_particle + n_particles));
                
            end
            
        end
        
        function update_graphics_positions (Particle_System)
            %UPDATE_GRAPHICS_POSITIONS  Update graphics positions.
            %
            %   Example
            %
            %   UPDATE_GRAPHICS_POSITIONS (PS) updates the graphics positions of all
            %   particles, springs, and attractions of the particle system PS.
            %
            %   See also get_particles_positions.
            %
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            for i_particle = 1 : length (Particle_System.particles)
                
                Particle_System.particles(i_particle).update_graphics_position;
                
            end
            
            for i_spring = 1 : length (Particle_System.springs)
                
                Particle_System.springs(i_spring).update_graphics_position;
                
            end
            
            for i_attraction = 1 : length (Particle_System.attractions)
                
                Particle_System.attractions(i_attraction).update_graphics_position;
            end
            
            drawnow
            
        end
        
    end
    
end

