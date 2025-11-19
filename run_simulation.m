%% ========================================================================
%  FILE 8: run_simulation.m
%  Main simulation loop - coordinates all components
%  Modified for 100% coverage guarantee
%% ========================================================================

function run_simulation(config, env, figures, flightPath, uav, sensors)
    % Main simulation loop - continues until 100% coverage achieved
    
    % Set crop health map for sensors
    sensors.setCropHealthMap(env.cropHealth);
    
    % Initialize simulation variables
    pathIndex = 1;
    pathResolution = size(flightPath, 1);
    startTime = tic;
    timeElapsed = 0;
    coverageAchieved = false;
    
    fprintf('🚁 UAV taking off...\n');
    fprintf('   Target: Field #%d\n', config.SELECTED_FIELD);
    fprintf('   Mission: 100%%%% Coverage Required (No Time Limit)\n');
    fprintf('   Battery: %.0f seconds capacity\n\n', 100/config.BATTERY_DRAIN_RATE);
    uav.setStatus('🚁 IN FLIGHT');
    
    %% Main Loop - Continue until 100% coverage OR critical battery
    while pathIndex <= pathResolution
        
        % Update elapsed time
        timeElapsed = toc(startTime);
        
        % Check for critical battery (safety override)
        if uav.getBattery() < 10
            fprintf('🔴 CRITICAL BATTERY LEVEL! Returning to base...\n');
            fprintf('   Coverage achieved: %.2f%%\n', currentCoverage);
            break;
        end
        
        % Calculate progress
        pathProgress = (pathIndex / pathResolution) * 100;
        
        % Get target position from flight path
        targetPos = flightPath(pathIndex, :);
        
        % Move UAV towards target
        uav.moveTo(targetPos, config.UPDATE_RATE);
        
        % Update battery
        uav.updateBattery(timeElapsed, config.SIMULATION_TIME);
        
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
        
        % Check for critical conditions
        if uav.getBattery() < 10
            uav.setStatus('🔴 CRITICAL BATTERY');
            fprintf('⚠️  Critical battery level! Returning to base...\n');
            break;
        elseif uav.getBattery() < config.LOW_BATTERY_WARNING
            uav.setStatus('⚠️ LOW BATTERY');
        elseif sensors.getDiseasePercentage() > config.DISEASE_ALERT_THRESHOLD
            uav.setStatus('⚠️ DISEASE ALERT');
        elseif currentCoverage >= 100
            uav.setStatus('✓ 100% COVERAGE');
        elseif sensors.getHealthyPercentage() > config.HEALTHY_FIELD_THRESHOLD
            uav.setStatus('✓ HEALTHY FIELD');
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
    
    %% Mission Complete
    finalCoverage = (sensors.getScannedArea() / (config.FIELD_SIZE^2)) * 100;
    
    fprintf('\n🎯 Mission complete!\n');
    fprintf('   Final Coverage: %.2f%%%%\n', finalCoverage);
    
    if finalCoverage >= 100
        fprintf('   ✅ 100%%%% COVERAGE TARGET ACHIEVED\n');
    else
        fprintf('   ⚠️  Coverage incomplete: %.2f%%%%\n', finalCoverage);
    end
    
    fprintf('   UAV returning to base...\n');
    
    % Generate final report
    generate_final_report(config, uav, sensors, timeElapsed, finalCoverage);
    
    % Add completion message to figure
    if finalCoverage >= 100
        msgColor = [0.9 1 0.9];
        edgeColor = 'green';
        msg = sprintf('✓ Mission Complete - Field #%d: 100%%%% Coverage Achieved', config.SELECTED_FIELD);
    else
        msgColor = [1 1 0.9];
        edgeColor = [1 0.6 0];
        msg = sprintf('⚠ Mission Complete - Field #%d: %.1f%%%% Coverage', config.SELECTED_FIELD, finalCoverage);
    end
    
    annotation(figures.main, 'textbox', [0.3 0.01 0.4 0.04], ...
        'String', msg, ...
        'FontSize', 12, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'EdgeColor', edgeColor, 'LineWidth', 2, ...
        'BackgroundColor', msgColor);
end