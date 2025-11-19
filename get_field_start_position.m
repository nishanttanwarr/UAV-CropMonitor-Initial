%% ========================================================================
%  FILE 10: get_field_start_position.m
%  Helper function to get starting position for selected field
%% ========================================================================

function startPos = get_field_start_position(config)
    % Returns starting position for the selected field
    % Based on field serial number (1-4 in 2x2 grid)
    
    fieldNum = config.SELECTED_FIELD;
    FIELD_SIZE = config.FIELD_SIZE;
    FIELD_SPACING = config.FIELD_SPACING;
    
    % Arrange fields in 2x2 grid
    cols = 2;
    row = ceil(fieldNum / cols);
    col = mod(fieldNum - 1, cols) + 1;
    
    % Calculate field offset based on position in grid
    x_offset = (col - 1) * (FIELD_SIZE + FIELD_SPACING);
    y_offset = (row - 1) * (FIELD_SIZE + FIELD_SPACING);
    
    % Starting position at the corner of selected field
    startPos = [x_offset + config.SCAN_MARGIN, ...
                y_offset + config.SCAN_MARGIN, ...
                config.UAV_HEIGHT];
    
    fprintf('   Field #%d location: [%.1f, %.1f] m\n', ...
            fieldNum, x_offset, y_offset);
end