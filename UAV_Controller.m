%% ========================================================================
%  FILE 5: UAV_Controller.m
%  UAV controller class - manages drone state and movement
%% ========================================================================

classdef UAV_Controller < handle
    properties
        position        % Current [x, y, z] position
        velocity        % Current velocity
        battery         % Battery level (0-100)
        config          % Configuration reference
        status          % Current status string
    end
    
    methods
        function obj = UAV_Controller(config)
            % Constructor
            obj.config = config;
            obj.position = [0, 0, 0];
            obj.velocity = [0, 0, 0];
            obj.battery = config.INITIAL_BATTERY;
            obj.status = 'INITIALIZING';
        end
        
        function setPosition(obj, pos)
            % Set UAV position
            obj.position = pos;
        end
        
        function pos = getPosition(obj)
            % Get current position
            pos = obj.position;
        end
        
        function moveTo(obj, targetPos, deltaTime)
            % Move UAV towards target position
            direction = targetPos - obj.position;
            distance = norm(direction);
            
            if distance > 0
                % Normalize direction
                direction = direction / distance;
                
                % Calculate movement
                maxDistance = obj.config.UAV_SPEED * deltaTime;
                actualDistance = min(maxDistance, distance);
                
                % Update position
                obj.position = obj.position + direction * actualDistance;
                obj.velocity = direction * obj.config.UAV_SPEED;
            else
                obj.velocity = [0, 0, 0];
            end
            
            % Add realistic jitter
            obj.position = obj.position + randn(1,3) * 0.2;
        end
        
        function updateBattery(obj, timeElapsed, totalTime)
            % Update battery level based on time
            % Uses configurable drain rate instead of linear depletion
            if isfield(obj.config, 'BATTERY_DRAIN_RATE')
                drainRate = obj.config.BATTERY_DRAIN_RATE;
            else
                drainRate = 0.5; % Default: 0.5% per second
            end
            
            obj.battery = obj.config.INITIAL_BATTERY - (timeElapsed * drainRate);
            obj.battery = max(0, min(100, obj.battery));
            
            % Update status based on battery
            if obj.battery < obj.config.LOW_BATTERY_WARNING
                obj.status = '⚠️ LOW BATTERY';
            else
                obj.status = '○ MONITORING...';
            end
        end
        
        function batteryLevel = getBattery(obj)
            % Get current battery level
            batteryLevel = obj.battery;
        end
        
        function stat = getStatus(obj)
            % Get current status
            stat = obj.status;
        end
        
        function setStatus(obj, newStatus)
            % Set UAV status
            obj.status = newStatus;
        end
        
        function speed = getSpeed(obj)
            % Get current speed
            speed = norm(obj.velocity);
        end
        
        function alt = getAltitude(obj)
            % Get altitude (Z coordinate)
            alt = obj.position(3);
        end
    end
end