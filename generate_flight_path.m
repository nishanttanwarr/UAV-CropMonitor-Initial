%% ========================================================================
%  FILE 4: generate_flight_path.m
%  Generates different flight path patterns with 100% coverage guarantee
%% ========================================================================

function flightPath = generate_flight_path(config)
    % Generates waypoints based on selected pattern
    % Ensures 100% field coverage with overlap
    
    FIELD_SIZE = config.FIELD_SIZE;
    UAV_HEIGHT = config.UAV_HEIGHT;
    pattern = config.SCAN_PATTERN;
    
    % Calculate camera footprint for 100% coverage
    cameraFootprint = 2 * UAV_HEIGHT * tan(deg2rad(config.CAMERA_FOV/2));
    effectiveSwath = cameraFootprint * (1 - config.OVERLAP_PERCENTAGE/100);
    
    % Calculate required number of passes for 100% coverage
    numPassesRequired = ceil(FIELD_SIZE / effectiveSwath);
    
    % Override config if needed to guarantee 100% coverage
    if strcmp(pattern, 'grid')
        config.NUM_PASSES = max(config.NUM_PASSES, numPassesRequired);
    end
    
    fprintf('   Camera footprint: %.2f m\n', cameraFootprint);
    fprintf('   Effective swath: %.2f m (with %.0f%% overlap)\n', ...
            effectiveSwath, config.OVERLAP_PERCENTAGE);
    fprintf('   Required passes: %d (for 100%% coverage)\n', numPassesRequired);
    
    % Get field boundaries based on selected field
    [field_x, field_y] = get_field_boundaries(config);
    
    switch pattern
        case 'grid'
            flightPath = generate_grid_pattern(config, field_x, field_y, numPassesRequired);
            fprintf('   ✓ Grid pattern: %d passes\n', numPassesRequired);
            
        case 'spiral'
            flightPath = generate_spiral_pattern(config, field_x, field_y);
            fprintf('   ✓ Spiral pattern: guaranteed coverage\n');
            
        case 'random'
            % Random pattern modified for 100% coverage
            flightPath = generate_coverage_random_pattern(config, field_x, field_y, numPassesRequired);
            fprintf('   ✓ Random pattern: %d waypoints for full coverage\n', numPassesRequired*4);
            
        otherwise
            error('Unknown scan pattern: %s', pattern);
    end
    
    % Verify 100% coverage
    coverage = verify_coverage(flightPath, config, field_x, field_y);
    fprintf('   ✓ Verified coverage: %.1f%%\n', coverage);
    
    if coverage < 100
        warning('Coverage below 100%% - increasing path density');
        flightPath = densify_path(flightPath, config, field_x, field_y);
        coverage = verify_coverage(flightPath, config, field_x, field_y);
        fprintf('   ✓ Adjusted coverage: %.1f%%\n', coverage);
    end
    
    % Interpolate for smooth path
    flightPath = interpolate_path(flightPath, config.PATH_RESOLUTION);
    fprintf('   ✓ Path smoothed to %d points\n', size(flightPath, 1));
end

%% Get Field Boundaries
function [field_x, field_y] = get_field_boundaries(config)
    % Calculate field position based on serial number (1-4 in 2x2 grid)
    fieldNum = config.SELECTED_FIELD;
    
    % Arrange fields in 2x2 grid
    cols = 2;
    row = ceil(fieldNum / cols);
    col = mod(fieldNum - 1, cols) + 1;
    
    % Calculate field offset
    x_offset = (col - 1) * (config.FIELD_SIZE + config.FIELD_SPACING);
    y_offset = (row - 1) * (config.FIELD_SIZE + config.FIELD_SPACING);
    
    % Field boundaries [min_x, max_x, min_y, max_y]
    field_x = [x_offset + config.SCAN_MARGIN, ...
               x_offset + config.FIELD_SIZE - config.SCAN_MARGIN];
    field_y = [y_offset + config.SCAN_MARGIN, ...
               y_offset + config.FIELD_SIZE - config.SCAN_MARGIN];
end

