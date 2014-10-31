classdef spring < handle
    
    properties
        
        particle_1
        particle_2
        rest
        strength
        damping
        graphics_handle
        
    end
    
    methods
        
        function Spring = spring (Particle_System, particle_1, particle_2, rest, strength, damping)
            %SPRING  Spring object constructor.
            %
            %   Examples
            %
            %   S = SPRING (PS, P1, P2) creates spring S between two
            %   particles P1 and P2 with default properties:
            %   rest (length): 1
            %   strength: 1
            %   damping: 0
            %   and appends it to the particle system PS
            %
            %   S = SPRING (PS, P1, P2, R, S, D) creates spring S between
            %   two particles P1 and P2 with the following properties:
            %   rest (length): R
            %   strength: S
            %   damping: D
            %   and appends it to the particle system PS
            
            %   Copyright 2008-2008, buchholz.hs-bremen.de
            
            if nargin == 3
                
                rest = 1;
                
                strength = 1;
                
                damping = 0;
                
            end
            
            Spring.particle_1 = particle_1;
            
            Spring.particle_2 = particle_2;
            
            Spring.rest = rest;
            
            Spring.strength = strength;
            
            Spring.damping = damping;
            
            Spring.append (Particle_System);
            
        end
        
        function delete (Spring)
            %DELETE  Delete spring.
            %
            %   Example
            %
            %   DELETE (S) deletes the spring S.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            if ishandle (Spring.graphics_handle)
                
                delete (Spring.graphics_handle)
                
            end
            
        end
        
        function update_graphics_position (Spring)
            %UPDATE_GRAPHICS_POSITION  Update the graphical spring representation.
            %
            %   Example
            %
            %   UPDATE_GRAPHICS_POSITION (S) updates the position of the
            %   graphical representation of the spring S.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            spring_position(1, 1:3) = Spring.particle_1.position;
            spring_position(2, 1:3) = Spring.particle_2.position;
            
            set (Spring.graphics_handle, ...
                'xdata', spring_position(:, 1), ...
                'ydata', spring_position(:, 2), ...
                'zdata', spring_position(:, 3));
            
        end
        
    end
        
    methods (Access = 'private')
        
        function append (Spring, Particle_System)
            %APPEND  Append spring to particle system.
            %
            %   Example
            %
            %   APPEND (S, PS) appends the spring S to the
            %   particle system PS.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            figure (Particle_System.graphics_handle)
            
            spring_position(1, 1:3) = Spring.particle_1.position;
            spring_position(2, 1:3) = Spring.particle_2.position;
            
            Spring.graphics_handle = ...
                line (...
                spring_position(:, 1), ...
                spring_position(:, 2), ...
                spring_position(:, 3), ...
                'linewidth', 1, ...
                'linestyle', '-', ...
                'color', [0 0 1]);
            
            Particle_System.springs = [Particle_System.springs, Spring];
            
        end
        
    end
    
end
