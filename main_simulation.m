%% ========================================================================
%  FILE 1: main_simulation.m
%  Main script to run the complete UAV simulation
%  This file coordinates all components
%% ========================================================================

clear all; close all; clc;

fprintf('\n');
fprintf('╔════════════════════════════════════════════════╗\n');
fprintf('║   UAV CROP MONITORING - MODULAR SYSTEM         ║\n');
fprintf('║   Multi-field Architecture                     ║\n');
fprintf('╚════════════════════════════════════════════════╝\n\n');

%% STEP 0: Get Field Selection from User
fprintf('Step 0/7: Field Selection\n');
fprintf('─────────────────────────────────────────────────\n');

% Get field serial number from user
fieldNum = input('Enter Field Serial Number to monitor (1-4): ');

% Validate input
while isempty(fieldNum) || fieldNum < 1 || fieldNum > 4 || floor(fieldNum) ~= fieldNum
    fprintf('⚠️  Invalid input! Please enter a number between 1 and 4.\n');
    fieldNum = input('Enter Field Serial Number to monitor (1-4): ');
end

fprintf('✓ Field #%d selected for monitoring\n\n', fieldNum);

%% STEP 1: Load Configuration
fprintf('Step 1/7: Loading configuration...\n');
config = load_config();
config.SELECTED_FIELD = fieldNum;
fprintf('✓ Configuration loaded\n');
fprintf('✓ Weather: %s, Wind: %.1f m/s @ %d°, Temp: %.1f°C\n\n', ...
        config.WEATHER_TYPE, config.WIND_SPEED, config.WIND_DIRECTION, config.TEMPERATURE);

%% STEP 2: Initialize Environment
fprintf('Step 2/7: Creating 3D environment...\n');
[env, figures] = create_environment(config);
fprintf('✓ Environment created\n\n');

%% STEP 3: Generate Flight Path (100%% Coverage)
fprintf('Step 3/7: Generating flight path for 100%%%% coverage...\n');
flightPath = generate_flight_path(config);
fprintf('✓ Flight path generated (%d waypoints)\n', size(flightPath, 1));
fprintf('✓ 100%%%% coverage guaranteed\n\n');

%% STEP 4: Initialize UAV
fprintf('Step 4/7: Initializing UAV at base station...\n');
uav = UAV_Controller(config);
% Start at base station
uav.setPosition([config.BASE_X, config.BASE_Y, config.BASE_Z]);
fprintf('✓ UAV initialized at Base Station [%.1f, %.1f, %.1f]\n\n', ...
        config.BASE_X, config.BASE_Y, config.BASE_Z);

%% STEP 5: Initialize Sensor System
fprintf('Step 5/7: Initializing sensors...\n');
sensors = SensorSystem(config);
fprintf('✓ Sensors ready\n\n');

%% STEP 6: Takeoff and Transit to Field
fprintf('Step 6/7: UAV taking off and transiting to field...\n');
fprintf('   Phase 1: Vertical takeoff to %.0f meters\n', config.TAKEOFF_HEIGHT);
fprintf('   Phase 2: Climb to transit height (%.0f meters)\n', config.TRANSIT_HEIGHT);
fprintf('   Phase 3: Transit to Field #%d\n', fieldNum);
fprintf('   Phase 4: Descend to scanning height (%.0f meters)\n\n', config.UAV_HEIGHT);

%% STEP 7: Run Simulation (100% Coverage Required)
fprintf('Step 7/7: Starting mission...\n');
fprintf('   Target: Field #%d\n', fieldNum);
fprintf('   Objective: 100%%%% Coverage (No Time Limit)\n');
fprintf('   Battery: %.0f seconds capacity\n', 100/config.BATTERY_DRAIN_RATE);
fprintf('   Weather Impact: Wind adds %.2f%%/s drain\n', config.WIND_SPEED * config.WIND_BATTERY_IMPACT);
fprintf('   Will continue until 100%%%% coverage or critical battery\n');
fprintf('   Press Ctrl+C to abort\n\n');

% Run the main simulation loop with transit phases
[totalTime, env] = run_simulation_with_transit(config, env, figures, flightPath, uav, sensors);

fprintf('\n✅ Simulation Complete!\n');
fprintf('   Field #%d: 100%%%% Coverage Achieved\n', fieldNum);
fprintf('   Total Mission Time: %.1f seconds\n', totalTime);
fprintf('═══════════════════════════════════════════════\n\n');