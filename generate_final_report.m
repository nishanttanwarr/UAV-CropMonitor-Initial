%% ========================================================================
%  FILE 9: generate_final_report.m
%  Generates final mission report
%% ========================================================================

function generate_final_report(config, uav, sensors, timeElapsed, finalCoverage)
    % Generates comprehensive mission report
    
    if ~config.GENERATE_REPORT
        return;
    end
    
    % Create output folder if needed
    if ~exist(config.OUTPUT_FOLDER, 'dir')
        mkdir(config.OUTPUT_FOLDER);
    end
    
    %% Generate text report
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    filename = fullfile(config.OUTPUT_FOLDER, sprintf('mission_report_%s.txt', timestamp));
    
    fid = fopen(filename, 'w');
    
    fprintf(fid, '══════════════════════════════════════════════════════════\n');
    fprintf(fid, '          UAV CROP MONITORING MISSION REPORT\n');
    fprintf(fid, '                    FIELD #%d\n', config.SELECTED_FIELD);
    fprintf(fid, '══════════════════════════════════════════════════════════\n\n');
    fprintf(fid, 'Mission Date: %s\n', datestr(now));
    fprintf(fid, 'Mission Duration: %.1f seconds\n', timeElapsed);
    fprintf(fid, 'Target Field: #%d\n', config.SELECTED_FIELD);
    fprintf(fid, 'Coverage Achieved: %.2f%%\n', finalCoverage);
    
    if finalCoverage >= 100
        fprintf(fid, 'STATUS: ✓ 100%% COVERAGE ACHIEVED\n\n');
    else
        fprintf(fid, 'STATUS: ⚠ PARTIAL COVERAGE (%.2f%%)\n\n', finalCoverage);
    end
    
    fprintf(fid, '──────────────────────────────────────────────────────────\n');
    fprintf(fid, 'MISSION PARAMETERS\n');
    fprintf(fid, '──────────────────────────────────────────────────────────\n');
    fprintf(fid, 'Field Size: %d x %d meters\n', config.FIELD_SIZE, config.FIELD_SIZE);
    fprintf(fid, 'Total Area: %d m²\n', config.FIELD_SIZE^2);
    fprintf(fid, 'Flight Pattern: %s\n', config.SCAN_PATTERN);
    fprintf(fid, 'UAV Altitude: %d meters AGL\n', config.UAV_HEIGHT);
    fprintf(fid, 'UAV Speed: %d m/s\n', config.UAV_SPEED);
    fprintf(fid, 'Camera FOV: %d degrees\n\n', config.CAMERA_FOV);
    
    fprintf(fid, '──────────────────────────────────────────────────────────\n');
    fprintf(fid, 'UAV PERFORMANCE\n');
    fprintf(fid, '──────────────────────────────────────────────────────────\n');
    fprintf(fid, 'Initial Battery: %.1f%%\n', config.INITIAL_BATTERY);
    fprintf(fid, 'Final Battery: %.1f%%\n', uav.getBattery());
    fprintf(fid, 'Battery Used: %.1f%%\n', config.INITIAL_BATTERY - uav.getBattery());
    uavPos = uav.getPosition();
    fprintf(fid, 'Final Position: [%.1f, %.1f, %.1f] meters\n', uavPos(1), uavPos(2), uavPos(3));
    fprintf(fid, 'Mission Status: %s\n\n', uav.getStatus());
    
    fprintf(fid, '──────────────────────────────────────────────────────────\n');
    fprintf(fid, 'SCAN COVERAGE\n');
    fprintf(fid, '──────────────────────────────────────────────────────────\n');
    fprintf(fid, 'Area Scanned: %.0f m²\n', sensors.getScannedArea());
    fprintf(fid, 'Coverage Percentage: %.2f%%\n', finalCoverage);
    fprintf(fid, 'Coverage Status: ');
    if finalCoverage >= 100
        fprintf(fid, '✓ COMPLETE (100%% Target Achieved)\n\n');
    else
        fprintf(fid, '⚠ INCOMPLETE (%.2f%% of 100%% Target)\n\n', finalCoverage);
    end
    
    fprintf(fid, '──────────────────────────────────────────────────────────\n');
    fprintf(fid, 'COMPREHENSIVE CROP HEALTH ANALYSIS\n');
    fprintf(fid, '──────────────────────────────────────────────────────────\n');
    fprintf(fid, 'VEGETATION INDICES & BIOMASS:\n');
    fprintf(fid, '  NDVI: %.4f (%s)\n', sensors.getNDVI(), sensors.classifyHealth());
    fprintf(fid, '  LAI (Leaf Area Index): %.2f\n', sensors.getLAI());
    fprintf(fid, '  Biomass Estimation: %.2f kg/m²\n', sensors.getBiomass());
    fprintf(fid, '  Greenness Index: %.1f%%\n\n', sensors.getGreenness());
    
    fprintf(fid, 'STRESS INDICATORS:\n');
    fprintf(fid, '  Water Stress: %.1f%% ', sensors.getWaterStress());
    if sensors.getWaterStress() > 60
        fprintf(fid, '(CRITICAL - Irrigation needed)\n');
    elseif sensors.getWaterStress() > 40
        fprintf(fid, '(MODERATE - Monitor closely)\n');
    else
        fprintf(fid, '(LOW - Adequate moisture)\n');
    end
    
    fprintf(fid, '  Pest Attack Risk: %.1f%% ', sensors.getPestAttack());
    if sensors.getPestAttack() > 40
        fprintf(fid, '(HIGH - Immediate action)\n');
    elseif sensors.getPestAttack() > 20
        fprintf(fid, '(MODERATE - Monitoring required)\n');
    else
        fprintf(fid, '(LOW - No immediate concern)\n');
    end
    
    fprintf(fid, '  Nutrient Deficiency: %.1f%% ', sensors.getNutrientDeficiency());
    if sensors.getNutrientDeficiency() > 50
        fprintf(fid, '(HIGH - Fertilization needed)\n');
    elseif sensors.getNutrientDeficiency() > 30
        fprintf(fid, '(MODERATE - Plan fertilization)\n');
    else
        fprintf(fid, '(LOW - Adequate nutrients)\n');
    end
    
    fprintf(fid, '  Thermal Stress: %.1f%% ', sensors.getThermalStress());
    if sensors.getThermalStress() > 30
        fprintf(fid, '(HIGH - Temperature control needed)\n');
    else
        fprintf(fid, '(ACCEPTABLE)\n');
    end
    fprintf(fid, '\n');
    
    fprintf(fid, 'DISEASE & PROBLEM AREAS:\n');
    fprintf(fid, '  Disease Presence: %.1f%%\n', sensors.getDiseasePresence());
    fprintf(fid, '  Disease Type: %s\n', sensors.getDiseaseType());
    fprintf(fid, '  Affected Zones: %d areas\n', sensors.getDiseaseAreas());
    if sensors.getDiseasePresence() > 60
        fprintf(fid, '  *** CRITICAL - Immediate treatment required ***\n');
    elseif sensors.getDiseasePresence() > 40
        fprintf(fid, '  ** WARNING - Disease spreading, action needed **\n');
    elseif sensors.getDiseasePresence() > 20
        fprintf(fid, '  * ALERT - Monitor closely *\n');
    end
    fprintf(fid, '\n');
    
    fprintf(fid, 'GAP DETECTION & UNIFORMITY:\n');
    fprintf(fid, '  Gaps Detected: %d locations\n', sensors.getGapCount());
    fprintf(fid, '  Total Gap Area: %.1f m²\n', sensors.getGapArea());
    fprintf(fid, '  Field Uniformity: %.1f%%\n', sensors.getFieldUniformity());
    fprintf(fid, '  Crop Stand Quality: %.1f%%\n', sensors.getCropStandQuality());
    if sensors.getGapCount() > 10
        fprintf(fid, '  *** Significant gaps - Consider replanting ***\n');
    elseif sensors.getGapCount() > 5
        fprintf(fid, '  ** Moderate gaps - Monitor for expansion **\n');
    end
    fprintf(fid, '\n');
    
    fprintf(fid, 'GROWTH PARAMETERS:\n');
    fprintf(fid, '  Growth Stage: %s\n', sensors.getGrowthStage());
    fprintf(fid, '  Canopy Density: %.1f%%\n', sensors.getCanopyDensity());
    fprintf(fid, '  Estimated Plant Height: %.0f cm\n', sensors.getPlantHeight());
    fprintf(fid, '  Estimated Biomass: %.2f kg/m²\n\n', sensors.getBiomass());
    fprintf(fid, 'Health Distribution:\n');
    fprintf(fid, '  Healthy Crops:  %6.2f%%\n', sensors.getHealthyPercentage());
    fprintf(fid, '  Stressed Crops: %6.2f%%\n', sensors.getStressedPercentage());
    fprintf(fid, '  Disease Area:   %6.2f%%\n\n', sensors.getDiseasePercentage());
    
    fprintf(fid, '──────────────────────────────────────────────────────────\n');
    fprintf(fid, 'ACTIONABLE RECOMMENDATIONS\n');
    fprintf(fid, '──────────────────────────────────────────────────────────\n');
    
    % Critical issues first
    critical = false;
    
    if sensors.getDiseasePresence() > 60
        fprintf(fid, '🔴 CRITICAL - DISEASE OUTBREAK:\n');
        fprintf(fid, '   → Disease level: %.1f%% (SEVERE)\n', sensors.getDiseasePresence());
        fprintf(fid, '   → Type identified: %s\n', sensors.getDiseaseType());
        fprintf(fid, '   → Affected areas: %d zones\n', sensors.getDiseaseAreas());
        fprintf(fid, '   → IMMEDIATE ground inspection required\n');
        fprintf(fid, '   → Identify pathogen and apply treatment\n');
        fprintf(fid, '   → Priority: EMERGENCY ACTION\n\n');
        critical = true;
    end
    
    if sensors.getWaterStress() > 60
        fprintf(fid, '🔴 CRITICAL - WATER STRESS:\n');
        fprintf(fid, '   → Immediate irrigation required\n');
        fprintf(fid, '   → Check irrigation system functionality\n');
        fprintf(fid, '   → Monitor soil moisture levels\n');
        fprintf(fid, '   → Priority: IMMEDIATE ACTION\n\n');
        critical = true;
    end
    
    if sensors.getPestAttack() > 40
        fprintf(fid, '🔴 CRITICAL - PEST INFESTATION:\n');
        fprintf(fid, '   → High pest activity detected\n');
        fprintf(fid, '   → Ground inspection recommended\n');
        fprintf(fid, '   → Consider targeted pesticide application\n');
        fprintf(fid, '   → Priority: WITHIN 24 HOURS\n\n');
        critical = true;
    end
    
    if sensors.getNutrientDeficiency() > 50
        fprintf(fid, '🔴 CRITICAL - NUTRIENT DEFICIENCY:\n');
        fprintf(fid, '   → Severe nutrient shortage detected\n');
        fprintf(fid, '   → Soil testing recommended\n');
        fprintf(fid, '   → Apply appropriate fertilizer\n');
        fprintf(fid, '   → Priority: WITHIN 48 HOURS\n\n');
        critical = true;
    end
    
    if sensors.getDiseasePercentage() > config.DISEASE_ALERT_THRESHOLD
        fprintf(fid, '🔴 CRITICAL - DISEASE OUTBREAK:\n');
        fprintf(fid, '   → Disease symptoms in %.1f%% of field\n', sensors.getDiseasePercentage());
        fprintf(fid, '   → Type: %s\n', sensors.getDiseaseType());
        fprintf(fid, '   → Identify disease type through scouting\n');
        fprintf(fid, '   → Apply appropriate fungicide/treatment\n');
        fprintf(fid, '   → Isolate affected areas if possible\n');
        fprintf(fid, '   → Priority: IMMEDIATE ACTION\n\n');
        critical = true;
    end
    
    if sensors.getGapCount() > 15
        fprintf(fid, '🔴 CRITICAL - EXCESSIVE GAPS:\n');
        fprintf(fid, '   → %d gaps detected (%.1f m² total)\n', sensors.getGapCount(), sensors.getGapArea());
        fprintf(fid, '   → Crop stand quality: %.1f%%\n', sensors.getCropStandQuality());
        fprintf(fid, '   → Investigate cause (poor germination, pests, disease)\n');
        fprintf(fid, '   → Consider spot replanting if early season\n');
        fprintf(fid, '   → Priority: WITHIN 1 WEEK\n\n');
        critical = true;
    end
    
    % Moderate issues
    if sensors.getWaterStress() > 40 && sensors.getWaterStress() <= 60
        fprintf(fid, '🟠 MODERATE - Water Stress:\n');
        fprintf(fid, '   → Schedule irrigation within 2-3 days\n');
        fprintf(fid, '   → Monitor weather forecast\n\n');
    end
    
    if sensors.getPestAttack() > 20 && sensors.getPestAttack() <= 40
        fprintf(fid, '🟠 MODERATE - Pest Pressure:\n');
        fprintf(fid, '   → Increased monitoring required\n');
        fprintf(fid, '   → Scout field for pest identification\n');
        fprintf(fid, '   → Consider preventive measures\n\n');
    end
    
    if sensors.getNutrientDeficiency() > 30 && sensors.getNutrientDeficiency() <= 50
        fprintf(fid, '🟠 MODERATE - Nutrient Status:\n');
        fprintf(fid, '   → Plan fertilization for next application window\n');
        fprintf(fid, '   → Soil test recommended\n\n');
    end
    
    if sensors.getThermalStress() > 30
        fprintf(fid, '🟠 MODERATE - Temperature Stress:\n');
        fprintf(fid, '   → Current temp: %.1f°C\n', config.TEMPERATURE);
        fprintf(fid, '   → Consider irrigation for cooling\n');
        fprintf(fid, '   → Monitor during heat of day\n\n');
    end
    
    % Growth stage specific recommendations
    fprintf(fid, '📈 GROWTH STAGE RECOMMENDATIONS (%s):\n', sensors.getGrowthStage());
    if strcmp(sensors.getGrowthStage(), 'Emergence')
        fprintf(fid, '   → Ensure adequate soil moisture\n');
        fprintf(fid, '   → Protect from birds/pests\n');
        fprintf(fid, '   → Monitor emergence rate\n\n');
    elseif strcmp(sensors.getGrowthStage(), 'Vegetative')
        fprintf(fid, '   → Critical nitrogen requirement period\n');
        fprintf(fid, '   → Optimize plant spacing if needed\n');
        fprintf(fid, '   → Monitor for early pest/disease signs\n\n');
    elseif strcmp(sensors.getGrowthStage(), 'Flowering')
        fprintf(fid, '   → Critical water requirement period\n');
        fprintf(fid, '   → Avoid stress during pollination\n');
        fprintf(fid, '   → Monitor for flower drop\n');
        fprintf(fid, '   → Ensure adequate pollinator activity\n\n');
    elseif strcmp(sensors.getGrowthStage(), 'Fruiting')
        fprintf(fid, '   → Maintain consistent moisture\n');
        fprintf(fid, '   → Monitor for fruit pests\n');
        fprintf(fid, '   → Support heavy fruit load if needed\n');
        fprintf(fid, '   → Optimize nutrition for fruit development\n\n');
    else % Maturity
        fprintf(fid, '   → Reduce irrigation as harvest approaches\n');
        fprintf(fid, '   → Monitor for harvest readiness\n');
        fprintf(fid, '   → Plan harvest logistics\n');
        fprintf(fid, '   → Protect from late-season pests\n\n');
    end
    
    % Positive feedback
    if sensors.getHealthyPercentage() > config.HEALTHY_FIELD_THRESHOLD
        fprintf(fid, '🟢 POSITIVE - Overall Field Health:\n');
        fprintf(fid, '   → Field shows good overall health (%.1f%%)\n', sensors.getHealthyPercentage());
        fprintf(fid, '   → Continue current management practices\n');
        fprintf(fid, '   → Maintain regular monitoring schedule\n');
        fprintf(fid, '   → Document successful practices for future\n\n');
    end
    
    if sensors.getNDVI() > 0.7
        fprintf(fid, '🟢 EXCELLENT - Vegetation Index:\n');
        fprintf(fid, '   → NDVI: %.3f (Excellent)\n', sensors.getNDVI());
        fprintf(fid, '   → Strong photosynthetic activity\n');
        fprintf(fid, '   → Good crop vigor indicated\n\n');
    end
    
    if sensors.getLAI() > 4
        fprintf(fid, '🟢 EXCELLENT - Canopy Development:\n');
        fprintf(fid, '   → LAI: %.2f (Well-developed canopy)\n', sensors.getLAI());
        fprintf(fid, '   → Good light interception\n');
        fprintf(fid, '   → Optimal for current growth stage\n\n');
    end
    
    if ~critical
        fprintf(fid, '✓ NO CRITICAL ISSUES DETECTED\n');
        fprintf(fid, '  Continue routine management and monitoring\n\n');
    end
    
    fprintf(fid, '──────────────────────────────────────────────────────────\n');
    fprintf(fid, 'NEXT ACTIONS\n');
    fprintf(fid, '──────────────────────────────────────────────────────────\n');
    fprintf(fid, '1. Ground-truth identified problem areas\n');
    fprintf(fid, '2. Implement zone-specific treatments\n');
    fprintf(fid, '3. Schedule follow-up UAV survey\n');
    fprintf(fid, '4. Update field management records\n');
    fprintf(fid, '5. Compare with historical data\n\n');
    
    fprintf(fid, '══════════════════════════════════════════════════════════\n');
    fprintf(fid, 'End of Report\n');
    fprintf(fid, '══════════════════════════════════════════════════════════\n');
    
    fclose(fid);
    
    fprintf('   ✓ Report saved: %s\n', filename);
    
    %% Generate CSV data export
    csvFilename = fullfile(config.OUTPUT_FOLDER, sprintf('mission_data_%s.csv', timestamp));
    fid = fopen(csvFilename, 'w');
    
    fprintf(fid, 'Metric,Value,Unit\n');
    fprintf(fid, 'Mission Duration,%.2f,seconds\n', timeElapsed);
    fprintf(fid, 'Field Number,%d,-\n', config.SELECTED_FIELD);
    fprintf(fid, 'Field Size,%d,meters\n', config.FIELD_SIZE);
    fprintf(fid, 'Area Scanned,%.0f,m²\n', sensors.getScannedArea());
    fprintf(fid, 'Coverage,%.2f,%%\n', finalCoverage);
    if finalCoverage >= 100
        fprintf(fid, 'Coverage Status,COMPLETE,-\n');
    else
        fprintf(fid, 'Coverage Status,INCOMPLETE,-\n');
    end
    
    % Vegetation Indices
    fprintf(fid, '\n--- VEGETATION INDICES & BIOMASS ---\n');
    fprintf(fid, 'NDVI,%.4f,-\n', sensors.getNDVI());
    fprintf(fid, 'LAI,%.2f,-\n', sensors.getLAI());
    fprintf(fid, 'Biomass,%.2f,kg/m²\n', sensors.getBiomass());
    fprintf(fid, 'Greenness Index,%.1f,%%\n', sensors.getGreenness());
    
    % Stress Indicators
    fprintf(fid, '\n--- STRESS INDICATORS ---\n');
    fprintf(fid, 'Water Stress,%.1f,%%\n', sensors.getWaterStress());
    fprintf(fid, 'Pest Attack Risk,%.1f,%%\n', sensors.getPestAttack());
    fprintf(fid, 'Nutrient Deficiency,%.1f,%%\n', sensors.getNutrientDeficiency());
    fprintf(fid, 'Thermal Stress,%.1f,%%\n', sensors.getThermalStress());
    
    % Growth Parameters
    fprintf(fid, '\n--- GROWTH PARAMETERS ---\n');
    fprintf(fid, 'Growth Stage,%s,-\n', sensors.getGrowthStage());
    fprintf(fid, 'Canopy Density,%.1f,%%\n', sensors.getCanopyDensity());
    fprintf(fid, 'Plant Height,%.0f,cm\n', sensors.getPlantHeight());
    
    % Overall Health
    fprintf(fid, '\n--- OVERALL HEALTH ---\n');
    fprintf(fid, 'Healthy Percentage,%.2f,%%\n', sensors.getHealthyPercentage());
    fprintf(fid, 'Stressed Percentage,%.2f,%%\n', sensors.getStressedPercentage());
    fprintf(fid, 'Disease Percentage,%.2f,%%\n', sensors.getDiseasePercentage());
    fprintf(fid, 'Health Classification,%s,-\n', sensors.classifyHealth());
    
    % Environmental Conditions
    fprintf(fid, '\n--- ENVIRONMENTAL CONDITIONS ---\n');
    fprintf(fid, 'Temperature,%.1f,°C\n', config.TEMPERATURE);
    fprintf(fid, 'Wind Speed,%.1f,m/s\n', config.WIND_SPEED);
    fprintf(fid, 'Wind Direction,%d,degrees\n', config.WIND_DIRECTION);
    fprintf(fid, 'Humidity,%.1f,%%\n', config.HUMIDITY);
    fprintf(fid, 'Weather Type,%s,-\n', config.WEATHER_TYPE);
    
    % Mission Data
    fprintf(fid, '\n--- MISSION DATA ---\n');
    fprintf(fid, 'Final Battery,%.2f,%%\n', uav.getBattery());
    fprintf(fid, 'Mission Date,%s,-\n', datestr(now));
    
    fclose(fid);
    
    fprintf('   ✓ CSV data saved: %s\n', csvFilename);
    
    %% Print summary to console
    fprintf('\n');
    fprintf('═══════════════════════════════════════════════\n');
    fprintf('MISSION SUMMARY - FIELD #%d\n', config.SELECTED_FIELD);
    fprintf('═══════════════════════════════════════════════\n');
    fprintf('Duration: %.1f seconds\n', timeElapsed);
    if finalCoverage >= 100
        fprintf('Coverage: %.2f%% ✓\n', finalCoverage);
    else
        fprintf('Coverage: %.2f%% ⚠\n', finalCoverage);
    end
    fprintf('Avg NDVI: %.3f (%s)\n', sensors.getNDVI(), sensors.classifyHealth());
    fprintf('Healthy: %.1f%% | Stressed: %.1f%% | Disease: %.1f%%\n', ...
            sensors.getHealthyPercentage(), sensors.getStressedPercentage(), ...
            sensors.getDiseasePercentage());
    fprintf('Battery Remaining: %.1f%%\n', uav.getBattery());
    fprintf('═══════════════════════════════════════════════\n');
end