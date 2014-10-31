classdef particle < handle
    
    properties
        
        mass
        position
        velocity
        fixed
        lifespan
        age = 0
        force = [0 0 0]
        graphics_handle
        
    end
    
    methods
        
        function Particle = particle (Particle_System, mass, position, velocity, fixed, lifespan)
            %PARTICLE  Particle object constructor.
            %
            %   Examples
            %
            %   P = PARTICLE (PS) creates particle P with default
            %   properties:
            %   mass: 1
            %   position: [0 0 0]
            %   velocity: [0 0 0]
            %   fixed: false
            %   life span: inf
            %   and appends it to the particle system PS
            %
            %   P = PARTICLE (PS, M, PP, V, F, L) creates particle P with
            %   the following properties:
            %   mass: M
            %   position: PP (PP must be a 1-by-3 vector)
            %   velocity: V (V must be a 1-by-3 vector)
            %   fixed: F (F must be false (or 0) for a free or true (or 1)
            %   for a fixed particle)
            %   life span: L
            %   and appends it to the particle system PS
            
            %   Copyright 2008-2008, buchholz.hs-bremen.de
            
            if nargin == 1
                
                mass = 1;
                
                position = [0, 0, 0];
                
                velocity = [0, 0, 0];
                
                fixed = false;
                
                lifespan = inf;
                
            end
            
            Particle.mass = mass;
            
            Particle.position = position;
            
            Particle.velocity = velocity;
            
            Particle.fixed = fixed;
            
            Particle.lifespan = lifespan;
            
            Particle.append (Particle_System);
            
        end
        
        function clear_force (Particle)
            %CLEAR_FORCE  Clear particle force accumulator.
            %
            %   Example
            %   CLEAR_FORCE (P) clears the force accumulator of the particle P.
            %
            %   See also add_force.
            
            %   Copyright 2008-2008, buchholz.hs-bremen.de
            
            Particle.force = [0 0 0];
            
        end
        
        function add_force (Particle, force)
            %ADD_FORCE  Add force to particle force accumulator.
            %
            %   Example
            %
            %   ADD_FORCE (P, F) adds the force F to the force accumulator of the
            %   particle P.
            %
            %   See also clear_force.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            Particle.force = Particle.force + force;
            
        end
        
        function delete (Particle)
            %DELETE  Delete particle.
            %
            %   Example
            %
            %   DELETE (P) deletes the particle P.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            if ishandle (Particle.graphics_handle)
                
                delete (Particle.graphics_handle)
                
            end
            
        end
        
        function update_graphics_position (Particle)
            %UPDATE_GRAPHICS_POSITION  Update the graphical particle representation.
            %
            %   Example
            %
            %   UPDATE_GRAPHICS_POSITION (P) updates the position of the
            %   graphical representation of the particle P.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            set (Particle.graphics_handle, ...
                'xdata', Particle.position(1), ...
                'ydata', Particle.position(2), ...
                'zdata', Particle.position(3));
            
        end
        
        function set.fixed (Particle, fixed)
            %SET.FIXED  Pin a particle to its position.
            %
            %   Examples
            %
            %   P.FIXED = TRUE pins the particle P to its current position
            %   and changes its graphical representation to an asterisk.
            %
            %   P.FIXED = FALSE makes P a free particle and changes its 
            %   graphical representation to a dot.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            Particle.fixed = fixed;
            
            if Particle.fixed
                
                set (Particle.graphics_handle, 'markersize', 10, 'marker', '*')
                
            else
                
                set (Particle.graphics_handle, 'markersize', 30, 'marker', '.')
                
            end
            
        end
        
        function set.position (Particle, position)
            %SET.POSITION  Set the position of a particle.
            %
            %   Examples
            %
            %   P.POSITION = NEW_POSITION sets the current position of the 
            %   particle P to NEW_POSITION.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            Particle.position = position;
            
            Particle.update_graphics_position;
            
        end
        
    end
    
    methods (Access = 'private')
        
        function append (Particle, Particle_System)
            %APPEND  Append particle to particle system.
            %
            %   Example
            %
            %   APPEND (P, PS) appends the particle P to the
            %   particle system PS.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            figure (Particle_System.graphics_handle)
            
            Particle.graphics_handle = ...
                line ( ...
                Particle.position(1), ...
                Particle.position(2), ...
                Particle.position(3), ...
                'color', [1 0 0], ...
                'markersize', 30, ...
                'marker', '.');
            
            if Particle.fixed
                
                set (Particle.graphics_handle, 'markersize', 10, 'marker', '*')
                
            end
            
            Particle_System.particles = [Particle_System.particles, Particle];
            
        end
        
    end
    
end
