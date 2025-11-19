%% ========================================================================
%  FILE 11: simulate_transit.m
%  Simulates UAV takeoff, transit to field, and return to base
%% ========================================================================

function [timeElapsed, env] = simulate_transit(phase, config, env, figures, uav, targetPos)
    % Simulates different transit phases
    % phase: 'takeoff', 'transit_to_field', 'return_to_base'
    
    startTime = tic;
    currentPos = uav.getPosition();
    
    switch phase
        case 'takeoff'
            fprintf('🚁 TAKEOFF INITIATED\n');
            fprintf('   Vertical climb to %.0f meters...\n', config.TAKEOFF_HEIGHT);
            
            % Vertical takeoff animation
            targetHeight = config.TAKEOFF_HEIGHT;
            steps = 20;
            
            for i = 1:steps
                % Update height
                newZ = currentPos(3) + (targetHeight - currentPos(3)) * i/steps;
                uav.setPosition([currentPos(1), currentPos(2), newZ]);
                
                % Apply wind effect
                windEffect = apply_wind(config);
                uav.position = uav.position + windEffect * 0.1;
                
                % Update battery with wind impact
                windDrain = config.WIND_SPEED * config.WIND_BATTERY_IMPACT;
                uav.battery = uav.battery - (config.BATTERY_DRAIN_RATE + windDrain) * 0.1;
                
                % Update visualization
                update_uav_visual(env, figures, uav, config);
                pause(0.1);
            end
            
            fprintf('   ✓ Takeoff complete - Altitude: %.1f m\n', uav.position(3));
            
        case 'transit_to_field'
            fprintf('✈️  TRANSITING TO FIELD #%d\n', config.SELECTED_FIELD);
            
            % Phase 1: Climb to transit height
            fprintf('   Climbing to transit altitude (%.0f m)...\n', config.TRANSIT_HEIGHT);
            steps = 15;
            for i = 1:steps
                newZ = currentPos(3) + (config.TRANSIT_HEIGHT - currentPos(3)) * i/steps;
                uav.setPosition([currentPos(1), currentPos(2), newZ]);
                
                windEffect = apply_wind(config);
                uav.position = uav.position + windEffect * 0.05;
                
                windDrain = config.WIND_SPEED * config.WIND_BATTERY_IMPACT;
                uav.battery = uav.battery - (config.BATTERY_DRAIN_RATE + windDrain) * 0.08;
                
                update_uav_visual(env, figures, uav, config);
                pause(0.08);
            end
            
            % Phase 2: Horizontal transit to field
            fprintf('   Transit flight to field (%.1f m/s)...\n', config.TRANSIT_SPEED);
            distance = norm(targetPos - uav.position);
            transitTime = distance / config.TRANSIT_SPEED;
            steps = ceil(transitTime / 0.1);
            
            for i = 1:steps
                % Move towards target
                direction = (targetPos - uav.position) / norm(targetPos - uav.position);
                newPos = uav.position + direction * config.TRANSIT_SPEED * 0.1;
                uav.setPosition(newPos);
                
                % Strong wind effect during transit
                windEffect = apply_wind(config);
                uav.position = uav.position + windEffect * 0.2;
                
                % Higher battery drain during fast transit
                windDrain = config.WIND_SPEED * config.WIND_BATTERY_IMPACT;
                uav.battery = uav.battery - (config.BATTERY_DRAIN_RATE * 1.5 + windDrain) * 0.1;
                
                % Update trail
                if config.SHOW_TRAIL
                    env.trailData = [env.trailData; uav.position];
                    if size(env.trailData, 1) > config.TRAIL_LENGTH
                        env.trailData = env.trailData(end-config.TRAIL_LENGTH+1:end, :);
                    end
                end
                
                update_uav_visual(env, figures, uav, config);
                pause(0.1);
            end
            
            % Phase 3: Descend to scanning altitude
            fprintf('   Descending to scanning altitude (%.0f m)...\n', config.UAV_HEIGHT);
            steps = 10;
            for i = 1:steps
                currentZ = uav.position(3);
                newZ = currentZ + (config.UAV_HEIGHT - currentZ) * i/steps;
                uav.setPosition([uav.position(1), uav.position(2), newZ]);
                
                windEffect = apply_wind(config);
                uav.position = uav.position + windEffect * 0.05;
                
                windDrain = config.WIND_SPEED * config.WIND_BATTERY_IMPACT;
                uav.battery = uav.battery - (config.BATTERY_DRAIN_RATE + windDrain) * 0.08;
                
                update_uav_visual(env, figures, uav, config);
                pause(0.08);
            end
            
            fprintf('   ✓ Arrived at Field #%d - Ready to scan\n', config.SELECTED_FIELD);
            
        case 'return_to_base'
            fprintf('🏠 RETURNING TO BASE\n');
            
            % Phase 1: Climb to transit height
            fprintf('   Climbing to transit altitude...\n');
            steps = 10;
            for i = 1:steps
                newZ = currentPos(3) + (config.TRANSIT_HEIGHT - currentPos(3)) * i/steps;
                uav.setPosition([currentPos(1), currentPos(2), newZ]);
                
                windEffect = apply_wind(config);
                uav.position = uav.position + windEffect * 0.05;
                
                windDrain = config.WIND_SPEED * config.WIND_BATTERY_IMPACT;
                uav.battery = uav.battery - (config.BATTERY_DRAIN_RATE + windDrain) * 0.08;
                
                update_uav_visual(env, figures, uav, config);
                pause(0.08);
            end
            
            % Phase 2: Transit back to base
            fprintf('   Transiting to base station...\n');
            basePos = [config.BASE_X, config.BASE_Y, config.TRANSIT_HEIGHT];
            distance = norm(basePos - uav.position);
            transitTime = distance / config.TRANSIT_SPEED;
            steps = ceil(transitTime / 0.1);
            
            for i = 1:steps
                direction = (basePos - uav.position) / norm(basePos - uav.position);
                newPos = uav.position + direction * config.TRANSIT_SPEED * 0.1;
                uav.setPosition(newPos);
                
                windEffect = apply_wind(config);
                uav.position = uav.position + windEffect * 0.2;
                
                windDrain = config.WIND_SPEED * config.WIND_BATTERY_IMPACT;
                uav.battery = uav.battery - (config.BATTERY_DRAIN_RATE * 1.5 + windDrain) * 0.1;
                
                if config.SHOW_TRAIL
                    env.trailData = [env.trailData; uav.position];
                    if size(env.trailData, 1) > config.TRAIL_LENGTH
                        env.trailData = env.trailData(end-config.TRAIL_LENGTH+1:end, :);
                    end
                end
                
                update_uav_visual(env, figures, uav, config);
                pause(0.1);
            end
            
            % Phase 3: Landing
            fprintf('   Landing at base station...\n');
            steps = 15;
            for i = 1:steps
                currentZ = uav.position(3);
                newZ = currentZ * (1 - i/steps);
                uav.setPosition([config.BASE_X, config.BASE_Y, newZ]);
                
                windEffect = apply_wind(config) * (1 - i/steps); % Less wind effect near ground
                uav.position = uav.position + windEffect * 0.05;
                
                windDrain = config.WIND_SPEED * config.WIND_BATTERY_IMPACT * 0.5;
                uav.battery = uav.battery - (config.BATTERY_DRAIN_RATE + windDrain) * 0.08;
                
                update_uav_visual(env, figures, uav, config);
                pause(0.08);
            end
            
            % Ensure on ground
            uav.setPosition([config.BASE_X, config.BASE_Y, 0]);
            update_uav_visual(env, figures, uav, config);
            
            fprintf('   ✓ Landed safely at base station\n');
            fprintf('   ✓ Final battery: %.1f%%\n', uav.battery);
    end
    
    timeElapsed = toc(startTime);
    fprintf('   Phase duration: %.1f seconds\n\n', timeElapsed);
