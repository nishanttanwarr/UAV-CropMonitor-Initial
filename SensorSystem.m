%% ========================================================================
%  FILE 6: SensorSystem.m (ENHANCED & FIXED)
%  Advanced crop health monitoring with multiple parameters
%% ========================================================================

classdef SensorSystem < handle
    properties
        config          % Configuration reference
        
        % Vegetation Indices
        ndvi            % Normalized Difference Vegetation Index
        gndvi           % Green NDVI
        
        % Advanced Health Parameters
        lai             % Leaf Area Index
        greenness       % Greenness index (0-100)
        biomass         % Estimated biomass (kg/m²)
        
        % Stress Detection
        waterStress     % Water stress level (0-100%)
        pestAttack      % Pest infestation level (0-100%)
        nutrientDeficiency % Nutrient deficiency (0-100%)
        thermalStress   % Heat stress from temperature
        
        % Disease & Problem Areas
        diseasePresence % Disease detection (0-100%)
        diseaseType     % Type of disease detected
        diseaseAreas    % Number of diseased zones
        
        % Gap & Uniformity Detection
        gapCount        % Number of gaps detected
        gapArea         % Total gap area (m²)
        fieldUniformity % Field uniformity score (0-100%)
        cropStandQuality % Overall stand quality (0-100%)
        
        % Growth Stage
        growthStage     % Current growth stage
        canopyDensity   % Canopy coverage (%)
        plantHeight     % Estimated plant height (cm)
        
        % General Health
        healthyCrop     % Percentage of healthy crop
        stressedCrop    % Percentage of stressed crop
        diseaseDetected % Percentage of disease detected
        
        % Coverage
        scannedArea     % Total area scanned (m²)
        cropHealthMap   % Reference to crop health map
    end
    
    methods
        function obj = SensorSystem(config)
            % Constructor
            obj.config = config;
            obj.ndvi = 0;
            obj.lai = 0;
            obj.greenness = 0;
            obj.biomass = 0;
            obj.waterStress = 0;
            obj.pestAttack = 0;
            obj.nutrientDeficiency = 0;
            obj.thermalStress = 0;
            obj.diseasePresence = 0;
            obj.diseaseType = 'None';
            obj.diseaseAreas = 0;
            obj.gapCount = 0;
            obj.gapArea = 0;
            obj.fieldUniformity = 100;
            obj.cropStandQuality = 100;
            obj.growthStage = 'Vegetative';
            obj.canopyDensity = 0;
            obj.plantHeight = 0;
            obj.healthyCrop = 0;
            obj.stressedCrop = 0;
            obj.diseaseDetected = 0;
            obj.scannedArea = 0;
        end
        
        function setCropHealthMap(obj, healthMap)
            % Set reference to crop health map
            obj.cropHealthMap = healthMap;
        end
        
        function scan(obj, position, pathProgress)
            % Perform comprehensive sensor reading at current position
            
            % Check if position is within field boundaries
            if obj.isInsideField(position)
                % Get local crop health from map
                localHealth = obj.getLocalHealth(position);
                
                % 1. CALCULATE NDVI (Primary indicator)
                obj.ndvi = 0.3 + localHealth * 0.6 + randn()*0.02;
                obj.ndvi = max(0, min(1, obj.ndvi));
                
                % 2. CALCULATE LAI (Leaf Area Index)
                % LAI typically ranges from 0 to 8 for crops
                % Higher NDVI correlates with higher LAI
                obj.lai = obj.ndvi * 6 + randn()*0.3; % 0-6 range
                obj.lai = max(0, min(8, obj.lai));
                
                % 3. GREENNESS INDEX (0-100)
                obj.greenness = obj.ndvi * 100;
                obj.greenness = max(0, min(100, obj.greenness));
                
                % 4. BIOMASS ESTIMATION (kg/m²)
                % Biomass correlates with LAI, plant height, and NDVI
                % Typical range: 0-5 kg/m² for crops
                obj.biomass = obj.lai * 0.4 + (obj.plantHeight/100) * 0.3 + obj.ndvi * 0.5;
                obj.biomass = max(0, min(6, obj.biomass));
                
                % 5. WATER STRESS DETECTION
                % Combine thermal data and NDVI
                tempFactor = (obj.config.TEMPERATURE - 22) / 15; % Normalized
                obj.waterStress = (1 - obj.ndvi) * 50 + tempFactor * 30 + randn()*5;
                obj.waterStress = max(0, min(100, obj.waterStress));
                
                % 6. PEST ATTACK DETECTION
                % Random variations in health might indicate pests
                if localHealth < 0.5 && rand() > 0.7
                    obj.pestAttack = 20 + rand()*30;
                else
                    obj.pestAttack = rand()*15;
                end
                obj.pestAttack = max(0, min(100, obj.pestAttack));
                
                % 7. NUTRIENT DEFICIENCY DETECTION (FIXED - Was missing!)
                % Based on NDVI, LAI, and local health
                % Low NDVI + Low LAI = Likely nutrient deficiency
                ndviScore = (1 - obj.ndvi) * 40; % Low NDVI indicates deficiency
                laiScore = (4 - obj.lai) / 4 * 30; % LAI below 4 indicates issues
                healthScore = (1 - localHealth) * 20; % Poor health correlates
                
                obj.nutrientDeficiency = ndviScore + laiScore + healthScore + randn()*5;
                obj.nutrientDeficiency = max(0, min(100, obj.nutrientDeficiency));
                
                % 8. THERMAL STRESS (FIXED - Better logic)
                % Optimal temperature range: 20-30°C for most crops
                % Calculate stress based on deviation from optimal
                optimalTemp = 25; % Optimal temperature
                tempDeviation = abs(obj.config.TEMPERATURE - optimalTemp);
                
                if obj.config.TEMPERATURE > 35
                    % Extreme heat stress
                    obj.thermalStress = 50 + (obj.config.TEMPERATURE - 35) * 5;
                elseif obj.config.TEMPERATURE > 30
                    % Moderate heat stress
                    obj.thermalStress = 20 + (obj.config.TEMPERATURE - 30) * 6;
                elseif obj.config.TEMPERATURE < 10
                    % Extreme cold stress
                    obj.thermalStress = 50 + (10 - obj.config.TEMPERATURE) * 5;
                elseif obj.config.TEMPERATURE < 15
                    % Moderate cold stress
                    obj.thermalStress = 15 + (15 - obj.config.TEMPERATURE) * 5;
                else
                    % Mild stress based on deviation from optimal (20-30°C range)
                    obj.thermalStress = tempDeviation * 2 + randn()*3;
                end
                
                % Add humidity effect on thermal stress
                if obj.config.HUMIDITY > 80
                    obj.thermalStress = obj.thermalStress + (obj.config.HUMIDITY - 80) * 0.5;
                end
                
                obj.thermalStress = max(0, min(100, obj.thermalStress));
                
                % 9. DISEASE DETECTION (Enhanced)
                % Combine multiple factors for disease presence
                obj.diseasePresence = (1 - localHealth) * 30 + ...
                                      obj.waterStress * 0.2 + ...
                                      obj.pestAttack * 0.3 + ...
                                      randn()*5;
                obj.diseasePresence = max(0, min(100, obj.diseasePresence));
                
                % Classify disease type based on symptoms
                if obj.diseasePresence > 60
                    diseaseTypes = {'Fungal Blight', 'Bacterial Wilt', 'Root Rot', 'Leaf Spot'};
                    obj.diseaseType = diseaseTypes{randi(length(diseaseTypes))};
                    obj.diseaseAreas = ceil(obj.diseasePresence / 10);
                elseif obj.diseasePresence > 40
                    diseaseTypes = {'Early Blight', 'Powdery Mildew', 'Rust'};
                    obj.diseaseType = diseaseTypes{randi(length(diseaseTypes))};
                    obj.diseaseAreas = ceil(obj.diseasePresence / 15);
                elseif obj.diseasePresence > 20
                    obj.diseaseType = 'Minor Infection';
                    obj.diseaseAreas = 1;
                else
                    obj.diseaseType = 'None';
                    obj.diseaseAreas = 0;
                end
                
                % 10. GAP DETECTION (Enhanced)
                % Areas with very low NDVI indicate gaps
                if obj.ndvi < 0.2
                    obj.gapCount = obj.gapCount + 1;
                    obj.gapArea = obj.gapArea + 4; % Assume 4 m² per gap
                end
                
                % Update field uniformity based on variation
                obj.fieldUniformity = 100 - (std([obj.ndvi, localHealth]) * 50);
                obj.fieldUniformity = max(0, min(100, obj.fieldUniformity));
                
                % Crop stand quality combines multiple factors
                obj.cropStandQuality = (obj.ndvi * 40) + ...
                                       (obj.fieldUniformity * 0.3) + ...
                                       (obj.lai / 8 * 30) - ...
                                       (obj.gapCount * 2);
                obj.cropStandQuality = max(0, min(100, obj.cropStandQuality));
                
                % 11. DETERMINE GROWTH STAGE based on NDVI and LAI
                if obj.ndvi < 0.3 || obj.lai < 1
                    obj.growthStage = 'Emergence';
                elseif obj.ndvi < 0.5 || obj.lai < 2.5
                    obj.growthStage = 'Vegetative';
                elseif obj.ndvi < 0.7 || obj.lai < 4
                    obj.growthStage = 'Flowering';
                elseif obj.ndvi < 0.85
                    obj.growthStage = 'Fruiting';
                else
                    obj.growthStage = 'Maturity';
                end
                
                % 12. CANOPY DENSITY (%)
                obj.canopyDensity = obj.lai * 15; % Rough approximation
                obj.canopyDensity = max(0, min(100, obj.canopyDensity));
                
                % 13. ESTIMATED PLANT HEIGHT (cm)
                % Based on LAI and growth stage
                if strcmp(obj.growthStage, 'Emergence')
                    obj.plantHeight = 5 + obj.lai * 5;
                elseif strcmp(obj.growthStage, 'Vegetative')
                    obj.plantHeight = 20 + obj.lai * 15;
                elseif strcmp(obj.growthStage, 'Flowering')
                    obj.plantHeight = 60 + obj.lai * 20;
                elseif strcmp(obj.growthStage, 'Fruiting')
                    obj.plantHeight = 80 + obj.lai * 15;
                else
                    obj.plantHeight = 100 + obj.lai * 10;
                end
                obj.plantHeight = max(0, min(250, obj.plantHeight));
                
                % 14. OVERALL HEALTH CLASSIFICATION
                obj.healthyCrop = 40 + localHealth * 40 + randn()*5;
                obj.stressedCrop = 30 - localHealth * 10 + randn()*5;
                obj.diseaseDetected = 10 + (1-localHealth) * 15 + randn()*3;
                
                % Add stress factors to disease/stress percentages
                obj.stressedCrop = obj.stressedCrop + obj.waterStress * 0.2;
                obj.diseaseDetected = obj.diseaseDetected + obj.pestAttack * 0.3;
                
                % Ensure valid percentages
                obj.healthyCrop = max(0, min(100, obj.healthyCrop));
                obj.stressedCrop = max(0, min(100, obj.stressedCrop));
                obj.diseaseDetected = max(0, min(30, obj.diseaseDetected));
                
                % Update scanned area (only actual field coverage)
                totalArea = obj.config.FIELD_SIZE * obj.config.FIELD_SIZE;
                obj.scannedArea = pathProgress * totalArea / 100;
            end
        end
        
        function inside = isInsideField(obj, position)
            % Check if position is inside the actual field boundaries
            [field_x, field_y] = obj.getFieldBoundaries();
            
            inside = (position(1) >= field_x(1) && position(1) <= field_x(2) && ...
                     position(2) >= field_y(1) && position(2) <= field_y(2));
        end
        
        function [field_x, field_y] = getFieldBoundaries(obj)
            % Get boundaries of selected field
            fieldNum = obj.config.SELECTED_FIELD;
            FIELD_SIZE = obj.config.FIELD_SIZE;
            FIELD_SPACING = obj.config.FIELD_SPACING;
            
            cols = 2;
            row = ceil(fieldNum / cols);
            col = mod(fieldNum - 1, cols) + 1;
            
            x_offset = (col - 1) * (FIELD_SIZE + FIELD_SPACING);
            y_offset = (row - 1) * (FIELD_SIZE + FIELD_SPACING);
            
            field_x = [x_offset, x_offset + FIELD_SIZE];
            field_y = [y_offset, y_offset + FIELD_SIZE];
        end
        
        function localHealth = getLocalHealth(obj, position)
            % Get crop health at specific position
            if isempty(obj.cropHealthMap)
                localHealth = 0.5;
                return;
            end
            
            [field_x, field_y] = obj.getFieldBoundaries();
            
            % Normalize position within field
            norm_x = (position(1) - field_x(1)) / (field_x(2) - field_x(1));
            norm_y = (position(2) - field_y(1)) / (field_y(2) - field_y(1));
            
            % Convert to map indices
            x_idx = max(1, min(size(obj.cropHealthMap,2), round(norm_x * size(obj.cropHealthMap,2))));
            y_idx = max(1, min(size(obj.cropHealthMap,1), round(norm_y * size(obj.cropHealthMap,1))));
            
            localHealth = obj.cropHealthMap(y_idx, x_idx);
        end
        
        %% Getter Methods
        function ndviVal = getNDVI(obj)
            ndviVal = obj.ndvi;
        end
        
        function laiVal = getLAI(obj)
            laiVal = obj.lai;
        end
        
        function bioVal = getBiomass(obj)
            bioVal = obj.biomass;
        end
        
        function grnVal = getGreenness(obj)
            grnVal = obj.greenness;
        end
        
        function wsVal = getWaterStress(obj)
            wsVal = obj.waterStress;
        end
        
        function paVal = getPestAttack(obj)
            paVal = obj.pestAttack;
        end
        
        function ndVal = getNutrientDeficiency(obj)
            ndVal = obj.nutrientDeficiency;
        end
        
        function tsVal = getThermalStress(obj)
            tsVal = obj.thermalStress;
        end
        
        function dpVal = getDiseasePresence(obj)
            dpVal = obj.diseasePresence;
        end
        
        function dtVal = getDiseaseType(obj)
            dtVal = obj.diseaseType;
        end
        
        function daVal = getDiseaseAreas(obj)
            daVal = obj.diseaseAreas;
        end
        
        function gcVal = getGapCount(obj)
            gcVal = obj.gapCount;
        end
        
        function gaVal = getGapArea(obj)
            gaVal = obj.gapArea;
        end
        
        function fuVal = getFieldUniformity(obj)
            fuVal = obj.fieldUniformity;
        end
        
        function csqVal = getCropStandQuality(obj)
            csqVal = obj.cropStandQuality;
        end
        
        function stage = getGrowthStage(obj)
            stage = obj.growthStage;
        end
        
        function density = getCanopyDensity(obj)
            density = obj.canopyDensity;
        end
        
        function height = getPlantHeight(obj)
            height = obj.plantHeight;
        end
        
        function pct = getHealthyPercentage(obj)
            pct = obj.healthyCrop;
        end
        
        function pct = getStressedPercentage(obj)
            pct = obj.stressedCrop;
        end
        
        function pct = getDiseasePercentage(obj)
            pct = obj.diseaseDetected;
        end
        
        function area = getScannedArea(obj)
            area = obj.scannedArea;
        end
        
        function status = getHealthStatus(obj)
            % Get overall health status with stress factors
            if obj.pestAttack > 40
                status = 'PEST ALERT';
            elseif obj.waterStress > 60
                status = 'WATER STRESS';
            elseif obj.nutrientDeficiency > 50
                status = 'NUTRIENT DEF';
            elseif obj.diseaseDetected > obj.config.DISEASE_ALERT_THRESHOLD
                status = 'DISEASE ALERT';
            elseif obj.healthyCrop > obj.config.HEALTHY_FIELD_THRESHOLD
                status = 'HEALTHY FIELD';
            else
                status = 'MONITORING...';
            end
        end
        
        function classification = classifyHealth(obj)
            % Classify health based on NDVI
            if obj.ndvi >= obj.config.HEALTHY_THRESHOLD
                classification = 'Healthy';
            elseif obj.ndvi >= obj.config.MODERATE_THRESHOLD
                classification = 'Moderate';
            elseif obj.ndvi >= obj.config.STRESSED_THRESHOLD
                classification = 'Stressed';
            else
                classification = 'Unhealthy';
            end
        end
        
        function summary = getComprehensiveSummary(obj)
            % Get complete summary of all parameters
            summary = sprintf([...
                '═══ COMPREHENSIVE CROP ANALYSIS ═══\n' ...
                'VEGETATION INDICES:\n' ...
                '  NDVI: %.3f (%s)\n' ...
                '  LAI: %.2f\n' ...
                '  Greenness: %.1f%%\n\n' ...
                'STRESS INDICATORS:\n' ...
                '  Water Stress: %.1f%%\n' ...
                '  Pest Attack: %.1f%%\n' ...
                '  Nutrient Deficiency: %.1f%%\n' ...
                '  Thermal Stress: %.1f%%\n\n' ...
                'GROWTH PARAMETERS:\n' ...
                '  Growth Stage: %s\n' ...
                '  Canopy Density: %.1f%%\n' ...
                '  Plant Height: %.0f cm\n\n' ...
                'OVERALL HEALTH:\n' ...
                '  Healthy: %.1f%%\n' ...
                '  Stressed: %.1f%%\n' ...
                '  Disease: %.1f%%\n'], ...
                obj.ndvi, obj.classifyHealth(), obj.lai, obj.greenness, ...
                obj.waterStress, obj.pestAttack, obj.nutrientDeficiency, obj.thermalStress, ...
                obj.growthStage, obj.canopyDensity, obj.plantHeight, ...
                obj.healthyCrop, obj.stressedCrop, obj.diseaseDetected);
        end
    end
end