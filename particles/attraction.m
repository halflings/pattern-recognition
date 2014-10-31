classdef attraction < handle
    
    properties
        
        particle_1
        particle_2
        strength
        minimum_distance
        graphics_handle
        
    end
    
    methods
        
        function Attraction = attraction (Particle_System, particle_1, particle_2, strength, minimum_distance)
            %ATTRACTION  Attraction object constructor.
            %
            %   Examples
            %
            %   A = ATTRACTION (PS, P1, P2) creates attraction A between two particles
            %   P1 and P2 with default properties:
            %   strength: 1
            %   minimum_distance: 0
            %   and appends it to the particle system PS
            %
            %   A = ATTRACTION (PS, P1, P2, S, M) creates attraction A between
            %   two particles P1 and P2 with the following properties:
            %   strength: S
            %   minimum_distance: M
            %   and appends it to the particle system PS
            
            %   Copyright 2008-2008, buchholz.hs-bremen.de
            
            if nargin == 3
                
                strength = 1;
                
                minimum_distance = 0;
                
            end
            
            Attraction.particle_1 = particle_1;
            
            Attraction.particle_2 = particle_2;
            
            Attraction.strength = strength;
            
            Attraction.minimum_distance = minimum_distance;
            
            Attraction.append (Particle_System);
            
        end
        
        function delete (Attraction)
            %DELETE  Delete attraction.
            %
            %   Example
            %
            %   DELETE (A) deletes the attraction A.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            if ishandle (Attraction.graphics_handle)
                
                delete (Attraction.graphics_handle)
                
            end
            
        end
        
        function update_graphics_position (Attraction)
            %UPDATE_GRAPHICS_POSITION  Update the graphical attraction representation.
            %
            %   Example
            %
            %   UPDATE_GRAPHICS_POSITION (A) updates the position of the
            %   graphical representation of the attraction A.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            attraction_position(1, 1:3) = Attraction.particle_1.position;
            attraction_position(2, 1:3) = Attraction.particle_2.position;
            
            set (Attraction.graphics_handle, ...
                'xdata', attraction_position(:, 1), ...
                'ydata', attraction_position(:, 2), ...
                'zdata', attraction_position(:, 3));
            
        end
        
    end
    
    methods (Access = 'private')
        
        function append (Attraction, Particle_System)
            %APPEND  Append attraction to particle system.
            %
            %   Example
            %
            %   APPEND (A, PS) appends the attraction A to the
            %   particle system PS.
            
            %   Copyright 2008-2008 buchholz.hs-bremen.de
            
            figure (Particle_System.graphics_handle)
            
            attraction_position(1, 1:3) = Attraction.particle_1.position;
            attraction_position(2, 1:3) = Attraction.particle_2.position;
            
            Attraction.graphics_handle = ...
                line (...
                attraction_position(:, 1), ...
                attraction_position(:, 2), ...
                attraction_position(:, 3), ...
                'color', [0 0 1], ...
                'linestyle', ':');
            
            Particle_System.attractions = [Particle_System.attractions, Attraction];
            
        end
        
    end
    
end
