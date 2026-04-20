/**
* Name: PredatorPrey
* Entry point. Imports all sub-modules, runs global initialisation,
* and defines the Simulation_Testing experiment.
* Author: hippolytegrandet
*/

model PredatorPrey

import "includes/parameters.gaml"
import "includes/nn_math.gaml"
import "species/mountain.gaml"
import "species/animal.gaml"
import "species/prey.gaml"
import "species/predator.gaml"

global {

    // --- Species-dependent counters (require prey/predator to be in scope) ---
    int nb_preys -> {length(prey)};
    int nb_predators -> {length(predator)};
    int nb_animals -> nb_preys + nb_predators;
    int nb_rays_total -> sum(collect(prey, each.sensor_nb_of_rays)) + sum(collect(predator, each.sensor_nb_of_rays));
    float duration_per_ray -> float(duration) / nb_rays_total;

    // --- NN output distribution tracking (used by heatmap displays) ---
    list l_detected_type_idx_short <- [
        'Left Sense Prey',      'Left Sense Nil',      'Left Sense Predator',
        'Center Sense Prey',    'Center Sense Nil',    'Center Sense Predator',
        'Right Sense Prey',     'Right Sense Nil',     'Right Sense Predator'
    ];
    list l_detected_type_idx_gen <- [
        'Seen Prey', 'Not Seen Prey', 'Seen Predator', 'Not Seen Predator', 'Seen Nothing'
    ];

    list<float> l_detected_type_prey_hd;
    list<float> l_detected_type_predator_hd;
    list<list<float>> l_detected_type_prey_temp_hd;
    list<list<float>> l_detected_type_predator_temp_hd;
    list<float> l_detected_type_prey_sp;
    list<float> l_detected_type_predator_sp;
    list<list<float>> l_detected_type_prey_temp_sp;
    list<list<float>> l_detected_type_predator_temp_sp;


    // =========================================================
    // Initialisation
    // =========================================================

    init {
        num_ray_features <- use_detected_info ? 5 : 3;
        if !dropout_b { dropout_prob <- 0.0; }
        if (default_n_hidden_neurons = 0) and !hn_evolution_b {
            energy_consumption_thinking_w <- moving_to_thinking_ratio * energy_consumption_moving_w;
        }

        create mountain;
        create prey number: init_prey_count;
        create predator number: init_predator_count;

        write 'For Neural Networks:';
        write 'Number of Input Features: ' + prey[0].nn_n_in_features;
        write 'Average Number of Rays: ' + (mean(collect(prey, each.sensor_nb_of_rays)) with_precision 1);
        write 'Average Number of Weights: ' + (mean(collect(prey, each.nn_n_weights)) with_precision 1);

        // Initialise NN output distribution tracking buffers
        l_detected_type_prey_temp_hd <- [];
        l_detected_type_predator_temp_hd <- [];
        l_detected_type_prey_temp_sp <- [];
        l_detected_type_predator_temp_sp <- [];
        loop i from: 0 to: length(l_detected_type_idx_short) - 1 {
            l_detected_type_prey_temp_hd <+ [];
            l_detected_type_predator_temp_hd <+ [];
        }
        loop i from: 0 to: length(l_detected_type_idx_gen) - 1 {
            l_detected_type_prey_temp_sp <+ [];
            l_detected_type_predator_temp_sp <+ [];
        }
        do get_nn_outputs_distrib;

        l_detected_type_prey_hd <- [];
        l_detected_type_predator_hd <- [];
        l_detected_type_prey_sp <- [];
        l_detected_type_predator_sp <- [];
        loop i from: 0 to: length(l_detected_type_idx_short) - 1 {
            l_detected_type_prey_hd <+ mean(l_detected_type_prey_temp_hd[i]);
            l_detected_type_predator_hd <+ mean(l_detected_type_predator_temp_hd[i]);
        }
        loop i from: 0 to: length(l_detected_type_idx_gen) - 1 {
            float v <- mean(l_detected_type_prey_temp_sp[i]);
            l_detected_type_prey_sp <+ (v = 0.0 ? 1.0 : v);
            v <- mean(l_detected_type_predator_temp_sp[i]);
            l_detected_type_predator_sp <+ (v = 0.0 ? 1.0 : v);
        }
    }


    // =========================================================
    // Simulation-level reflexes
    // =========================================================

    reflex stop_simulation when: ((nb_preys <= 0) or (nb_predators <= 0)) {
        do pause;
        do save_sim_end;
    }

    reflex save_step_duration when: cycle > 0 and record_duration {
        save [cycle, duration, nb_preys, nb_predators, nb_animals, nb_rays_total, duration_per_ray]
            to: "durations.csv" format: "csv" rewrite: false;
    }

    // Accumulate NN output samples every cycle for the heatmap displays.
    reflex update_nn_outputs when: true {
        do get_nn_outputs_distrib;
    }

    // Aggregate and reset the NN output buffers every 10 cycles.
    reflex flush_nn_outputs when: (cycle mod 10 = 0) {
        l_detected_type_prey_hd <- [];
        l_detected_type_predator_hd <- [];
        l_detected_type_prey_sp <- [];
        l_detected_type_predator_sp <- [];

        loop i from: 0 to: length(l_detected_type_idx_short) - 1 {
            l_detected_type_prey_hd <+ mean(l_detected_type_prey_temp_hd[i]);
            l_detected_type_predator_hd <+ mean(l_detected_type_predator_temp_hd[i]);
        }
        loop i from: 0 to: length(l_detected_type_idx_gen) - 1 {
            float v <- mean(l_detected_type_prey_temp_sp[i]);
            l_detected_type_prey_sp <+ (v = 0.0 ? 1.0 : v);
            v <- mean(l_detected_type_predator_temp_sp[i]);
            l_detected_type_predator_sp <+ (v = 0.0 ? 1.0 : v);
        }

        l_detected_type_prey_temp_hd <- [];
        l_detected_type_predator_temp_hd <- [];
        l_detected_type_prey_temp_sp <- [];
        l_detected_type_predator_temp_sp <- [];
        loop i from: 0 to: length(l_detected_type_idx_short) - 1 {
            l_detected_type_prey_temp_hd <+ [];
            l_detected_type_predator_temp_hd <+ [];
        }
        loop i from: 0 to: length(l_detected_type_idx_gen) - 1 {
            l_detected_type_prey_temp_sp <+ [];
            l_detected_type_predator_temp_sp <+ [];
        }
    }


    // =========================================================
    // Global helper actions
    // =========================================================

    // Collects mean NN outputs (heading delta, speed) per sensor-group input pattern
    // and appends them to the rolling heatmap buffers.
    action get_nn_outputs_distrib {
        list<float> l_prey_hd <- [];
        list<float> l_predator_hd <- [];
        list<float> l_prey_sp <- [];
        list<float> l_predator_sp <- [];

        int idx_rg_1 <- num_stats_features + 2;
        int idx_rg_2 <- num_stats_features + 2 + num_ray_features;
        int idx_rg_3 <- num_stats_features + 2 + num_ray_features * 2;

        loop t_rg_1 over: [-1.0, 0.0, 1.0] {
            l_prey_hd <+ mean(collect(prey where (each.nn_f_in[idx_rg_1] = t_rg_1 and !each.exhausted), each.heading_delta));
            l_predator_hd <+ mean(collect(predator where (each.nn_f_in[idx_rg_1] = t_rg_1 and !each.digesting), each.heading_delta));
        }
        loop t_rg_2 over: [-1.0, 0.0, 1.0] {
            l_prey_hd <+ mean(collect(prey where (each.nn_f_in[idx_rg_2] = t_rg_2 and !each.exhausted), each.heading_delta));
            l_predator_hd <+ mean(collect(predator where (each.nn_f_in[idx_rg_2] = t_rg_2 and !each.digesting), each.heading_delta));
        }
        loop t_rg_3 over: [-1.0, 0.0, 1.0] {
            l_prey_hd <+ mean(collect(prey where (each.nn_f_in[idx_rg_3] = t_rg_3 and !each.exhausted), each.heading_delta));
            l_predator_hd <+ mean(collect(predator where (each.nn_f_in[idx_rg_3] = t_rg_3 and !each.digesting), each.heading_delta));
        }

        float v;
        loop t_rg over: [-1.0, 1.0] {
            v <- mean(collect(prey where ((each.nn_f_in[idx_rg_1] = t_rg or each.nn_f_in[idx_rg_2] = t_rg or each.nn_f_in[idx_rg_3] = t_rg) and !each.exhausted), each.speed));
            l_prey_sp <+ (v = 0.0 ? 1.0 : v);
            v <- mean(collect(prey where ((each.nn_f_in[idx_rg_1] != t_rg and each.nn_f_in[idx_rg_2] != t_rg and each.nn_f_in[idx_rg_3] != t_rg) and !each.exhausted), each.speed));
            l_prey_sp <+ (v = 0.0 ? 1.0 : v);
            v <- mean(collect(predator where ((each.nn_f_in[idx_rg_1] = t_rg or each.nn_f_in[idx_rg_2] = t_rg or each.nn_f_in[idx_rg_3] = t_rg) and !each.digesting), each.speed));
            l_predator_sp <+ (v = 0.0 ? 1.0 : v);
            v <- mean(collect(predator where ((each.nn_f_in[idx_rg_1] != t_rg and each.nn_f_in[idx_rg_2] != t_rg and each.nn_f_in[idx_rg_3] != t_rg) and !each.digesting), each.speed));
            l_predator_sp <+ (v = 0.0 ? 1.0 : v);
        }
        v <- mean(collect(prey where ((each.nn_f_in[idx_rg_1] = 0.0 and each.nn_f_in[idx_rg_2] = 0.0 and each.nn_f_in[idx_rg_3] = 0.0) and !each.exhausted), each.speed));
        l_prey_sp <+ (v = 0.0 ? 1.0 : v);
        v <- mean(collect(predator where ((each.nn_f_in[idx_rg_1] = 0.0 and each.nn_f_in[idx_rg_2] = 0.0 and each.nn_f_in[idx_rg_3] = 0.0) and !each.digesting), each.speed));
        l_predator_sp <+ (v = 0.0 ? 1.0 : v);

        list<list<float>> l_temp_prey_hd <- [];
        list<list<float>> l_temp_predator_hd <- [];
        list<list<float>> l_temp_prey_sp <- [];
        list<list<float>> l_temp_predator_sp <- [];
        loop i from: 0 to: length(l_detected_type_idx_short) - 1 {
            l_temp_prey_hd <+ l_detected_type_prey_temp_hd[i] + l_prey_hd[i];
            l_temp_predator_hd <+ l_detected_type_predator_temp_hd[i] + l_predator_hd[i];
        }
        loop i from: 0 to: length(l_detected_type_idx_gen) - 1 {
            l_temp_prey_sp <+ l_detected_type_prey_temp_sp[i] + l_prey_sp[i];
            l_temp_predator_sp <+ l_detected_type_predator_temp_sp[i] + l_predator_sp[i];
        }
        l_detected_type_prey_temp_hd <- l_temp_prey_hd;
        l_detected_type_predator_temp_hd <- l_temp_predator_hd;
        l_detected_type_prey_temp_sp <- l_temp_prey_sp;
        l_detected_type_predator_temp_sp <- l_temp_predator_sp;
    }

    action save_sim_end {
        save [environment_size, duration, init_prey_count, init_predator_count, nb_preys, nb_predators,
              (mean(collect(prey, each.sensor_nb_of_rays)) with_precision 1),
              (mean(collect(prey, each.nn_n_weights)) with_precision 1)]
            to: "simulation_logs.csv" format: "csv" rewrite: false;
    }
}


