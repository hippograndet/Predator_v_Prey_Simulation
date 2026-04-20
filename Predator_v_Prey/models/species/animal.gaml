/**
* Name: Animal
* Abstract base species for all moving agents.
* Covers: perception (raycasting sensors), neural-network decision-making,
* movement, combat, reproduction, and evolution.
* Concrete subclasses: prey, predator.
* Author: hippolytegrandet
*/

model Animal

import "../includes/nn_math.gaml"
import "mountain.gaml"

species animal skills: [moving] {

    // --- Identity & Lineage ---
    int age_count <- 0 update: age_count + 1;
    animal parent <- nil;
    string family;
    int gen_count <- 0;
    string enemy_species;
    float loc_x_min;
    float loc_x_max;
    float loc_y_min;
    float loc_y_max;
    float dist_covered <- 0.0;

    // --- Status ---
    bool digesting <- false;
    bool exhausted <- false;
    bool freeze <- false;
    bool active <- true update: !exhausted and !freeze;
    int count_last_seen_enemy <- 0 update: count_last_seen_enemy + 1;
    bool in_mountains <- false update: (mountain_b and mountain[0] covers location);
    float local_p_density update: 1 / (1 + length(neighbors_at(self, body_radius * population_density_radius)));

    // --- Body ---
    float body_radius min: 1/3 * default_body_radius;
    float mass;
    int color_r min: 0 max: 255;
    int color_g min: 0 max: 255;
    int color_b min: 0 max: 255;
    rgb color <- rgb(color_r, color_g, color_b);

    // --- Health & Combat ---
    float health_max;
    float health max: health_max;
    float ad_ratio min: 0.0 max: 1.0;
    float ad_total;
    float ad_attack;
    float ad_defense;
    bool attacked <- false;
    int kill_count <- 0;

    // --- Energy ---
    float energy_max;
    float energy max: energy_max;
    float energy_consumption_moving_c;
    float energy_consumption_thinking_c;
    float energy_consumption <- 0.0 update: 0.0;

    // --- Reproduction ---
    float reproduction_m;
    float reproduction_v;
    int offspring_count <- 0;

    // --- Sensors ---
    float sensor_distance_range min: body_radius * 2 max: float(world.environment_size);
    float sensor_angle_range min: 10.0 max: 360.0;
    list<float> sensor_angles;
    list<animal> sensed_agents;
    list<float> sensed_agents_dist;
    list<animal> enemy_in_range;
    int sensor_nb_of_rays;
    list<int> sensors_idx_nn;
    bool closest_sensed_enemy update: false;
    float closest_sensed_dist;
    float closest_sensed_angle;

    // --- Movement ---
    float heading_delta <- 0.0;
    float heading_delta_delta;
    float heading_max_turning_ratio min: 0.05 max: 1.0;
    float speed <- 1.0;
    float speed_previous;
    float speed_delta;
    float speed_max;

    // --- Neural Network ---
    int nn_n_in_features;
    int nn_n_sensor_groups;
    list<float> nn_f_in;
    int nn_n_hidden_neurons;
    matrix<float> nn_w_in;
    matrix<float> nn_b_in;
    matrix<float> nn_w_hidden;
    matrix<float> nn_b_hidden;
    matrix<float> nn_memory_hidden;
    int nn_n_weights;
    list<float> nn_f_out_flat_pre;


    init {
        if parent = nil {
            // --- Starting agent ---
            location <- any_location_in(world.shape);
            family <- string(self);

            body_radius <- default_body_radius * growth_value(br_init_b, init_std);
            ad_ratio <- ad_ratio + (growth_value(ad_init_b, init_std) - 1);
            sensor_distance_range <- default_sensor_distance_range * growth_value(sensor_init_b, init_std);
            sensor_angle_range <- default_sensor_angle_range * growth_value(sensor_init_b, init_std);
            nn_n_hidden_neurons <- int(round(default_n_hidden_neurons * growth_value(hn_init_b, init_std)));
            nn_n_sensor_groups <- default_sensor_groups;
            nn_n_in_features <- (nn_n_sensor_groups * num_ray_features) + num_stats_features;
            if use_hn_memory {
                nn_n_in_features <- nn_n_in_features + nn_n_hidden_neurons;
            }

            float w_std <- init_std;
            if nn_n_hidden_neurons = 0 {
                w_std <- get_normal_std(nn_n_in_features, n_output_features, false, false);
                nn_w_in <- world.get_gauss_matrix(nn_n_in_features, n_output_features, w_std);
                w_std <- get_normal_std(n_output_features, 1, false, true);
                nn_b_in <- world.get_gauss_matrix(n_output_features, 1, w_std);
            } else {
                w_std <- get_normal_std(nn_n_in_features, nn_n_hidden_neurons, true, false);
                nn_w_in <- world.get_gauss_matrix(nn_n_in_features, nn_n_hidden_neurons, w_std);
                w_std <- get_normal_std(nn_n_hidden_neurons, 1, true, true);
                nn_b_in <- world.get_gauss_matrix(nn_n_hidden_neurons, 1, w_std);
                w_std <- get_normal_std(nn_n_hidden_neurons, n_output_features, false, false);
                nn_w_hidden <- world.get_gauss_matrix(nn_n_hidden_neurons, n_output_features, w_std);
                w_std <- get_normal_std(n_output_features, 1, false, true);
                nn_b_hidden <- world.get_gauss_matrix(n_output_features, 1, w_std);
            }

        } else {
            // --- Child agent ---
            location <- any_location_in(circle(parent.body_radius * birth_radius_ratio, parent.location) inter world.shape);
            gen_count <- parent.gen_count + 1;
            family <- parent.family;
            heading <- rnd(-360.0, 360.0);

            float noise_std <- (evolution_decay ^ gen_count);

            body_radius <- parent.body_radius * growth_value(br_evolution_b, evolution_std * noise_std);

            int color_v_range <- 0;
            color_r <- parent.color_r + rnd(-color_v_range, color_v_range);
            color_g <- parent.color_g + rnd(-color_v_range, color_v_range);
            color_b <- parent.color_b + rnd(-color_v_range, color_v_range);
            color <- rgb(color_r, color_g, color_b);

            ad_ratio <- parent.ad_ratio * growth_value(ad_evolution_b, evolution_std * noise_std);
            sensor_distance_range <- parent.sensor_distance_range * growth_value(sensor_evolution_b, evolution_std * noise_std);
            sensor_angle_range <- parent.sensor_angle_range * growth_value(sensor_evolution_b, evolution_std * noise_std);

            nn_n_in_features <- parent.nn_n_in_features;
            nn_n_sensor_groups <- parent.nn_n_sensor_groups;
            nn_w_in <- parent.nn_w_in;
            nn_b_in <- parent.nn_b_in;
            nn_w_hidden <- parent.nn_w_hidden;
            nn_b_hidden <- parent.nn_b_hidden;

            if parent.nn_n_hidden_neurons > 0 {
                nn_n_hidden_neurons <- int(round(parent.nn_n_hidden_neurons * max(growth_value(hn_init_b, evolution_std * noise_std), 1.0)));
            } else {
                nn_n_hidden_neurons <- parent.nn_n_hidden_neurons;
            }
            int new_hidden_neuron <- nn_n_hidden_neurons - parent.nn_n_hidden_neurons;

            float w_std <- init_std;
            if new_hidden_neuron != 0 {
                w_std <- get_normal_std(length(columns_list(nn_w_in)), nn_n_hidden_neurons, true, false);
                matrix<float> new_ws_in_w <- world.get_gauss_matrix(length(columns_list(nn_w_in)), new_hidden_neuron, w_std);
                nn_w_in <- nn_w_in append_vertically new_ws_in_w;

                w_std <- get_normal_std(nn_n_hidden_neurons, 1, true, true);
                matrix<float> new_b_in_w <- world.get_gauss_matrix(new_hidden_neuron, 1, w_std);
                nn_b_in <- nn_b_in append_horizontally new_b_in_w;

                w_std <- get_normal_std(nn_n_hidden_neurons, n_output_features, false, false);
                matrix<float> new_w_hidden_w <- world.get_gauss_matrix(new_hidden_neuron, n_output_features, w_std);
                nn_w_hidden <- nn_w_hidden append_horizontally new_w_hidden_w;
            }
            if w_evolution_b {
                do add_noise_weights_nn(noise_std);
            }
        }

        // --- Spatial tracking ---
        loc_x_min <- location.x;
        loc_x_max <- location.x;
        loc_y_min <- location.y;
        loc_y_max <- location.y;

        // --- Sensors ---
        do calculate_sensor_angle();
        sensor_nb_of_rays <- length(sensor_angles);

        // --- Body geometry ---
        mass <- body_radius ^ 2;
        shape <- circle(body_radius);

        // --- Energy ---
        energy_max <- mass;
        energy <- energy_max;
        energy_consumption_moving_c <- energy_consumption_moving_w * mass;
        if nn_n_hidden_neurons = 0 {
            energy_consumption_thinking_c <- energy_consumption_thinking_w * ((hn_w * nn_n_hidden_neurons) + (nr_w * sensor_nb_of_rays / default_number_of_rays));
        } else {
            energy_consumption_thinking_c <- energy_consumption_thinking_w * ((hn_w * nn_n_hidden_neurons / default_n_hidden_neurons) + (nr_w * sensor_nb_of_rays / default_number_of_rays));
        }

        // --- Health ---
        health_max <- mass;
        health <- health_max;

        // --- Movement ---
        heading_max_turning_ratio <- default_max_turning_ratio / body_radius;
        speed_max <- max_speed_w / body_radius;

        // --- NN weight count ---
        nn_n_weights <- length(columns_list(nn_w_in)) * length(rows_list(nn_w_in))
            + length(columns_list(nn_b_in)) * length(rows_list(nn_b_in));
        if nn_w_hidden != nil {
            nn_n_weights <- nn_n_weights
                + length(columns_list(nn_w_hidden)) * length(rows_list(nn_w_hidden))
                + length(columns_list(nn_b_hidden)) * length(rows_list(nn_b_hidden));
        }

        do species_specific_init();

        // --- Combat stats (after species_specific_init sets ad_total) ---
        ad_attack <- ad_total * ad_ratio;
        ad_defense <- ad_total * (1 - ad_ratio);

        // --- Reproduction ---
        reproduction_v <- (parent = nil) ? rnd(0.0, reproduction_m) : 0.0;

        do generate_sensors();
        nn_f_in <- get_features_vector();
    }


    // =========================================================
    // Reflexes
    // =========================================================

    // Prey-only: triggers resting/grazing when energy depleted or stopped.
    reflex exhaustion when: (exhausted or speed <= 0.0) and !freeze {
        do resting();
    }

    // Predator-only: processes energy absorption from a recent kill.
    reflex digestion when: digesting and !freeze {
        do digest();
    }

    reflex sense when: active {
        do generate_sensors();
    }

    reflex think when: active and !digesting {
        nn_f_in <- get_features_vector();
        float prev_heading_delta <- heading_delta;
        do compute_nn_output();
        if log_agents {
            heading_delta_delta <- heading_delta - prev_heading_delta;
            energy_consumption <- energy_consumption + energy_consumption_thinking_c;
        }
        heading <- heading + heading_delta;
        energy <- energy - energy_consumption_thinking_c;
    }

    reflex move when: active and !digesting {
        if speed < speed_still {
            speed <- 0.0;
        }
        if in_mountains {
            speed <- speed * mountain_speed_reduction;
        }
        if log_agents {
            speed_delta <- speed - speed_previous;
        }
        speed_previous <- speed;
        do move;
        if log_agents {
            loc_x_min <- min(loc_x_min, location.x);
            loc_x_max <- max(loc_x_max, location.x);
            loc_y_min <- min(loc_y_min, location.y);
            loc_y_max <- max(loc_y_max, location.y);
            dist_covered <- dist_covered + speed;
        }
        if in_mountains {
            speed <- speed / mountain_speed_reduction;
        }
        float energy_consumption_movement <- energy_consumption_moving_c * speed ^ 2;
        if log_agents {
            energy_consumption <- energy_consumption + energy_consumption_movement;
        }
        energy <- energy - energy_consumption_movement;
    }

    reflex reproduce when: !attacked and active {
        if reproduction_v >= reproduction_m and flip(local_p_density) {
            reproduction_v <- reproduction_v - reproduction_m;
            create species(self) with: [parent::self];
            offspring_count <- offspring_count + 1;
        }
    }

    reflex attack when: active {
        float attack_to_inflict <- ad_attack;
        if length(enemy_in_range) > 0 and attack_to_inflict > 0.0 {
            if attack_rollover {
                loop i from: 0 to: length(enemy_in_range) - 1 {
                    attack_to_inflict <- attack_target(attack_to_inflict, enemy_in_range[i]);
                    if attack_to_inflict <= 0.0 { break; }
                }
            } else {
                do attack_target(attack_to_inflict, enemy_in_range[0]);
                attack_to_inflict <- 0.0;
            }
        }
        if attack_close and attack_to_inflict > 0.0 {
            list<animal> enemies_in_range_circle <- ((agents of_generic_species animal) where (string(species(each)) = enemy_species)) at_distance(body_radius / 2);
            if length(enemies_in_range_circle) > 0 {
                if attack_rollover {
                    loop i from: 0 to: length(enemies_in_range_circle) - 1 {
                        attack_to_inflict <- attack_target(attack_to_inflict, enemies_in_range_circle[i]);
                        if attack_to_inflict <= 0.0 { break; }
                    }
                } else {
                    do attack_target(attack_to_inflict, enemies_in_range_circle[0]);
                }
            }
        }
    }

    reflex survive when: !freeze {
        if attacked = true {
            attacked <- false;
        } else {
            health <- health + health_regen_rate * health_max;
        }
        if in_mountains {
            health <- health - mountain_health_reduction_ratio;
        }
        if health < 0.0 {
            do die;
        }
        do species_specific_survive();
    }


    // =========================================================
    // Sensor actions
    // =========================================================

    action calculate_sensor_angle {
        float angle_step <- 2 * asin(sensor_precision / (2 * sensor_distance_range));
        int n_rays <- int(ceil(sensor_angle_range / angle_step));
        float new_angle_step <- sensor_angle_range / n_rays;

        sensor_angles <- [];
        float angle <- -(sensor_angle_range / 2.0);
        loop i from: 0 to: n_rays {
            sensor_angles <+ angle;
            angle <- angle + new_angle_step;
        }

        // Fallback: ensure enough rays to fill all sensor groups.
        if length(sensor_angles) < nn_n_sensor_groups {
            sensor_angles <- [];
            float angle_step_t <- sensor_angle_range / (nn_n_sensor_groups - 1);
            loop i from: 0 to: nn_n_sensor_groups - 1 {
                sensor_angles <+ (i * angle_step_t - sensor_angle_range / 2.0);
            }
        }
    }

    action generate_sensors {
        list<animal> agents_in_sensor_radius <- ((agents of_generic_species animal) where (each != self)) at_distance(sensor_distance_range + default_body_radius);

        sensed_agents <- [];
        sensed_agents_dist <- [];
        enemy_in_range <- [];

        loop ray_agl over: sensor_angles {
            animal a_sensed;
            float sensed_dist <- in_mountains ? sensor_distance_range * mountain_visibility_reduction : sensor_distance_range;

            point r_start <- point({location.x + body_radius * cos(heading + ray_agl), location.y + body_radius * sin(heading + ray_agl)});
            point r_end <- point({location.x + sensed_dist * cos(heading + ray_agl), location.y + sensed_dist * sin(heading + ray_agl)});
            geometry r <- line(r_start, r_end) inter world.shape;

            list<animal> a_s <- agents_in_sensor_radius overlapping r;
            if length(a_s) > 0 {
                a_sensed <- a_s closest_to self;
                sensed_dist <- self.location distance_to a_sensed;

                if string(species(a_sensed)) = enemy_species {
                    count_last_seen_enemy <- 0;
                    if sensed_dist <= attack_range_ratio * body_radius {
                        if !attack_infront or abs(ray_agl) < attack_angle {
                            if (enemy_in_range index_of a_sensed) = -1 {
                                enemy_in_range <+ a_sensed;
                            }
                        }
                    }
                }
            } else {
                sensed_dist <- (r = nil) ? 0.0 : r.perimeter + body_radius;
            }

            sensed_agents <+ a_sensed;
            sensed_agents_dist <+ sensed_dist;
        }
    }


    // =========================================================
    // Neural network actions
    // =========================================================

    // Builds the input feature vector from sensor data and agent status.
    action get_features_vector {
        closest_sensed_enemy <- false;
        closest_sensed_dist <- sensor_distance_range;
        closest_sensed_angle <- 0.0;

        list<float> v <- [];
        sensors_idx_nn <- [];

        // Status features
        v <- v + ((energy_max - energy) / energy_max);
        v <- v + 1 / (1 + count_last_seen_enemy);
        v <- v + float(in_mountains);
        v <- v + local_p_density;

        if use_hn_memory {
            if nn_memory_hidden = nil {
                loop i from: 0 to: nn_n_hidden_neurons - 1 { v <+ 0.0; }
            } else {
                v <<+ list(world.tanh_matrix(nn_memory_hidden));
            }
        }

        // Sensor group features
        loop idx_ray_group from: 0 to: nn_n_sensor_groups - 1 {
            int idx_start <- int(round(idx_ray_group * length(sensor_angles) / nn_n_sensor_groups));
            int idx_end <- int(round((idx_ray_group + 1) * length(sensor_angles) / nn_n_sensor_groups));

            float a_distance <- sensor_distance_range;
            int a_idx <- idx_start;
            bool sensed <- false;

            loop idx from: idx_start to: idx_end - 1 {
                if !sensed and sensed_agents[idx] != nil {
                    a_distance <- sensed_agents_dist[idx];
                    a_idx <- idx;
                    sensed <- true;
                } else if sensed_agents_dist[idx] < a_distance {
                    if sensed_agents[idx] != nil {
                        a_distance <- sensed_agents_dist[idx];
                        a_idx <- idx;
                        sensed <- true;
                    } else if !sensed {
                        a_distance <- sensed_agents_dist[idx];
                        a_idx <- idx;
                    }
                }
            }

            animal a_sensed <- sensed_agents[a_idx];
            float a_angle <- sensor_angles[a_idx];
            sensors_idx_nn <- sensors_idx_nn + a_idx;

            if (a_distance < closest_sensed_dist) and (string(species(a_sensed)) = enemy_species) {
                closest_sensed_enemy <- true;
                closest_sensed_dist <- a_distance;
                closest_sensed_angle <- a_angle;
            }

            v <+ ((sensor_distance_range - a_distance) / sensor_distance_range);
            v <+ (a_angle / (360.0 * heading_max_turning_ratio));

            string a_species;
            float a_speed;
            float a_heading;
            try {
                a_species <- string(species(a_sensed));
                a_speed <- a_sensed.speed;
                a_heading <- a_sensed.heading;
            } catch {
                a_species <- '';
                a_speed <- 0.0;
                a_heading <- heading;
            }

            if a_species = 'prey' {
                v <+ -1.0;
            } else if a_species = 'predator' {
                v <+ 1.0;
            } else {
                v <+ 0.0;
            }

            if use_detected_info {
                v <+ (a_speed / speed_max);
                v <+ ((heading - a_heading) / 360.0);
            }
        }

        return v;
    }

    // Runs one forward pass through the neural network, setting heading_delta and speed.
    action compute_nn_output {
        matrix<float> f_hidden <- (matrix(nn_f_in) . transpose(nn_w_in)) + nn_b_in;
        if use_hn_memory {
            nn_memory_hidden <- (nn_memory_hidden = nil)
                ? f_hidden
                : memory_discount_factor * nn_memory_hidden + (1 - memory_discount_factor) * f_hidden;
        }
        matrix<float> f_out;
        if nn_n_hidden_neurons = 0 {
            f_out <- f_hidden;
        } else {
            f_out <- world.relu_matrix(f_hidden) . transpose(nn_w_hidden) + nn_b_hidden;
        }
        if log_agents {
            nn_f_out_flat_pre <- list(f_out);
        }
        heading_delta <- (world.sigmoid(column_at(f_out, 0)[0]) - 0.5) * 360.0 * heading_max_turning_ratio;
        speed <- world.sigmoid(column_at(f_out, 1)[0]) * speed_max;
    }


    // =========================================================
    // Combat actions
    // =========================================================

    float attack_target(float attack_to_inflict, animal a) {
        if flip(1 - attack_success_p) { return 0.0; }
        if !dead(a) {
            float attack_damage <- max(0.0, attack_to_inflict - a.ad_defense);
            float a_new_health <- a.health - attack_damage;
            a.attacked <- true;
            if a_new_health <= 0 {
                attack_to_inflict <- attack_to_inflict - (a.health + a.ad_defense);
                a.health <- a_new_health;
                do kill_target(a);
            } else {
                a.health <- a_new_health;
                attack_to_inflict <- 0.0;
            }
        }
        return attack_to_inflict;
    }

    action kill_target(animal a) {
        kill_count <- kill_count + 1;
        ask a { do die; }
    }


    // =========================================================
    // Evolution actions
    // =========================================================

    action add_noise_weights_nn(float std_discount) {
        float w_std;
        if nn_n_hidden_neurons = 0 {
            w_std <- std_discount * evolution_w_std * get_normal_std(length(columns_list(nn_w_in)), length(rows_list(nn_w_in)), false, false);
            nn_w_in <- world.add_noise_matrix(w_std, nn_w_in);
            w_std <- std_discount * evolution_w_std * get_normal_std(length(columns_list(nn_b_in)), length(rows_list(nn_b_in)), false, true);
            nn_b_in <- world.add_noise_matrix(w_std, nn_b_in);
        } else {
            w_std <- std_discount * evolution_w_std * get_normal_std(length(columns_list(nn_w_in)), length(rows_list(nn_w_in)), true, false);
            nn_w_in <- world.add_noise_matrix(w_std, nn_w_in);
            w_std <- std_discount * evolution_w_std * get_normal_std(length(columns_list(nn_b_in)), length(rows_list(nn_b_in)), true, true);
            nn_b_in <- world.add_noise_matrix(w_std, nn_b_in);
            w_std <- std_discount * evolution_w_std * get_normal_std(length(columns_list(nn_w_hidden)), length(rows_list(nn_w_hidden)), false, false);
            nn_w_hidden <- world.add_noise_matrix(w_std, nn_w_hidden);
            w_std <- std_discount * evolution_w_std * get_normal_std(length(columns_list(nn_b_hidden)), length(rows_list(nn_b_hidden)), false, true);
            nn_b_hidden <- world.add_noise_matrix(w_std, nn_b_hidden);
        }
    }

    // Returns He Normal (hidden) or Glorot/Xavier Normal (output) std, or falls back to fixed std.
    float get_normal_std(int n_in, int m_out, bool hidden_layer, bool bias) {
        if !bias {
            if use_he_normal_weights {
                return hidden_layer ? sqrt(2 / n_in) : sqrt(2 / (n_in + m_out));
            } else {
                return nn_w_std;
            }
        } else {
            return nn_b_std;
        }
    }

    // Returns a growth multiplier sampled from a truncated Gaussian, or 1.0 if growth is disabled.
    float growth_value(bool growth, float std) {
        return growth ? max(truncated_gauss({1.0, std}), 0.1) : 1.0;
    }


    // =========================================================
    // Abstract hooks (implemented by prey and predator)
    // =========================================================

    action species_specific_init virtual: true;
    action species_specific_survive virtual: true;

    // Optional overrides — default is a no-op (not all species use both).
    action resting {}
    action digest {}


    // =========================================================
    // Visual aspects
    // =========================================================

    aspect body {
        draw shape color: color border: #black;
        geometry heading_line <- line([location, location + {body_radius * 2 * cos(heading), body_radius * 2 * sin(heading)}]);
        draw heading_line color: #black end_arrow: body_radius / 2;
        if attacked {
            draw circle(body_radius / 2) color: #orange;
        }
    }

    aspect active_sensors {
        do generate_sensors;
        loop i from: 0 to: length(sensed_agents) {
            if sensed_agents[i] != nil {
                geometry new_ray <- line([location, location + {sensed_agents_dist[i] * cos(heading + sensor_angles[i]), sensed_agents_dist[i] * sin(heading + sensor_angles[i])}]);
                if string(species(sensed_agents[i])) = 'prey' {
                    draw new_ray color: #blue;
                } else if string(species(sensed_agents[i])) = 'predator' {
                    draw new_ray color: #red;
                }
            }
        }
    }

    aspect sensors {
        if visualize_rays {
            do generate_sensors;
            loop i from: 0 to: length(sensed_agents) {
                if sensed_agents[i] != nil {
                    geometry new_ray <- line([location, location + {sensed_agents_dist[i] * cos(heading + sensor_angles[i]), sensed_agents_dist[i] * sin(heading + sensor_angles[i])}]);
                    if string(species(sensed_agents[i])) = 'prey' {
                        draw new_ray color: #blue;
                    } else if string(species(sensed_agents[i])) = 'predator' {
                        draw new_ray color: #red;
                    }
                } else {
                    geometry new_ray <- line([location, location + {sensor_distance_range * cos(heading + sensor_angles[i]), sensor_distance_range * sin(heading + sensor_angles[i])}]);
                    draw new_ray inter world.shape color: #black;
                }
            }
        }
    }

    aspect neuronal_sensors {
        if visualize_rays {
            do generate_sensors;
            do get_features_vector;
            loop i from: 0 to: length(sensed_agents) {
                if sensed_agents[i] != nil {
                    geometry new_ray <- line([location, location + {sensed_agents_dist[i] * cos(heading + sensor_angles[i]), sensed_agents_dist[i] * sin(heading + sensor_angles[i])}]);
                    if string(species(sensed_agents[i])) = 'prey' {
                        draw new_ray color: #blue;
                    } else if string(species(sensed_agents[i])) = 'predator' {
                        draw new_ray color: #red;
                    }
                } else {
                    geometry new_ray <- line([location, location + {sensor_distance_range * cos(heading + sensor_angles[i]), sensor_distance_range * sin(heading + sensor_angles[i])}]);
                    draw new_ray inter world.shape color: #black;
                }
            }
            loop idx over: sensors_idx_nn {
                geometry new_ray <- line([location, location + {sensed_agents_dist[idx] * cos(heading + sensor_angles[idx]), sensed_agents_dist[idx] * sin(heading + sensor_angles[idx])}]);
                draw new_ray color: #green;
            }
        }
    }

    aspect health_energy_bar {
        if visualize_health_energy {
            float bar_width <- 0.3;
            float bar_gap <- 0.05;
            float bar_edge_padding <- 0.1 * body_radius;
            float bar_length <- 2 * (body_radius + bar_edge_padding);

            point health_bar_tl <- point({location.x - bar_length / 2, location.y - body_radius - bar_width - bar_gap});
            point health_bar_br_full <- point({location.x + bar_length / 2, location.y - body_radius - bar_gap});
            point health_bar_br <- point({location.x - bar_length / 2 + (health / health_max) * bar_length, location.y - body_radius - bar_gap});
            draw rectangle(health_bar_tl, health_bar_br_full) border: #black wireframe: true;
            draw rectangle(health_bar_tl, health_bar_br) color: #green;
            image_file health_icon <- image_file("../includes/health_icon.jpeg");
            draw health_icon at: point({location.x, location.y - body_radius - bar_width / 2 - bar_gap}) size: bar_width;

            point energy_bar_tl <- point({location.x - bar_length / 2, location.y - body_radius - 2 * bar_width - 2 * bar_gap});
            point energy_bar_br_full <- point({location.x + bar_length / 2, location.y - body_radius - bar_width - 2 * bar_gap});
            point energy_bar_br <- point({location.x - bar_length / 2 + (energy / energy_max) * bar_length, location.y - body_radius - bar_width - 2 * bar_gap});
            draw rectangle(energy_bar_tl, energy_bar_br_full) border: #black wireframe: true;
            draw rectangle(energy_bar_tl, energy_bar_br) color: #green;
            image_file energy_icon <- image_file("../includes/energy_icon.png");
            draw energy_icon at: point({location.x, location.y - body_radius - 3 / 2 * bar_width - 2 * bar_gap}) size: bar_width;
        }
    }
}
