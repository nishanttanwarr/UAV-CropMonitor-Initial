%% ========================================================================
%  FILE 2: load_config.m
%  Configuration file - Edit parameters here
%% ========================================================================

function config = load_config()
    % All simulation parameters in one place
    % Edit these values to customize your simulation
    
    %% FIELD PARAMETERS
    config.FIELD_SIZE = 100;        % Single field size in meters (100x100)
    config.GRID_RESOLUTION = 20;    % Number of grid points
    config.SELECTED_FIELD = 1;      % Field serial number (set by main script)
    config.TOTAL_FIELDS = 4;        % Total number of fields available (reduced to 4)
    config.FIELD_SPACING = 10;      % Spacing between fields in meters
    
    %% BASE STATION (Home/Resting Point)
    config.BASE_X = -20;            % Base station X coordinate (before fields)
    config.BASE_Y = 50;             % Base station Y coordinate (center)
    config.BASE_Z = 0;              % Base station on ground
    config.TAKEOFF_HEIGHT = 5;      % Initial takeoff height
    config.TRANSIT_HEIGHT = 20;     % Height during transit to field
    
    %% WEATHER & ENVIRONMENTAL CONDITIONS
    config.WIND_ENABLED = true;         % Enable wind simulation
    config.WIND_SPEED = 3;              % Wind speed in m/s (0-10)
    config.WIND_DIRECTION = 45;         % Wind direction in degrees (0-360)
    config.WIND_VARIABILITY = 0.5;      % Wind gust factor (0-1)
    
    config.TEMPERATURE = 28;            % Temperature in Celsius
    config.HUMIDITY = 65;               % Humidity percentage
    config.PRESSURE = 1013;             % Atmospheric pressure in hPa
    config.VISIBILITY = 10000;          % Visibility in meters
    
    config.WEATHER_TYPE = 'clear';      % 'clear', 'cloudy', 'windy', 'humid'
    
    %% AIR DENSITY & FLIGHT PHYSICS
    config.AIR_DENSITY = 1.225;         % kg/m³ (affects battery drain)
    config.ALTITUDE_MSL = 300;          % Mean sea level altitude (meters)
    config.TURBULENCE_FACTOR = 0.2;     % Air turbulence (0-1)
    
    %% COVERAGE PARAMETERS
    config.COVERAGE_REQUIREMENT = 100;  % Required coverage percentage (must be 100)
    config.OVERLAP_PERCENTAGE = 15;     % Camera overlap for 100% guarantee (%) - increased
    config.SCAN_MARGIN = 1;             % Safety margin from field edges (meters) - reduced
    
    %% UAV PARAMETERS
    config.UAV_HEIGHT = 15;         % Flying height in meters
    config.UAV_SPEED = 2;           % Speed in m/s during scanning
    config.TRANSIT_SPEED = 5;       % Speed during transit (faster)
    config.UAV_SIZE = 2;            % Visual size of UAV
    config.INITIAL_BATTERY = 100;   % Starting battery percentage
    config.BATTERY_DRAIN_RATE = 0.3; % Battery drain percentage per second (reduced for longer flight)
    config.WIND_BATTERY_IMPACT = 0.1; % Extra battery drain in wind (0.1% per m/s wind)
    
    %% FLIGHT PARAMETERS
    config.SCAN_PATTERN = 'grid';   % Options: 'grid', 'spiral', 'random'
    config.NUM_PASSES = 10;         % Number of passes for grid pattern (increased for 100%)
    config.PATH_RESOLUTION = 1500;  % Smoothness of flight path (increased)
    
    %% CAMERA/SENSOR PARAMETERS
    config.CAMERA_FOV = 60;         % Camera field of view in degrees
    config.SENSOR_UPDATE_RATE = 0.1; % How often sensors update (seconds)
    
    %% SIMULATION PARAMETERS
    config.SIMULATION_TIME = 180;   % Total simulation time in seconds (reference only, no limit enforced)
    config.UPDATE_RATE = 0.05;      % Graphics update rate (20 FPS)
    config.TRAIL_LENGTH = 100;      % Number of trail points to show
    
    %% CROP HEALTH PARAMETERS
    config.HEALTHY_THRESHOLD = 0.65;    % NDVI > 0.65 = Healthy
    config.MODERATE_THRESHOLD = 0.45;   % NDVI 0.45-0.65 = Moderate
    config.STRESSED_THRESHOLD = 0.25;   % NDVI 0.25-0.45 = Stressed
    % Below 0.25 = Unhealthy
    
    %% ALERT PARAMETERS
    config.LOW_BATTERY_WARNING = 20;    % Battery percentage for warning
    config.DISEASE_ALERT_THRESHOLD = 20; % Disease % for alert
    config.HEALTHY_FIELD_THRESHOLD = 70; % Healthy % for good status
    
    %% VISUALIZATION PARAMETERS
    config.AUTO_ROTATE = true;          % Auto-rotate 3D view
    config.ROTATION_SPEED = 0.5;        % Degrees per update
    config.SHOW_TRAIL = true;           % Show UAV trail
    config.SHOW_FOV = true;             % Show camera FOV cone
    
    %% FILE EXPORT PARAMETERS
    config.SAVE_RESULTS = true;         % Save results to file
    config.OUTPUT_FOLDER = 'results';   % Output folder name
    config.GENERATE_REPORT = true;      % Generate text report
    
    fprintf('📋 Configuration Summary:\n');
    fprintf('   Field: %dx%d m\n', config.FIELD_SIZE, config.FIELD_SIZE);
    fprintf('   UAV Height: %d m\n', config.UAV_HEIGHT);
    fprintf('   Speed: %d m/s\n', config.UAV_SPEED);
    fprintf('   Pattern: %s\n', config.SCAN_PATTERN);
    fprintf('   Duration: %d seconds\n', config.SIMULATION_TIME);
end