// =========================================================
// Experiment
// =========================================================

experiment Simulation_Testing type: gui benchmark: true {

    // --- Environment ---
    parameter "Environment Size"             category: "Environment"    var: environment_size            min: 50    max: 1000  step: 50;
    parameter "Population per Square of 10"  category: "Environment"    var: pop_per_10_square           min: 0.1   max: 2.5   step: 0.1;
    parameter "Proportion of Predators"      category: "Environment"    var: init_predator_prey_ratio    min: 0.1   max: 0.9   step: 0.05  colors: [#red, #purple, #blue];
    parameter "Add Mountain"                 category: "Environment"    var: mountain_b                  colors: [#green, #grey];
    parameter "Mountain Shape"               category: "Environment"    var: mountain_range_shape        among: ["circle", "square", "line"];

    // --- Logging ---
    parameter "Log Cycle Durations"          category: "Logging"        var: record_duration             colors: [#green, #grey];
    parameter "Log Agents"                   category: "Logging"        var: log_agents                  colors: [#green, #grey];

    // --- Visualisation ---
    parameter "Health and Energy Bar"        category: "Visualisation"  var: visualize_health_energy     colors: [#green, #grey];
    parameter "Rays"                         category: "Visualisation"  var: visualize_rays              colors: [#green, #grey];
    parameter "Simulation Metrics Refresh"   category: "Visualisation"  var: simulation_charts_refresh_count  min: 5  max: 100  step: 5;
    parameter "Behavior Metrics Refresh"     category: "Visualisation"  var: behavior_charts_refresh_count    min: 5  max: 100  step: 5;
    parameter "Evolution Metrics Refresh"    category: "Visualisation"  var: evolution_charts_refresh_count   min: 5  max: 100  step: 5;
    parameter "Performance Metrics Refresh"  category: "Visualisation"  var: performance_charts_refresh_count min: 5  max: 100  step: 5;

    // --- Sensors ---
    parameter "Sensor Distance Range"        category: "Agent Sensors"  var: default_sensor_distance_ratio  min: 10.0  max: 50.0   step: 1.0;
    parameter "Sensor Angle Range"           category: "Agent Sensors"  var: default_sensor_angle_range     min: 60.0  max: 360.0  step: 10.0;
    parameter "Sensor Angle Precision"       category: "Agent Sensors"  var: sensor_precision_ratio         min: 0.5   max: 4.0    step: 0.25;

    // --- Energy Consumption ---
    parameter "Movement Energy Ratio"        category: "Agent Energy"   var: energy_consumption_moving_w    min: 0.005  max: 0.05  step: 0.005;
    parameter "Thinking to Moving Ratio"     category: "Agent Energy"   var: moving_to_thinking_ratio       min: 1/10   max: 1/1   step: 1/10;
    parameter "Neurons Weight in Energy"     category: "Agent Energy"   var: hn_w                           min: 1.0    max: 5.0   step: 0.5;
    parameter "Rays Weight in Energy"        category: "Agent Energy"   var: nr_w                           min: 1.0    max: 5.0   step: 0.5;
    parameter "Population Density Radius"    category: "Agent Energy"   var: population_density_radius      min: 1.0    max: 10.0  step: 0.5;

    // --- Brain ---
    parameter "Number of Sensor Groups"      category: "Agent Brain"    var: default_sensor_groups          min: 2   max: 9   step: 1;
    parameter "Weight Distribution"          category: "Agent Brain"    var: use_he_normal_weights          labels: ["He & Glorot Normal", "Standard Normal"];
    parameter "Clip NN Weights"              category: "Agent Brain"    var: clip_weights                   colors: [#green, #grey];
    parameter "Starting Hidden Neurons"      category: "Agent Brain"    var: default_n_hidden_neurons       min: 0   max: 12  step: 1;
    parameter "Use Detected Heading/Speed"   category: "Agent Brain"    var: use_detected_info              colors: [#green, #grey];
    parameter "Use NN Memory"                category: "Agent Brain"    var: use_memory                     colors: [#green, #grey];

    // --- Evolution ---
    parameter "Init Distribution Std"        category: "Agent Evolution" var: init_std           min: 0.1  max: 0.9  step: 0.1;
    parameter "Init Distribute Body Radius"  category: "Agent Evolution" var: br_init_b          colors: [#green, #grey];
    parameter "Init Distribute Attack/Def"   category: "Agent Evolution" var: ad_init_b          colors: [#green, #grey];
    parameter "Init Distribute Sensors"      category: "Agent Evolution" var: sensor_init_b      colors: [#green, #grey];
    parameter "Init Distribute Hidden Neur." category: "Agent Evolution" var: hn_init_b          colors: [#green, #grey];
    parameter "Evolution Decay"              category: "Agent Evolution" var: evolution_decay     min: 0.5  max: 1.0  step: 0.01;
    parameter "Evolution Std"                category: "Agent Evolution" var: evolution_std       min: 0.1  max: 0.9  step: 0.1;
    parameter "Evolve Body Radius"           category: "Agent Evolution" var: br_evolution_b      colors: [#green, #grey];
    parameter "Evolve Attack/Defense"        category: "Agent Evolution" var: ad_evolution_b      colors: [#green, #grey];
    parameter "Evolve Sensors"               category: "Agent Evolution" var: sensor_evolution_b  colors: [#green, #grey];
    parameter "Evolve Hidden Neurons"        category: "Agent Evolution" var: hn_evolution_b      colors: [#green, #grey];
    parameter "Evolve NN Weights"            category: "Agent Evolution" var: w_evolution_b       colors: [#green, #grey];

    // --- Species Behavior ---
    parameter "Attack-Defense Discount"      category: "Species Behavior" var: ad_health_ratio    min: 0.2  max: 1.0  step: 0.05;
    parameter "Attack Rollover"              category: "Species Behavior" var: attack_rollover     colors: [#green, #grey];
    parameter "Attack Forward Only"          category: "Species Behavior" var: attack_infront      colors: [#green, #grey];
    parameter "Suffocation"                  category: "Species Behavior" var: suffocation_b       colors: [#green, #grey];
    parameter "Successful Attack Prob."      category: "Species Behavior" var: attack_success_p    min: 0.5  max: 1.0  step: 0.05;

    // --- Species Specific ---
    parameter "Prey: Resting Energy Ratio"   category: "Species Specific" var: energy_resting_ratio       min: 1/50  max: 1/2   step: 1/100;
    parameter "Prey: Attack/Defense Ratio"   category: "Species Specific" var: prey_ad_ratio              min: 0.0   max: 0.5   step: 1/20;
    parameter "Prey: A/D Discount"           category: "Species Specific" var: prey_ad_discount_factor    min: 0.0   max: 1.0   step: 1/20;
    parameter "Prey: Cycles to Reproduce"    category: "Species Specific" var: reproduction_w_prey        min: 25.0  max: 200.0 step: 5.0;
    parameter "Predator: Digestion Ratio"    category: "Species Specific" var: energy_digestion_ratio     min: 1/10  max: 1/1   step: 0.05;
    parameter "Predator: Repro. Amount"      category: "Species Specific" var: reproduction_w_predator    min: 1.0   max: 5.0   step: 0.5;
    parameter "Predator: Attack/Def. Ratio"  category: "Species Specific" var: predator_ad_ratio          min: 0.5   max: 1.0   step: 1/20;

    // --- Perturbation ---
    parameter "Freeze Prey"                  category: "Perturbation" var: prey_freeze      colors: [#green, #grey];
    parameter "Freeze Predators"             category: "Perturbation" var: predator_freeze  colors: [#green, #grey];


    output {
        // 6 displays → #split creates a 3×2 grid; each display has at most 2 charts.
        // GAMA does not support tabs-within-a-panel via GAML, so each chart group
        // gets its own full display instead of being crammed into a 2×2 sub-grid.
        layout #split parameters: true editors: false;
        monitor "Prey"       value: nb_preys;
        monitor "Predators"  value: nb_predators;
        monitor "Rays/cycle" value: default_number_of_rays;

        // 1 ── Simulation map ──────────────────────────────────────────────────
        display Simulation background: #white
            autosave: 'Simulation_' + string(environment_size) + '_' + string(default_n_hidden_neurons) + '_cycle' + string(int(cycle / 100) * 100) + '.png' {
            species mountain  aspect: mountain_disp;
            species prey      aspect: body;
            species prey      aspect: health_energy_bar;
            species prey      aspect: neuronal_sensors;
            species predator  aspect: body;
            species predator  aspect: health_energy_bar;
            species predator  aspect: neuronal_sensors;
            // Single compact status line — does not cover agents
            overlay position: {0, 0} size: {200, 10} background: rgb(0, 0, 0, 160) {
                draw 'Cycle: ' + string(cycle) + '   Prey: ' + string(nb_preys) + '   Pred: ' + string(nb_predators)
                    at: {10, 5} color: #white font: font('SansSerif', 10, #plain);
            }
        }

        // 2 ── Population counts + ratio ───────────────────────────────────────
        display Population_Analysis
            refresh: every(simulation_charts_refresh_count#cycles) type: 2d {
            chart "Species Count" type: series size: {1, 0.67} position: {0, 0} {
                data "Prey"     value: nb_preys     color: #blue;
                data "Predator" value: nb_predators color: #red;
            }
            chart "Predator / Prey Ratio" type: series size: {1, 0.33} position: {0, 0.67} {
                data "" value: (nb_preys > 0) ? (nb_predators / nb_preys) : 0.0 color: #black;
            }
        }

        // 3 ── Movement: speed + heading delta (side-by-side) ─────────────────
        display Movement
            refresh: every(behavior_charts_refresh_count#cycles) type: 2d {
            chart "Speed" type: box_whisker size: {0.5, 1} position: {0, 0} series_label_position: yaxis {
                data "Prey" value: [
                    mean(collect(prey where !each.exhausted, each.speed)),
                    median(collect(prey where !each.exhausted, each.speed)),
                    quantile((prey where !each.exhausted sort_by each.speed) collect each.speed, 0.25),
                    quantile((prey where !each.exhausted sort_by each.speed) collect each.speed, 0.75),
                    min(collect(prey where !each.exhausted, each.speed)),
                    max(collect(prey where !each.exhausted, each.speed))
                ] color: #blue accumulate_values: true;
                data "Predator" value: [
                    mean(collect(predator where !each.digesting, each.speed)),
                    median(collect(predator where !each.digesting, each.speed)),
                    quantile((predator where !each.digesting sort_by each.speed) collect each.speed, 0.25),
                    quantile((predator where !each.digesting sort_by each.speed) collect each.speed, 0.75),
                    min(predator where !each.digesting collect each.speed),
                    max(predator where !each.digesting collect each.speed)
                ] color: #red accumulate_values: true;
            }
            chart "Heading Delta" type: box_whisker size: {0.5, 1} position: {0.5, 0} series_label_position: yaxis {
                data "Prey" value: [
                    mean(collect(prey where !each.exhausted, abs(each.heading_delta))),
                    median(collect(prey where !each.exhausted, abs(each.heading_delta))),
                    quantile((prey where !each.exhausted sort_by abs(each.heading_delta)) collect abs(each.heading_delta), 0.25),
                    quantile((prey where !each.exhausted sort_by abs(each.heading_delta)) collect abs(each.heading_delta), 0.75),
                    min(collect(prey where !each.exhausted, abs(each.heading_delta))),
                    max(collect(prey where !each.exhausted, abs(each.heading_delta)))
                ] color: #blue accumulate_values: true;
                data "Predator" value: [
                    mean(collect(predator where !each.digesting, abs(each.heading_delta))),
                    median(collect(predator where !each.digesting, abs(each.heading_delta))),
                    quantile((predator where !each.digesting sort_by abs(each.heading_delta)) collect abs(each.heading_delta), 0.25),
                    quantile((predator where !each.digesting sort_by abs(each.heading_delta)) collect abs(each.heading_delta), 0.75),
                    min(predator where !each.digesting collect abs(each.heading_delta)),
                    max(predator where !each.digesting collect abs(each.heading_delta))
                ] color: #red accumulate_values: true;
            }
        }

        // 4 ── Reaction calibration: overall + relative (side-by-side) ────────
        display Calibration
            refresh: every(behavior_charts_refresh_count#cycles) type: 2d {
            chart "Angle Calibration (Overall)" type: box_whisker size: {0.5, 1} position: {0, 0} series_label_position: yaxis {
                data "Prey" value: [
                    mean(collect(prey where each.closest_sensed_enemy, abs(each.closest_sensed_angle - each.heading_delta))),
                    median(collect(prey where each.closest_sensed_enemy, abs(each.closest_sensed_angle - each.heading_delta))),
                    quantile((prey where each.closest_sensed_enemy sort_by abs(each.closest_sensed_angle - each.heading_delta)) collect abs(each.closest_sensed_angle - each.heading_delta), 0.25),
                    quantile((prey where each.closest_sensed_enemy sort_by abs(each.closest_sensed_angle - each.heading_delta)) collect abs(each.closest_sensed_angle - each.heading_delta), 0.75),
                    min(collect(prey where each.closest_sensed_enemy, abs(each.closest_sensed_angle - each.heading_delta))),
                    max(collect(prey where each.closest_sensed_enemy, abs(each.closest_sensed_angle - each.heading_delta)))
                ] color: #blue accumulate_values: true;
                data "Predator" value: [
                    mean(collect(predator where each.closest_sensed_enemy, abs(each.closest_sensed_angle - each.heading_delta))),
                    median(collect(predator where each.closest_sensed_enemy, abs(each.closest_sensed_angle - each.heading_delta))),
                    quantile((predator where each.closest_sensed_enemy sort_by abs(each.closest_sensed_angle - each.heading_delta)) collect abs(each.closest_sensed_angle - each.heading_delta), 0.25),
                    quantile((predator where each.closest_sensed_enemy sort_by (each.closest_sensed_angle - each.heading_delta)) collect abs(each.closest_sensed_angle - each.heading_delta), 0.75),
                    min(collect(predator where each.closest_sensed_enemy, abs(each.closest_sensed_angle - each.heading_delta))),
                    max(collect(predator where each.closest_sensed_enemy, abs(each.closest_sensed_angle - each.heading_delta)))
                ] color: #red accumulate_values: true;
            }
            chart "Angle Calibration (Relative)" type: box_whisker size: {0.5, 1} position: {0.5, 0} series_label_position: yaxis {
                data "Prey" value: [
                    mean(collect(prey where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 10.0)), (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)))),
                    median(collect(prey where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 10.0)), (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)))),
                    quantile((prey where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 10.0)) sort_by (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle))) collect (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)), 0.25),
                    quantile((prey where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 10.0)) sort_by (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle))) collect (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)), 0.75),
                    min(collect(prey where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 10.0)), (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)))),
                    max(collect(prey where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 10.0)), (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle))))
                ] color: #blue accumulate_values: true;
                data "Predator" value: [
                    mean(collect(predator where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 15.0)), (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)))),
                    median(collect(predator where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 15.0)), (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)))),
                    quantile((predator where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 15.0)) sort_by (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle))) collect (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)), 0.25),
                    quantile((predator where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 15.0)) sort_by (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle))) collect (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)), 0.75),
                    min(collect(predator where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 15.0)), (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)))),
                    max(collect(predator where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 15.0)), (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle))))
                ] color: #red accumulate_values: true;
            }
        }

        // 5 ── Brain heatmaps: prey (side-by-side) ────────────────────────────
        display Brain_Prey type: 2d {
            chart "Prey: Heading Delta by Input" type: heatmap size: {0.5, 1} position: {0, 0}
                x_serie_labels: l_detected_type_idx_short
                x_label: 'Sensor Group Input' y_label: 'Cycle' {
                data "Heading Delta" value: l_detected_type_prey_hd
                    color: [#darkblue, #ghostwhite, #darkgreen] accumulate_values: false;
            }
            chart "Prey: Speed by Input" type: heatmap size: {0.5, 1} position: {0.5, 0}
                x_serie_labels: l_detected_type_idx_gen
                x_label: 'Sensor Group Input' y_label: 'Cycle' {
                data "Speed" value: l_detected_type_prey_sp
                    color: [#skyblue, #darkblue] accumulate_values: false;
            }
        }

        // 6 ── Brain heatmaps: predator (side-by-side) ────────────────────────
        display Brain_Predator type: 2d {
            chart "Predator: Heading Delta by Input" type: heatmap size: {0.5, 1} position: {0, 0}
                x_serie_labels: l_detected_type_idx_short
                x_label: 'Sensor Group Input' y_label: 'Cycle' {
                data "Heading Delta" value: l_detected_type_predator_hd
                    color: [#darkblue, #ghostwhite, #darkgreen] accumulate_values: false;
            }
            chart "Predator: Speed by Input" type: heatmap size: {0.5, 1} position: {0.5, 0}
                x_serie_labels: l_detected_type_idx_gen
                x_label: 'Sensor Group Input' y_label: 'Cycle' {
                data "Speed" value: l_detected_type_predator_sp
                    color: [#skyblue, #darkblue] accumulate_values: false;
            }
        }
    }
}