end

%% Helper: Apply Wind Effect
function windEffect = apply_wind(config)
    if ~config.WIND_ENABLED
        windEffect = [0, 0, 0];
        return;
    end
    
    % Convert wind direction to radians
    windDir = deg2rad(config.WIND_DIRECTION);
    
    % Base wind vector
    windX = config.WIND_SPEED * cos(windDir);
    windY = config.WIND_SPEED * sin(windDir);
    
    % Add variability (gusts)
    gustFactor = 1 + (rand() - 0.5) * config.WIND_VARIABILITY;
    
    windEffect = [windX * gustFactor, windY * gustFactor, 0] * 0.05;
end

%% Helper: Update UAV Visual
function update_uav_visual(env, figures, uav, config)
    uavPos = uav.getPosition();
    
    % Update UAV position
    set(env.uavPlot, 'XData', uavPos(1)+env.uavX, ...
                     'YData', uavPos(2)+env.uavY, ...
                     'ZData', uavPos(3)+env.uavZ);
    
    set(env.uavBody, 'XData', uavPos(1), ...
                     'YData', uavPos(2), ...
                     'ZData', uavPos(3));
    
    % Update trail
    if config.SHOW_TRAIL
        set(env.trailPlot, 'XData', env.trailData(:,1), ...
                           'YData', env.trailData(:,2), ...
                           'ZData', env.trailData(:,3));
    end
    
    % Update top-down view
    set(env.uavDot, 'XData', uavPos(1), 'YData', uavPos(2));
    if config.SHOW_TRAIL
        set(env.trailTop, 'XData', env.trailData(:,1), 'YData', env.trailData(:,2));
    end
    
    drawnow;
end