%% ========================================================================
%  FILE 12: run_simulation_with_transit.m
%  Main simulation with takeoff, transit, scanning, and return
%% ========================================================================

function [totalTime, env] = run_simulation_with_transit(config, env, figures, flightPath, uav, sensors)
    % Complete mission simulation with all phases
    
    missionStartTime = tic;
    
    %% PHASE 1: TAKEOFF
    [takeoffTime, env] = simulate_transit('takeoff', config, env, figures, uav, []);
    
    %% PHASE 2: TRANSIT TO FIELD
    startPos = get_field_start_position(config);
    [transitTime, env] = simulate_transit('transit_to_field', config, env, figures, uav, startPos);
    
    %% PHASE 3: FIELD SCANNING
    fprintf('📷 SCANNING FIELD #%d\n', config.SELECTED_FIELD);
    fprintf('   Mission: 100%%%% Coverage\n');
    fprintf('   Weather: %s, Wind: %.1fm/s, Temp: %.1f°C\n\n', ...
            config.WEATHER_TYPE, config.WIND_SPEED, config.TEMPERATURE);
    
    [scanTime, finalCoverage] = run_field_scan(config, env, figures, flightPath, uav, sensors);
    
    %% PHASE 4: RETURN TO BASE
    [returnTime, env] = simulate_transit('return_to_base', config, env, figures, uav, []);
    
    %% MISSION COMPLETE
    totalTime = toc(missionStartTime);
    
    fprintf('\n╔════════════════════════════════════════════════╗\n');
    fprintf('║         MISSION SUMMARY                        ║\n');
    fprintf('╠════════════════════════════════════════════════╣\n');
    fprintf('║ TOTAL MISSION:    %6.1f seconds              ║\n', totalTime);
    fprintf('║ Coverage:         %6.2f%%                  ║\n', finalCoverage);
    fprintf('║ Battery:          %6.1f%% remaining        ║\n', uav.getBattery());
    fprintf('╚════════════════════════════════════════════════╝\n');
    
    % Generate final report
    generate_final_report(config, uav, sensors, totalTime, finalCoverage);
end

%% Field Scanning Function
function [scanTime, finalCoverage] = run_field_scan(config, env, figures, flightPath, uav, sensors)
    % Set crop health map for sensors
    sensors.setCropHealthMap(env.cropHealth);
    
    % Initialize scanning variables
    pathIndex = 1;
    pathResolution = size(flightPath, 1);
    startTime = tic;
    timeElapsed = 0;
    coverageAchieved = false;
    
    uav.setStatus('🔍 SCANNING');
    
    %% Main Scanning Loop
    while pathIndex <= pathResolution
        
        % Update elapsed time
        timeElapsed = toc(startTime);
        
        % Check for critical battery
        if uav.getBattery() < 10
            fprintf('🔴 CRITICAL BATTERY LEVEL! Aborting scan...\n');
            currentCoverage = (sensors.getScannedArea() / (config.FIELD_SIZE^2)) * 100;
            fprintf('   Coverage achieved: %.2f%%\n', currentCoverage);
            break;
        end
        
        % Calculate progress
        pathProgress = (pathIndex / pathResolution) * 100;
        
        % Get target position from flight path
        targetPos = flightPath(pathIndex, :);
        
        % Move UAV towards target
        uav.moveTo(targetPos, config.UPDATE_RATE);
        
        % Apply wind drift during scanning
        if config.WIND_ENABLED
            windEffect = apply_wind_drift(config);
            uav.position = uav.position + windEffect;
        end
        
        % Update battery with weather impact
        weatherDrain = calculate_weather_impact(config);
        uav.battery = uav.battery - (config.BATTERY_DRAIN_RATE + weatherDrain) * config.UPDATE_RATE;
        uav.battery = max(0, min(100, uav.battery));
        
        % Perform sensor scan
        sensors.scan(uav.getPosition(), pathProgress);
        
        % Check for 100% coverage achievement
        currentCoverage = (sensors.getScannedArea() / (config.FIELD_SIZE^2)) * 100;
        
        if currentCoverage >= 100 && ~coverageAchieved
            coverageAchieved = true;
            fprintf('\n🎯 100%%%% COVERAGE ACHIEVED!\n');
            fprintf('   Time: %.1f seconds\n', timeElapsed);
            fprintf('   Completing final pass...\n\n');
        end
        
        % Update status based on conditions
        if uav.getBattery() < config.LOW_BATTERY_WARNING
            uav.setStatus('⚠️ LOW BATTERY');
        elseif currentCoverage >= 100
            uav.setStatus('✓ 100% COVERAGE');
        elseif sensors.getDiseasePercentage() > config.DISEASE_ALERT_THRESHOLD
            uav.setStatus('⚠️ DISEASE ALERT');
        else
            uav.setStatus('🔍 SCANNING');
        end
        
        % Update visualization
        update_visualization(env, figures, uav, sensors, config, timeElapsed, pathProgress);
        
        % Control simulation speed
        pause(config.UPDATE_RATE);
        
        % Advance to next waypoint
        stepSize = ceil(config.UAV_SPEED * config.UPDATE_RATE / ...
                       (config.FIELD_SIZE / pathResolution));
        pathIndex = pathIndex + stepSize;
    end
    
    scanTime = toc(startTime);
    finalCoverage = (sensors.getScannedArea() / (config.FIELD_SIZE^2)) * 100;
    
    fprintf('   ✓ Scanning complete\n');
    fprintf('   Coverage: %.2f%%\n', finalCoverage);
    fprintf('   Battery used: %.1f%%\n\n', config.INITIAL_BATTERY - uav.getBattery());
end

%% Helper: Apply Wind Drift
function windEffect = apply_wind_drift(config)
    windDir = deg2rad(config.WIND_DIRECTION);
    windX = config.WIND_SPEED * cos(windDir) * 0.02;
    windY = config.WIND_SPEED * sin(windDir) * 0.02;
    
    % Add turbulence
    turbX = (rand() - 0.5) * config.TURBULENCE_FACTOR * 0.1;
    turbY = (rand() - 0.5) * config.TURBULENCE_FACTOR * 0.1;
    
    windEffect = [windX + turbX, windY + turbY, 0];
end

%% Helper: Calculate Weather Impact on Battery
function weatherDrain = calculate_weather_impact(config)
    % Base wind drain
    windDrain = config.WIND_SPEED * config.WIND_BATTERY_IMPACT;
    
    % Temperature impact (optimal is 20-25°C)
    tempDiff = abs(config.TEMPERATURE - 22.5);
    tempDrain = tempDiff * 0.005; % 0.5% per 10°C difference
    
    % Humidity impact (high humidity = more drag)
    humidityDrain = (config.HUMIDITY - 50) * 0.001; % Small effect
    
    % Air density impact (higher altitude = less drag but more power needed)
    densityFactor = config.AIR_DENSITY / 1.225; % Normalized to sea level
    densityDrain = (1 - densityFactor) * 0.02;
    
    weatherDrain = windDrain + tempDrain + max(0, humidityDrain) + densityDrain;
end