/**
* Name: Parameters
* All global parameter declarations for the PredatorPrey simulation.
* Author: hippolytegrandet
*/

model Parameters

global {
    // --- Environment ---
    int environment_size <- 100;
    geometry shape <- square(environment_size);

    // --- Population ---
    float init_predator_prey_ratio <- 1/3;
    float pop_per_10_square <- 0.5;
    int init_prey_count <- int((pop_per_10_square * environment_size^2 / 100) * (1 - init_predator_prey_ratio));
    int init_predator_count <- int((pop_per_10_square * environment_size^2 / 100) * init_predator_prey_ratio);

    int nb_suffocated <- 0;

    // --- Performance Logging ---
    bool record_duration <- false;

    // --- Terrain ---
    bool mountain_b <- true;
    string mountain_range_shape <- 'circle'; // 'square' or 'line'
    float mountain_speed_reduction <- 1/2;
    float mountain_visibility_reduction <- 1/2;
    float mountain_health_reduction_ratio <- health_regen_rate * 2;

    // --- Visualisation ---
    bool visualize_health_energy <- false;
    bool visualize_rays <- false;
    int simulation_charts_refresh_count <- 10;
    int evolution_charts_refresh_count <- 25;
    int behavior_charts_refresh_count <- 25;
    int performance_charts_refresh_count <- 50;

    // --- Simulation Control ---
    bool prey_freeze <- false;
    bool predator_freeze <- false;
    bool log_agents <- true;

    // --- Body ---
    float default_body_radius <- 1.0;

    // --- Movement ---
    float max_speed_w <- 2.0 / default_body_radius;
    float speed_still <- 0.025 * max_speed_w;
    float default_max_turning_ratio <- 0.5;

    // --- Health & Combat ---
    float health_regen_rate <- 1/20;
    float ad_health_ratio <- 1.0;
    float attack_range_ratio <- 3.0;
    bool attack_rollover <- false;
    float attack_success_p <- 0.95;
    bool attack_close <- false;
    bool attack_infront <- true;
    float attack_angle <- 45.0;

    // --- Reproduction ---
    float birth_radius_ratio <- 10.0;

    // --- Sensors ---
    float default_sensor_distance_ratio <- 15.0;
    float default_sensor_distance_range <- default_sensor_distance_ratio * default_body_radius;
    float default_sensor_angle_range <- 180.0;
    float sensor_precision_ratio <- 2.0;
    float sensor_precision <- sensor_precision_ratio * default_body_radius;
    int default_number_of_rays <- int(1 + ceil(default_sensor_angle_range / (2 * asin(sensor_precision / (2 * default_sensor_distance_range)))));

    // --- Energy Consumption ---
    float energy_consumption_moving_w <- 0.015;
    float moving_to_thinking_ratio <- 1/2;
    float hn_w <- 1.0;  // hidden neuron weight in thinking cost
    float nr_w <- 1.0;  // ray count weight in thinking cost
    float energy_consumption_thinking_w <- moving_to_thinking_ratio * energy_consumption_moving_w / (hn_w + nr_w);

    // --- Neural Network ---
    float nn_w_std <- 1.0;
    float nn_b_std <- 0.1;
    bool use_he_normal_weights <- true;
    bool clip_weights <- true;
    int num_stats_features <- 4;
    int default_sensor_groups <- 3;
    int num_ray_features;
    int default_n_hidden_neurons <- 0;
    int n_output_features <- 2;
    bool use_detected_info <- false;
    bool use_memory <- false;
    bool use_hn_memory <- use_memory and (not hn_evolution_b);
    float memory_discount_factor <- 0.8;
    bool specialized_neurons_b <- true;
    bool dropout_b <- false;
    float dropout_prob <- 0.01;

    // --- Evolution ---
    float init_std <- 0.5;
    bool br_init_b <- false;
    bool ad_init_b <- false;
    bool sensor_init_b <- false;
    bool hn_init_b <- false;
    float evolution_std <- 0.1;
    float evolution_w_std <- 0.1;
    float evolution_decay <- 0.99;
    bool br_evolution_b <- false;
    bool ad_evolution_b <- false;
    bool sensor_evolution_b <- false;
    bool hn_evolution_b <- false;
    bool w_evolution_b <- true;

    // --- Prey ---
    float energy_resting_ratio <- 1/10;
    float prey_ad_discount_factor <- 0.0;
    float reproduction_w_prey <- 30.0;
    bool suffocation_b <- true;
    float suffocating_ratio <- 1/8;
    float population_density_radius <- 5.0;
    float prey_ad_ratio <- 0.0;

    // --- Predator ---
    float energy_digestion_ratio <- 1/3;
    float reproduction_w_predator <- 1.5;
    float predator_ad_ratio <- 1.0;
}
