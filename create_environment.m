%% ========================================================================
%  FILE 3: create_environment.m
%  Creates the 3D visualization environment
%% ========================================================================

function [env, figures] = create_environment(config)
    % Creates all graphical elements for the simulation
    
    %% Create main figure
    figures.main = figure('Name', '3D UAV Real-Time Monitoring', ...
                         'Position', [50 50 1600 900], ...
                         'Color', [0.95 0.95 0.95]);
    
    %% Create 3D visualization (main panel)
    figures.ax3D = subplot(2,3,[1,2,4,5]);
    hold(figures.ax3D, 'on');
    grid(figures.ax3D, 'on');
    
    % Calculate view boundaries for all fields
    maxExtent = 2 * (config.FIELD_SIZE + config.FIELD_SPACING);
    
    axis(figures.ax3D, [-30 maxExtent -20 maxExtent 0 config.UAV_HEIGHT*2]);
    view(figures.ax3D, 45, 30);
    xlabel(figures.ax3D, 'X (meters)', 'FontWeight', 'bold');
    ylabel(figures.ax3D, 'Y (meters)', 'FontWeight', 'bold');
    zlabel(figures.ax3D, 'Height (meters)', 'FontWeight', 'bold');
    title(figures.ax3D, sprintf('3D UAV Flight Simulation - Field #%d Target', config.SELECTED_FIELD), ...
          'FontSize', 14, 'FontWeight', 'bold');
    
    %% Draw base station
    base_size = 15;
    [X_base, Y_base] = meshgrid(config.BASE_X:base_size/5:config.BASE_X+base_size, ...
                                config.BASE_Y-base_size/2:base_size/5:config.BASE_Y+base_size/2);
    Z_base = zeros(size(X_base));
    
    surf(figures.ax3D, X_base, Y_base, Z_base, ones(size(Z_base))*0.5, ...
         'EdgeColor', 'none', 'FaceAlpha', 0.9, 'FaceColor', [0.5 0.5 0.5]);
    
    text(figures.ax3D, config.BASE_X+base_size/2, config.BASE_Y, 3, ...
         'BASE STATION', 'FontSize', 10, 'FontWeight', 'bold', ...
         'Color', 'white', 'HorizontalAlignment', 'center', ...
         'BackgroundColor', [0.3 0.3 0.3 0.8]);
    
    % Helipad marker
    theta_pad = linspace(0, 2*pi, 50);
    pad_radius = 5;
    plot3(figures.ax3D, config.BASE_X+base_size/2 + pad_radius*cos(theta_pad), ...
          config.BASE_Y + pad_radius*sin(theta_pad), ...
          zeros(size(theta_pad))+0.1, 'y-', 'LineWidth', 3);
    plot3(figures.ax3D, [config.BASE_X+base_size/2-pad_radius, config.BASE_X+base_size/2+pad_radius], ...
          [config.BASE_Y, config.BASE_Y], [0.1, 0.1], 'y-', 'LineWidth', 3);
    plot3(figures.ax3D, [config.BASE_X+base_size/2, config.BASE_X+base_size/2], ...
          [config.BASE_Y-pad_radius, config.BASE_Y+pad_radius], [0.1, 0.1], 'y-', 'LineWidth', 3);
    
    %% Draw ground plane (brown dirt)
    ground_x_min = -10;
    ground_x_max = maxExtent + 10;
    ground_y_min = -10;
    ground_y_max = maxExtent + 10;
    
    [X_ground_plane, Y_ground_plane] = meshgrid(ground_x_min:20:ground_x_max, ...
                                                  ground_y_min:20:ground_y_max);
    Z_ground_plane = zeros(size(X_ground_plane)) - 0.5;
    
    surf(figures.ax3D, X_ground_plane, Y_ground_plane, Z_ground_plane, ...
         ones(size(Z_ground_plane))*0.3, ...
         'EdgeColor', 'none', 'FaceAlpha', 0.5, 'FaceColor', [0.4 0.3 0.2]);
    
    %% Draw 4 fields
    cols = 2;
    
    for fieldIdx = 1:config.TOTAL_FIELDS
        row = ceil(fieldIdx / cols);
        col = mod(fieldIdx - 1, cols) + 1;
        
        x_start = (col - 1) * (config.FIELD_SIZE + config.FIELD_SPACING);
        y_start = (row - 1) * (config.FIELD_SIZE + config.FIELD_SPACING);
        
        [X_field, Y_field] = meshgrid(x_start:config.FIELD_SIZE/config.GRID_RESOLUTION:x_start+config.FIELD_SIZE, ...
                                      y_start:config.FIELD_SIZE/config.GRID_RESOLUTION:y_start+config.FIELD_SIZE);
        Z_field = 0.5 * sin(X_field/10) .* cos(Y_field/10);
        
        fieldHealth = peaks(size(X_field,1));
        fieldHealth = (fieldHealth - min(fieldHealth(:))) / (max(fieldHealth(:)) - min(fieldHealth(:)));
        
        if fieldIdx == config.SELECTED_FIELD
            env.cropHealth = fieldHealth;
            env.X_ground = X_field;
            env.Y_ground = Y_field;
            env.Z_ground = Z_field;
            
            surf(figures.ax3D, X_field, Y_field, Z_field, fieldHealth, ...
                 'EdgeColor', 'none', 'FaceAlpha', 1.0);
            
            plot3(figures.ax3D, ...
                  [x_start x_start+config.FIELD_SIZE x_start+config.FIELD_SIZE x_start x_start], ...
                  [y_start y_start y_start+config.FIELD_SIZE y_start+config.FIELD_SIZE y_start], ...
                  [2 2 2 2 2], 'g-', 'LineWidth', 5);
            
            text(figures.ax3D, x_start+config.FIELD_SIZE/2, y_start+config.FIELD_SIZE/2, 8, ...
                 sprintf('FIELD #%d\n(TARGET)', fieldIdx), ...
                 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0 1 0], ...
                 'HorizontalAlignment', 'center', 'BackgroundColor', [0 0 0 0.7], ...
                 'EdgeColor', 'green', 'LineWidth', 2);
        else
            surf(figures.ax3D, X_field, Y_field, Z_field, fieldHealth, ...
                 'EdgeColor', 'none', 'FaceAlpha', 0.6);
            
            plot3(figures.ax3D, ...
                  [x_start x_start+config.FIELD_SIZE x_start+config.FIELD_SIZE x_start x_start], ...
                  [y_start y_start y_start+config.FIELD_SIZE y_start+config.FIELD_SIZE y_start], ...
                  [0.5 0.5 0.5 0.5 0.5], 'w-', 'LineWidth', 2);
            
            text(figures.ax3D, x_start+config.FIELD_SIZE/2, y_start+config.FIELD_SIZE/2, 3, ...
                 sprintf('#%d', fieldIdx), ...
                 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'white', ...
                 'HorizontalAlignment', 'center', 'BackgroundColor', [0 0 0 0.5]);
        end
    end
    
    colormap(figures.ax3D, jet);
    
    %% Create UAV visual elements
    uavSize = config.UAV_SIZE;
    uavX = [0 uavSize 0 -uavSize 0];
    uavY = [0 0 uavSize 0 -uavSize];
    uavZ = [0 0 0 0 0];
    
    initialPos = [config.BASE_X, config.BASE_Y, config.BASE_Z];
    
    env.uavPlot = plot3(figures.ax3D, initialPos(1)+uavX, initialPos(2)+uavY, ...
                        initialPos(3)+uavZ, 'r-', 'LineWidth', 3, ...
                        'Marker', 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'red');
    
    env.uavBody = plot3(figures.ax3D, initialPos(1), initialPos(2), initialPos(3), ...
                        'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'yellow', ...
                        'MarkerEdgeColor', 'red', 'LineWidth', 2);
    
    if config.SHOW_FOV
        cameraRadius = config.UAV_HEIGHT * tan(deg2rad(config.CAMERA_FOV/2));
        theta = linspace(0, 2*pi, 20);
        
        conePts_x = [initialPos(1)*ones(1,20), initialPos(1) + cameraRadius*cos(theta)];
        conePts_y = [initialPos(2)*ones(1,20), initialPos(2) + cameraRadius*sin(theta)];
        conePts_z = [initialPos(3)*ones(1,20), zeros(1,20)];
        
        env.cameraFOV = plot3(figures.ax3D, conePts_x, conePts_y, conePts_z, ...
                              'b-', 'LineWidth', 1, 'Color', [0.3 0.6 1 0.3]);
        env.cameraRadius = cameraRadius;
        env.cameraTheta = theta;
    end
    
    if config.SHOW_TRAIL
        env.trailPlot = plot3(figures.ax3D, initialPos(1), initialPos(2), initialPos(3), ...
                              'g-', 'LineWidth', 1.5);
        env.trailData = initialPos;
    end
    
    env.uavX = uavX;
    env.uavY = uavY;
    env.uavZ = uavZ;
    
    %% Create top-down view
    figures.axTop = subplot(2,3,3);
    hold(figures.axTop, 'on');
    
    for fieldIdx = 1:config.TOTAL_FIELDS
        row = ceil(fieldIdx / 2);
        col = mod(fieldIdx - 1, 2) + 1;
        
        x_start = (col - 1) * (config.FIELD_SIZE + config.FIELD_SPACING);
        y_start = (row - 1) * (config.FIELD_SIZE + config.FIELD_SPACING);
        
        if fieldIdx == config.SELECTED_FIELD
            imagesc(figures.axTop, [x_start x_start+config.FIELD_SIZE], ...
                    [y_start y_start+config.FIELD_SIZE], env.cropHealth);
            
            rectangle(figures.axTop, 'Position', [x_start, y_start, config.FIELD_SIZE, config.FIELD_SIZE], ...
                     'EdgeColor', 'g', 'LineWidth', 4);
            
            text(figures.axTop, x_start+config.FIELD_SIZE/2, y_start+config.FIELD_SIZE/2, ...
                 sprintf('#%d\nTARGET', fieldIdx), 'Color', 'g', 'FontWeight', 'bold', ...
                 'HorizontalAlignment', 'center', 'FontSize', 10);
        else
            rectangle(figures.axTop, 'Position', [x_start, y_start, config.FIELD_SIZE, config.FIELD_SIZE], ...
                     'FaceColor', [0.7 0.7 0.7 0.3], 'EdgeColor', 'w', 'LineWidth', 2);
            
            text(figures.axTop, x_start+config.FIELD_SIZE/2, y_start+config.FIELD_SIZE/2, ...
                 sprintf('#%d', fieldIdx), 'Color', 'w', 'FontWeight', 'bold', ...
                 'HorizontalAlignment', 'center', 'FontSize', 9);
        end
    end
    
    colormap(figures.axTop, jet);
    axis(figures.axTop, 'equal', 'tight');
    xlim(figures.axTop, [-20, maxExtent]);
    ylim(figures.axTop, [-10, maxExtent]);
    title(figures.axTop, sprintf('Top-Down: Field #%d Coverage', config.SELECTED_FIELD), ...
          'FontSize', 11, 'FontWeight', 'bold');
    xlabel(figures.axTop, 'X (m)');
    ylabel(figures.axTop, 'Y (m)');
    
    rectangle(figures.axTop, 'Position', [config.BASE_X, config.BASE_Y-7.5, 15, 15], ...
             'FaceColor', [0.5 0.5 0.5], 'EdgeColor', 'k', 'LineWidth', 2);
    text(figures.axTop, config.BASE_X+7.5, config.BASE_Y, 'BASE', ...
         'Color', 'y', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    
    env.uavDot = plot(figures.axTop, initialPos(1), initialPos(2), ...
                      'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'red', 'LineWidth', 2);
    env.trailTop = plot(figures.axTop, initialPos(1), initialPos(2), ...
                        'g-', 'LineWidth', 1);
    
    %% Create data display panel
    figures.axData = subplot(2,3,6);
    axis(figures.axData, 'off');
    env.dataText = text(0.05, 0.95, '', 'FontSize', 10, 'FontName', 'Courier', ...
                        'VerticalAlignment', 'top', 'Parent', figures.axData);
    
    fprintf('   ✓ 3D environment created\n');
    fprintf('   ✓ Ground terrain generated\n');
    fprintf('   ✓ UAV model initialized\n');
    fprintf('   ✓ Data displays ready\n');
end