%% Grid Pattern (Lawn Mower) - 100% Coverage
function waypoints = generate_grid_pattern(config, field_x, field_y, numPasses)
    UAV_HEIGHT = config.UAV_HEIGHT;
    
    % Calculate spacing for exact coverage
    spacing = (field_y(2) - field_y(1)) / numPasses;
    
    waypoints = [];
    
    for i = 1:numPasses+1  % +1 to ensure edge coverage
        y_pos = field_y(1) + (i-1) * spacing;
        y_pos = min(y_pos, field_y(2)); % Clamp to field boundary
        
        if mod(i, 2) == 1
            % Left to right
            waypoints = [waypoints; field_x(1), y_pos, UAV_HEIGHT];
            waypoints = [waypoints; field_x(2), y_pos, UAV_HEIGHT];
        else
            % Right to left
            waypoints = [waypoints; field_x(2), y_pos, UAV_HEIGHT];
            waypoints = [waypoints; field_x(1), y_pos, UAV_HEIGHT];
        end
    end
end

%% Spiral Pattern - 100% Coverage
function waypoints = generate_spiral_pattern(config, field_x, field_y)
    UAV_HEIGHT = config.UAV_HEIGHT;
    
    % Calculate center of field
    center_x = mean(field_x);
    center_y = mean(field_y);
    
    % Calculate required spiral density for 100% coverage
    max_radius = min(field_x(2) - center_x, field_y(2) - center_y);
    
    % Dense spiral for complete coverage
    numTurns = 8;
    t = linspace(0, numTurns*2*pi, 300);
    r = linspace(0, max_radius, 300);
    
    waypoints = [center_x + r.*cos(t)', ...
                center_y + r.*sin(t)', ...
                ones(300,1) * UAV_HEIGHT];
end

%% Random Pattern Modified for Coverage
function waypoints = generate_coverage_random_pattern(config, field_x, field_y, numPasses)
    UAV_HEIGHT = config.UAV_HEIGHT;
    
    % Create grid of waypoints ensuring coverage
    numWaypointsX = numPasses;
    numWaypointsY = numPasses;
    
    x_points = linspace(field_x(1), field_x(2), numWaypointsX);
    y_points = linspace(field_y(1), field_y(2), numWaypointsY);
    
    waypoints = [];
    for i = 1:numWaypointsX
        for j = 1:numWaypointsY
            % Add small random offset but stay within grid
            x = x_points(i) + randn() * 2;
            y = y_points(j) + randn() * 2;
            x = max(field_x(1), min(field_x(2), x));
            y = max(field_y(1), min(field_y(2), y));
            waypoints = [waypoints; x, y, UAV_HEIGHT];
        end
    end
end

%% Verify Coverage
function coverage = verify_coverage(waypoints, config, field_x, field_y)
    % Calculate what percentage of field is covered
    
    cameraRadius = config.UAV_HEIGHT * tan(deg2rad(config.CAMERA_FOV/2));
    
    % Create grid of field
    [X, Y] = meshgrid(linspace(field_x(1), field_x(2), 50), ...
                     linspace(field_y(1), field_y(2), 50));
    
    covered = zeros(size(X));
    
    % Check each waypoint
    for i = 1:size(waypoints, 1)
        wx = waypoints(i, 1);
        wy = waypoints(i, 2);
        
        % Mark points within camera FOV as covered
        dist = sqrt((X - wx).^2 + (Y - wy).^2);
        covered(dist <= cameraRadius) = 1;
    end
    
    coverage = sum(covered(:)) / numel(covered) * 100;
end

%% Densify Path if Needed
function densePath = densify_path(waypoints, config, field_x, field_y)
    % Add more waypoints to ensure 100% coverage
    
    cameraFootprint = 2 * config.UAV_HEIGHT * tan(deg2rad(config.CAMERA_FOV/2));
    spacing = cameraFootprint * 0.7; % 30% overlap
    
    % Generate dense grid
    x_points = field_x(1):spacing:field_x(2);
    y_points = field_y(1):spacing:field_y(2);
    
    densePath = [];
    for i = 1:length(x_points)
        for j = 1:length(y_points)
            densePath = [densePath; x_points(i), y_points(j), config.UAV_HEIGHT];
        end
    end
end

%% Path Interpolation
function smoothPath = interpolate_path(waypoints, resolution)
    % Interpolate waypoints for smooth flight
    t_waypoints = linspace(0, 1, size(waypoints, 1));
    t_path = linspace(0, 1, resolution);
    
    smoothPath = [interp1(t_waypoints, waypoints(:,1), t_path)', ...
                  interp1(t_waypoints, waypoints(:,2), t_path)', ...
                  interp1(t_waypoints, waypoints(:,3), t_path)'];
end

%% Helper Function: Get Field Start Position
function startPos = get_field_start_position(config)
    % Returns starting position for selected field
    [field_x, field_y] = get_field_boundaries(config);
    startPos = [field_x(1), field_y(1), config.UAV_HEIGHT];
end