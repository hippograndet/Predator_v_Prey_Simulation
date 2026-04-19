/**
* Name: PredatorPrey
* Based on the internal empty template. 
* Author: hippolytegrandet
* Tags: 
*/


model PredatorPrey

/* Insert your model definition here */

global {
    // Environment Parameters
    int environment_size <- 100;
    geometry shape <- square(environment_size);
    
    	// Population Parameters
    float init_predator_prey_ratio <- 1/3;  // To be implemented
    float pop_per_10_square <- 0.5;
//    float init_population_density <- 100 / (pop_per_10_square * environment_size * environment_size);	// To be implemented
    int init_prey_count <- int((pop_per_10_square * environment_size^2 / 100) * (1 - init_predator_prey_ratio));
    int init_predator_count <- int((pop_per_10_square * environment_size^2 / 100) * init_predator_prey_ratio);
    
	int nb_preys -> {length(prey)};
	int nb_predators -> {length(predator)};
	int nb_suffocated <- 0;
	int nb_animals -> nb_preys + nb_predators;
	int nb_rays_total -> sum(collect(prey, each.sensor_nb_of_rays)) + sum(collect(predator, each.sensor_nb_of_rays));
//	int nb_ray_inncrements_total -> default_increments_per_ray * nb_rays_total;
	
		// Duration Parameters
	bool record_duration <- false;
	float duration_per_ray -> float(duration) / nb_rays_total;
//	float duration_per_ray_increment -> float(duration) / nb_ray_inncrements_total;
//	float duration_per_ray_increment_per_animal -> float(duration) / (nb_ray_inncrements_total*nb_animals);
//	float duration_per_animal -> float(duration) / nb_animals;
//	float duration_per_animal_squared -> float(duration) / (nb_animals^2);
//	string sensor_calculation <- 'v3';
	
		// Complex Environment Parameters
	bool mountain_b <- true;
	string mountain_range_shape <- 'circle'; // square, line
	float mountain_speed_reduction <- 1/2;
	float mountain_visibility_reduction <- 1/2;
	float mountain_health_reduction_ratio <- health_regen_rate * 2; 
	
		// Visualization
	bool visualize_health_energy <- false;
	bool visualize_rays <- false;
	int simulation_charts_refresh_count <- 10;
	int evolution_charts_refresh_count <- 25;
	int behavior_charts_refresh_count <- 25;
	int performance_charts_refresh_count <- 50;
	
		// Simulation Parameters
	bool prey_freeze <- false;
	bool predator_freeze <- false;


  	// Agent Parameter
  	bool log_agents <- true;
		// Body Parameters
	float default_body_radius <- 1.0;

		// Movement Parameters
	float max_speed_w <- 2.0 / default_body_radius;
	float speed_still <- 0.025 * max_speed_w; // Speed to go under to define as not moving and so resting
    float default_max_turning_ratio <- 0.5;
        
		// Health, Attack Defense Parameters
	float health_regen_rate <- 1/20;
	float ad_health_ratio <- 1.0;
    float attack_range_ratio <- 3.0;
    bool attack_rollover <- false;
    float attack_success_p <- 0.95;
    bool attack_close <- false;
    bool attack_infront <- true;
    float attack_angle <- 45.0;

    	// Reproduction Parameters
	float birth_radius_ratio <- 10.0;

		// Sensor Parameters
	float default_sensor_distance_ratio <- 15.0;
	float default_sensor_distance_range <- default_sensor_distance_ratio*default_body_radius;
	float default_sensor_angle_range <- 180.0;
	float sensor_precision_ratio <- 2.0;
	float sensor_precision <- sensor_precision_ratio * default_body_radius;
	int default_number_of_rays <- int(1 + ceil(default_sensor_angle_range  / (2 * asin(sensor_precision / (2 * default_sensor_distance_range)))));
//    float angle_step <- 2.5; 
//	float ray_dist_incr_ratio <- 1/2;
//    float ray_dist_incrementations <- ray_dist_incr_ratio*default_body_radius;
//    int default_increments_per_ray <- int(round(default_sensor_distance_range / ray_dist_incrementations));
		
		// Energy Consumption Parameters
	float energy_consumption_moving_w <- 0.015; // 1/50;
	float moving_to_thinking_ratio <- 1/2;
//	float sr_w <- 1.0; // Sensor Distance Range Weight
//	float sar_w <- 1.0; // Sensor Angle Range Weight
	float hn_w <- 1.0;  // Hidden Neuron Weight
	float nr_w <- 1.0;	// Number of Rays Weight 
	float energy_consumption_thinking_w <- moving_to_thinking_ratio * energy_consumption_moving_w / (hn_w + nr_w); // divide by sum of weights
	
		// NN Parameters
    float nn_w_std <- 1.0;
    float nn_b_std <- 0.1;
    bool use_he_normal_weights <- true;
    bool clip_weights <- true;
    int num_stats_features <- 4;
    int default_sensor_groups <- 3;
    int num_ray_features;
    int default_n_hidden_neurons <-  0;
	int n_output_features <- 2;
	bool use_detected_info <- false;
	bool use_memory <- false;
	bool use_hn_memory <- use_memory and (not hn_evolution_b);
	float memory_discount_factor <- 0.8;
	bool specialized_neurons_b <- true;
	bool dropout_b <- false;
	float dropout_prob <- 0.01;

    // Evolution Parameters
    	// Should these parameters start spread or not?
    float init_std <- 0.5;
	bool br_init_b <- false;
	bool ad_init_b <- false;
	bool sensor_init_b <- false;
	bool hn_init_b <- false;
		// How they evolve from generation to generation
    float evolution_std <- 0.1;
    float evolution_w_std <- 0.1;
    float evolution_decay <- 0.99; // 1.0 for no reduction over generations
	bool br_evolution_b <- false;
	bool ad_evolution_b <- false;
	bool sensor_evolution_b <- false;
	bool hn_evolution_b <- false;
	bool w_evolution_b <- true;
	
    // Prey Parameters
	float energy_resting_ratio <- 1/10;
	float prey_ad_discount_factor <- 0.0; //1/3; // 1/2
	float reproduction_w_prey <- 30.0; // 150.0
	bool suffocation_b <- true;
	float suffocating_ratio <- 1/8;
	float population_density_radius <- 5.0;
	float prey_ad_ratio <- 0.0;

    // Predator Parameters
	float energy_digestion_ratio <- 1/3; // Amount digesting each turn, proportional to predator size
	float reproduction_w_predator <- 1.5; // Number of Preys to Eat, proportional to predator size
	float predator_ad_ratio <- 1.0;

    init {
    	if use_detected_info {
    		num_ray_features <- 5;
		} else {
			num_ray_features <- 3;
		}
    	    
//    	if mountain_b {
    	create mountain;
//    	}
    	
    	if (default_n_hidden_neurons = 0) and !hn_evolution_b {
//    		hn_w <- 0.0;
    		energy_consumption_thinking_w <- moving_to_thinking_ratio * energy_consumption_moving_w;
    	}
    	
//    	if specialized_neurons_b {
//    		default_n_hidden_neurons <- default_n_hidden_neurons + default_sensor_groups;
//    	}
		if !dropout_b {
			dropout_prob <- 0.0;			
		}		
    	    	
        create prey number: init_prey_count;
        create predator number: init_predator_count;
        
//        write 'Simulation Date: ' + string(current_date);
        
        write '	For Neural Networks:';
        write 'Number of Input Features: ' + prey[0].nn_n_in_features;
        write 'Average Number of Rays: ' + (mean(collect(prey, each.sensor_nb_of_rays)) with_precision 1);
        write 'Average Number of Weights: ' + (mean(collect(prey, each.nn_n_weights)) with_precision 1);
        
		l_detected_type_prey_temp_hd <- [];
		l_detected_type_predator_temp_hd <- [];
		l_detected_type_prey_temp_sp <- [];
		l_detected_type_predator_temp_sp <- [];
		loop i from: 0 to: length(l_detected_type_idx_short) -1  {
			l_detected_type_prey_temp_hd <+ [];
			l_detected_type_predator_temp_hd <+ [];
		}
		loop i from: 0 to: length(l_detected_type_idx_gen) -1  {
			l_detected_type_prey_temp_sp <+ [];
			l_detected_type_predator_temp_sp <+ [];
		}
        do get_nn_outputs_distrib;

		l_detected_type_prey_hd <- [];
		l_detected_type_predator_hd <- [];
		l_detected_type_prey_sp <- [];
		l_detected_type_predator_sp <- [];
		
		write 'Temp';
		write 'Prey Heading Deltas: ' + l_detected_type_prey_temp_hd;
		write 'Predator Heading Deltas: ' + l_detected_type_predator_temp_hd;
		write 'Prey Speeds: ' + l_detected_type_prey_temp_sp;
		write 'Predator Speeds: ' + l_detected_type_predator_temp_sp;

		loop i from: 0 to: length(l_detected_type_idx_short) -1  {
			l_detected_type_prey_hd <+ mean(l_detected_type_prey_temp_hd[i]);
			l_detected_type_predator_hd <+ mean(l_detected_type_predator_temp_hd[i]);
		}
		loop i from: 0 to: length(l_detected_type_idx_gen) -1  {
			float v <- mean(l_detected_type_prey_temp_sp[i]);
			if v = 0.0 {
				v <- 1.0;
			}
			l_detected_type_prey_sp <+ v;

			v <- mean(l_detected_type_predator_temp_sp[i]);
			if v = 0.0 {
				v <- 1.0;
			}
			l_detected_type_predator_sp <+ v;
		}
		write cycle;
		write l_detected_type_idx_short;
		write 'Prey Heading Deltas: ' + l_detected_type_prey_hd;
		write 'Predator Heading Deltas: ' + l_detected_type_predator_hd;
		write l_detected_type_idx_gen;
		write 'Prey Speeds: ' + l_detected_type_prey_sp;
		write 'Predator Speeds: ' + l_detected_type_predator_sp;
    } 
        
    
    reflex stop_simulation when: ((nb_preys <= 0) or (nb_predators <= 0)) {
		do pause;
		
		do save_sim_end;
	} 
	
	reflex save_step_duration when: cycle>0 and record_duration {		
		save [cycle, duration, nb_preys, nb_predators, nb_animals, nb_rays_total, duration_per_ray] 
		to:"durations.csv" 
		format:"csv" 
		rewrite:false;		
	}       
    
    list l_detected_type_idx <- [
    	'prey-prey-prey', 'prey-prey-nil', 'prey-prey-pred',
    	'prey-nil-prey', 'prey-nil-nil', 'prey-nil-pred',
    	'prey-pred-prey', 'prey-pred-nil', 'prey-pred-pred',
    	'nil-prey-prey', 'nil-prey-nil', 'nil-prey-pred',
    	'nil-nil-prey', 'nil-nil-nil', 'nil-nil-pred',
    	'nil-pred-prey', 'nil-pred-nil', 'nil-pred-pred',
    	'pred-prey-prey', 'pred-prey-nil', 'pred-prey-pred',
    	'pred-nil-prey', 'pred-nil-nil', 'pred-nil-pred',
    	'pred-pred-prey', 'pred-pred-nil', 'pred-pred-pred'
    ];
    list l_detected_type_idx_short <- [
    	'Left Sense Prey', 'Left Sense Nil', 'Left Sense Predator',
    	'Center Sense Prey', 'Center Sense Nil', 'Center Sense Predator',
    	'Right Sense Prey', 'Right Sense Nil', 'Right Sense Predator'
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
    
    reflex update_nn_input_output { // when: (cycle mod behavior_charts_refresh_count = 0)
		do get_nn_outputs_distrib;
    }
    
	reflex update_nn_input_output_cycled when: (cycle mod 10 = 0) {
		l_detected_type_prey_hd <- [];
		l_detected_type_predator_hd <- [];
		l_detected_type_prey_sp <- [];
		l_detected_type_predator_sp <- [];

		loop i from: 0 to: length(l_detected_type_idx_short) -1  {
			l_detected_type_prey_hd <+ mean(l_detected_type_prey_temp_hd[i]);
			l_detected_type_predator_hd <+ mean(l_detected_type_predator_temp_hd[i]);
		}
		loop i from: 0 to: length(l_detected_type_idx_gen) -1  {
			float v <- mean(l_detected_type_prey_temp_sp[i]);
			if v = 0.0 {
				v <- 1.0;
			}
			l_detected_type_prey_sp <+ v;

			v <- mean(l_detected_type_predator_temp_sp[i]);
			if v = 0.0 {
				v <- 1.0;
			}
			l_detected_type_predator_sp <+ v;
		}

		write cycle;
		write l_detected_type_idx_short;
		write 'Prey Heading Deltas: ' + l_detected_type_prey_hd;
		write 'Predator Heading Deltas: ' + l_detected_type_predator_hd;
		write l_detected_type_idx_gen;
		write 'Prey Speeds: ' + l_detected_type_prey_sp;
		write 'Predator Speeds: ' + l_detected_type_predator_sp;
		
		l_detected_type_prey_temp_hd <- [];
		l_detected_type_predator_temp_hd <- [];
		l_detected_type_prey_temp_sp <- [];
		l_detected_type_predator_temp_sp <- [];
		loop i from: 0 to: length(l_detected_type_idx_short) -1  {
			l_detected_type_prey_temp_hd <+ [];
			l_detected_type_predator_temp_hd <+ [];
		}
		loop i from: 0 to: length(l_detected_type_idx_gen) -1  {
			l_detected_type_prey_temp_sp <+ [];
			l_detected_type_predator_temp_sp <+ [];
		}
    }    
    
    action get_nn_outputs_distrib {
        list<float> l_prey_hd <- [];
    	list<float> l_predator_hd <- [];
        list<float> l_prey_sp <- [];
    	list<float> l_predator_sp <- [];
    	int idx_rg_1 <- num_stats_features + 2;
    	int idx_rg_2 <- num_stats_features + 2 + num_ray_features;
    	int idx_rg_3 <- num_stats_features + 2 + num_ray_features*2;
		
		float v;
    	loop t_rg_1 over: [-1.0, 0.0, 1.0] {
    		l_prey_hd <+ mean(collect(prey where (each.nn_f_in[idx_rg_1] = t_rg_1 and !each.exhausted), each.heading_delta));
    		l_predator_hd <+ mean(collect(predator where (each.nn_f_in[idx_rg_1] = t_rg_1 and !each.digesting), each.heading_delta));
    	}
    	
    	loop t_rg_2 over: [-1.0, 0.0, 1.0] {
    		l_prey_hd <+ mean(collect(prey where (each.nn_f_in[idx_rg_2] = t_rg_2 and !each.exhausted), each.heading_delta));
    		l_predator_hd <+ mean(collect(predator where (each.nn_f_in[idx_rg_2] = t_rg_2 and !each.digesting), each.heading_delta));
//	    	l_prey_hd <+ mean(collect(prey where (each.nn_f_in[idx_rg_2] = t_rg_2 and !each.exhausted), each.heading_delta));
//	    	l_predator_hd <+ mean(collect(predator where (each.nn_f_in[idx_rg_2] = t_rg_2 and !each.digesting), each.heading_delta));
    	}
    	
    	loop t_rg_3 over: [-1.0, 0.0, 1.0] {
    		l_prey_hd <+ mean(collect(prey where (each.nn_f_in[idx_rg_3] = t_rg_3 and !each.exhausted), each.heading_delta));
    		l_predator_hd <+ mean(collect(predator where (each.nn_f_in[idx_rg_3] = t_rg_3 and !each.digesting), each.heading_delta));
		}
    	
    	loop t_rg over: [-1.0, 1.0] {
	    	v <- mean(collect(prey where ((each.nn_f_in[idx_rg_1] = t_rg or each.nn_f_in[idx_rg_2] = t_rg or each.nn_f_in[idx_rg_3] = t_rg) and !each.exhausted), each.speed));
			if v = 0.0 {
				v <- 1.0;
			}
			l_prey_sp <+ v;
	    	v <- mean(collect(prey where ((each.nn_f_in[idx_rg_1] != t_rg and each.nn_f_in[idx_rg_2] != t_rg and each.nn_f_in[idx_rg_3] != t_rg) and !each.exhausted), each.speed));
			if v = 0.0 {
				v <- 1.0;
			}
			l_prey_sp <+ v;
	    	v <- mean(collect(predator where ((each.nn_f_in[idx_rg_1] = t_rg or each.nn_f_in[idx_rg_2] = t_rg or each.nn_f_in[idx_rg_3] = t_rg) and !each.digesting), each.speed));
			if v = 0.0 {
				v <- 1.0;
			}
			l_predator_sp <+ v;
			v <- mean(collect(predator where ((each.nn_f_in[idx_rg_1] != t_rg and each.nn_f_in[idx_rg_2] != t_rg and each.nn_f_in[idx_rg_3] != t_rg) and !each.digesting), each.speed));
			if v = 0.0 {
				v <- 1.0;
			}
			l_predator_sp <+ v;
    	}
    	
    	v <- mean(collect(prey where ((each.nn_f_in[idx_rg_1] = 0.0 and each.nn_f_in[idx_rg_2] = 0.0 and each.nn_f_in[idx_rg_3] = 0.0) and !each.exhausted), each.speed));
		if v = 0.0 {
			v <- 1.0;
		}
		l_prey_sp <+ v;
		v <- mean(collect(predator where ((each.nn_f_in[idx_rg_1] = 0.0 and each.nn_f_in[idx_rg_2] = 0.0 and each.nn_f_in[idx_rg_3] = 0.0) and !each.digesting), each.speed));
		if v = 0.0 {
			v <- 1.0;
		}
		l_predator_sp <+ v;
    	
    	list<list<float>> l_temp_prey_hd <- [];
    	list<list<float>> l_temp_predator_hd <- [];
    	list<list<float>> l_temp_prey_sp <- [];
    	list<list<float>> l_temp_predator_sp <- [];
		loop i from: 0 to: length(l_detected_type_idx_short) -1  {
			l_temp_prey_hd <+  l_detected_type_prey_temp_hd[i] + l_prey_hd[i];
			l_temp_predator_hd <+ l_detected_type_predator_temp_hd[i] + l_predator_hd[i];
		}
		loop i from: 0 to: length(l_detected_type_idx_gen) -1  {
			l_temp_prey_sp <+  l_detected_type_prey_temp_sp[i] + l_prey_sp[i];
			l_temp_predator_sp <+ l_detected_type_predator_temp_sp[i] + l_predator_sp[i];
		}
		
		l_detected_type_prey_temp_hd <- l_temp_prey_hd;
		l_detected_type_predator_temp_hd <- l_temp_predator_hd;
		l_detected_type_prey_temp_sp <- l_temp_prey_sp;
		l_detected_type_predator_temp_sp <- l_temp_predator_sp;
    }
        // Helper Function For Matrix Manipulation
    matrix<float> sigmoid_matrix(matrix<float> m) {
		list<list<float>> rows <- rows_list(m);	
//		write length(rows);	
    	matrix<float> mt <- matrix(list_sigmoid(rows[0]));
//		write length(columns_list(mt));	
    	
    	if length(rows) > 1 {
			loop i from: 1 to: (length(rows) - 1) {
				mt <- mt append_vertically matrix(list_sigmoid(rows[i]));
//				write length(columns_list(mt));	
			}     
		}
		
		return mt;		
    }
    
    matrix<float> relu_matrix(matrix<float> m) {
    	
		list<list<float>> rows <- rows_list(m);
		
    	matrix<float> mt <- matrix(list_relu(rows[0]));
    	
    	if length(rows) > 1 {
			loop i from: 1 to: (length(rows) - 1) {
				mt <- mt append_vertically matrix(list_relu(rows[i]));
			}     
		}
		
		return mt;		
    }
   
    matrix<float> tanh_matrix(matrix<float> m) {
		list<list<float>> rows <- rows_list(m);	
//		write length(rows);	
    	matrix<float> mt <- matrix(list_tanh(rows[0]));
//		write length(columns_list(mt));	
    	
    	if length(rows) > 1 {
			loop i from: 1 to: (length(rows) - 1) {
				mt <- mt append_vertically matrix(list_tanh(rows[i]));
//				write length(columns_list(mt));	
			}     
		}
		
		return mt;		
    }
     
    list<float> list_sigmoid(list<float> l) {
    	list<float> new_l <- [];
    	loop i from: 0 to: (length(l) - 1) {
    		new_l <+ sigmoid(l[i]);
		}
    	
    	return new_l;
    }
    
    list<float> list_relu(list<float> l) {
    	list<float> new_l <- [];
    	loop i from: 0 to: (length(l) - 1) {
    		new_l <+ relu(l[i]);
		}
    	
    	return new_l;
    }

    list<float> list_tanh(list<float> l) {
    	list<float> new_l <- [];
    	loop i from: 0 to: (length(l) - 1) {
    		new_l <+ tanh(l[i]);
		}
    	
    	return new_l;
    }
  
    float sigmoid(float x) {
    	return 1.0 / (1.0 + exp(-x));
	}

    float relu(float x) {
    	return max(0.0, x);
	}  
    
    matrix<float> get_gauss_matrix(int n, int m, float std) {
    	
    	matrix<float> mt <- matrix(list_gauss(n, std));
    	
    	if m > 1 {
			loop i from: 1 to: (m - 1) {
				mt <- mt append_vertically matrix(list_gauss(n, std));
			}     
		}
		
		return mt;		
    }
    
    list<float> list_gauss(int n, float std) {
    	    	
    	list<float> l <- [];
	    loop i from: 0 to: (n - 1) {
	    	float v <- gauss({0.0, std});
	    	
	    	// Dropout
	    	if flip(dropout_prob) {
	    		v <- 0.0;
	    	}
	    	
	    	if clip_weights {
	    		v <- min(max(v, -3*std), 3*std);
	    	}
    		l <+ v;
		}
    	
    	return l;
    }
        
	matrix<float> add_noise_matrix(float std, matrix<float> m) {
		if m != nil {
			matrix<float> m_noise <- get_gauss_matrix(length(columns_list(m)), length(rows_list(m)), std);
			m <- m + m_noise;
		}
		
		return m;
	}

	matrix<float> remove_surrounding_n_columns(int n_remove, matrix<float> m) {
		list<list<float>> cols <- columns_list(m); // split into columns

		// Now reassemble the matrix by horizontally appending the columns
		matrix<float> new_m <- matrix(cols[n_remove]);
		loop i from: n_remove + 1 to: (length(cols) - n_remove - 1) {
		   new_m <- new_m append_vertically matrix(cols[i]);
		}

		new_m <- transpose(new_m);

		return new_m;		
	}
    
		// Other Helper Functions
	action  save_sim_end {
		save [environment_size, duration, init_prey_count, init_predator_count, nb_preys, nb_predators, (mean(collect(prey, each.sensor_nb_of_rays)) with_precision 1), (mean(collect(prey, each.nn_n_weights)) with_precision 1)] 
		to:"simulation_logs.csv" 
		format:"csv"
		rewrite:false;		
	}
}

species mountain {	
	init {
		if mountain_range_shape = 'circle' {
			shape <- circle(environment_size*1/5);
		} else if mountain_range_shape = 'square' {
			shape <- square(environment_size*1/5);
		} else if mountain_range_shape = 'line' {
			shape <- rectangle(environment_size*1/10, environment_size*1/2);
		} else {
			shape <- circle(environment_size*1/5);
		}
		location <- point({environment_size/2, environment_size/2});
	}

	aspect mountain_disp {
		if mountain_b {
			draw shape color: #darkgrey;
		}
    }
	
}

species animal skills: [moving] {
	
		// General
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
		// Status Variables
    bool digesting <- false;
	bool exhausted <- false;
	bool freeze <- false;
	int count_last_seen_enemy <- 0 update: count_last_seen_enemy + 1;
	bool in_mountains <- false update: (mountain_b and mountain[0] covers location);	
	float local_p_density update: 1 / (1 + length(neighbors_at(self, body_radius * population_density_radius)));
	
		// Body
	float body_radius min: 1/3*default_body_radius; // min: ray_dist_incrementations;
	float mass;
			// Color
	int color_r min: 0 max: 255; int color_g min: 0 max: 255; int color_b min: 0 max: 255;
	rgb color <- rgb(color_r, color_g, color_b);
	
		// Health
	float health_max;
	float health max: health_max;
			// Attack Defense
	float ad_ratio min: 0.0 max: 1.0;
	float ad_total;
	float ad_attack;
	float ad_defense;
	bool attacked <- false;
	int kill_count <- 0;
	
		// Energy
	float energy_max;
	float energy max: energy_max;
			// Energy Consumption
    float energy_consumption_moving_c;
    float energy_consumption_thinking_c;
    float energy_consumption <- 0.0 update: 0.0;

		// Reproduction
	float reproduction_m;
	float reproduction_v;
	int offspring_count <- 0;
		
		// Sensors
    float sensor_distance_range min: body_radius*2 max: float(world.environment_size);
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

    	// Movement
    float heading_delta <- 0.0;
    float heading_delta_delta;
    float heading_max_turning_ratio min: 0.05 max: 1.0;
    float speed <- 1.0;
    float speed_previous;
    float speed_delta;
    float speed_max;
    
    	// NN
	int nn_n_in_features;
	int nn_n_sensor_groups;
    list<float> nn_f_in;
	int nn_n_hidden_neurons;
	matrix<float> nn_w_in;
	matrix<float> nn_b_in;
	matrix<float> nn_w_hidden;
	matrix<float> nn_b_hidden;
	matrix<float> nn_memory_hidden;
//	list<float> nn_f_hidden_flat;
	int nn_n_weights;
	list<float> nn_f_out_flat_pre;
    
    
    init {	
    	if parent = nil {
    	// Starting Agent
    		location <- any_location_in(world.shape);    		
    		family <- string(self);
    		
    		// Body
		    body_radius <- default_body_radius * growth_value(br_init_b, init_std);
		    
		    // Attack-Defense
		    ad_ratio <- ad_ratio + (growth_value(ad_init_b, init_std)-1);
		    
		    // Sensor
		    sensor_distance_range <- default_sensor_distance_range * growth_value(sensor_init_b, init_std);
		    sensor_angle_range <- default_sensor_angle_range * growth_value(sensor_init_b, init_std);
    		    		
    		// NN
    		nn_n_hidden_neurons <- int(round(default_n_hidden_neurons * growth_value(hn_init_b, init_std)));
    		nn_n_sensor_groups <- default_sensor_groups; // int(round(default_sensor_groups * growth_value(hn_init_b, init_std)));
    		nn_n_in_features <- (nn_n_sensor_groups * num_ray_features) + num_stats_features;
    		if use_hn_memory {
    			nn_n_in_features <- nn_n_in_features + nn_n_hidden_neurons;
    		}
    		
    			// Setup NN Matrices
    		float w_std <- init_std;
    		if nn_n_hidden_neurons = 0 {
    			// Try Creating specified neurons, and also dropout
    			w_std <- get_normal_std(nn_n_in_features, n_output_features, false, false);
	    		nn_w_in <- world.get_gauss_matrix(nn_n_in_features, n_output_features, w_std);
	    		
    			w_std <- get_normal_std(n_output_features, 1, false, true);
				nn_b_in <- world.get_gauss_matrix(n_output_features, 1, w_std);
    		} else {
    			w_std <- get_normal_std(nn_n_in_features, nn_n_hidden_neurons, true, false);
    			nn_w_in <- world.get_gauss_matrix(nn_n_in_features, nn_n_hidden_neurons, w_std);
    			
//    			if specialized_neurons_b {
//    				nn_w_in <- specialize_neurons(nn_w_in, w_std);
//    			}
    			
    			w_std <- get_normal_std(nn_n_hidden_neurons, 1, true, true);
				nn_b_in <- world.get_gauss_matrix(nn_n_hidden_neurons, 1, w_std);
				
    			w_std <- get_normal_std(nn_n_hidden_neurons, n_output_features, false, false);
    			nn_w_hidden <- world.get_gauss_matrix(nn_n_hidden_neurons, n_output_features, w_std);
    			w_std <- get_normal_std(n_output_features, 1, false, true);
				nn_b_hidden <- world.get_gauss_matrix(n_output_features, 1, w_std);
    		}
    		
				
    	} else {
    	// Child Agent
    		location <- any_location_in(circle(parent.body_radius*birth_radius_ratio, parent.location) inter world.shape); // parent.location
			gen_count <- parent.gen_count + 1;
    		family <- parent.family;
    		
    		heading <- rnd(-360.0, 360.0);
	
	// Reproduction

			float noise_std <- (evolution_decay ^ gen_count);
			
			// Body
				// Body Radius Evolution
			body_radius <- parent.body_radius * growth_value(br_evolution_b, evolution_std * noise_std);
			
				// Color
			int color_v_range <- 0; // 25;
			color_r <- parent.color_r + rnd(-color_v_range, color_v_range);
			color_g <- parent.color_g + rnd(-color_v_range, color_v_range);
			color_b <- parent.color_b + rnd(-color_v_range, color_v_range);
			color <- rgb(color_r, color_g, color_b);
			
			// Attack Defense
			ad_ratio <- parent.ad_ratio * growth_value(ad_evolution_b, evolution_std * noise_std);
			
			// Sensor
			sensor_distance_range <- parent.sensor_distance_range * growth_value(sensor_evolution_b, evolution_std * noise_std);
			sensor_angle_range <- parent.sensor_angle_range * growth_value(sensor_evolution_b, evolution_std * noise_std);
						
			// NN
			nn_n_in_features <- parent.nn_n_in_features; //(sensor_groups * num_ray_features) + num_stats_features;
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
    		
				// New Weights relative to evolution hidden neurons	
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
				// Add Noise to Weights
			if w_evolution_b {
				do add_noise_weights_nn(noise_std);
			}
    	}
    	// Spatial Info
		loc_x_min <- location.x;
		loc_x_max <- location.x;
		loc_y_min <- location.y;
		loc_y_max <- location.y;
    	
    	// Calculate Ray Angles
    	do calculate_sensor_angle();
    	sensor_nb_of_rays <- length(sensor_angles);
    	
		// Body
		mass <- body_radius^2;
		shape <- circle(body_radius);
		
		// Energy
		energy_max <- mass;
		energy <- energy_max;
			// Energy Consumption
    	energy_consumption_moving_c <- energy_consumption_moving_w * mass;
    	if nn_n_hidden_neurons = 0 {
//    		write energy_consumption_thinking_w;
//    		write sensor_nb_of_rays;
//    		write hn_w * nn_n_hidden_neurons;
//    		write nr_w * sensor_nb_of_rays / default_number_of_rays;
    	    energy_consumption_thinking_c <- energy_consumption_thinking_w * ((hn_w * nn_n_hidden_neurons) + (nr_w * sensor_nb_of_rays / default_number_of_rays));
    	} else {
	    	energy_consumption_thinking_c <- energy_consumption_thinking_w * ((hn_w * nn_n_hidden_neurons / default_n_hidden_neurons) + (nr_w * sensor_nb_of_rays / default_number_of_rays));
    	}

		// Health
		health_max <- mass;
		health <- health_max;

		// Movement
		heading_max_turning_ratio <- default_max_turning_ratio / body_radius;
		speed_max <- max_speed_w / body_radius;

		// Neural Network
		nn_n_weights <- length(columns_list(nn_w_in))*length(rows_list(nn_w_in)) + length(columns_list(nn_b_in))*length(rows_list(nn_b_in)); 
		if nn_w_hidden != nil {
			nn_n_weights <- nn_n_weights + length(columns_list(nn_w_hidden))*length(rows_list(nn_w_hidden)) + length(columns_list(nn_b_hidden))*length(rows_list(nn_b_hidden));
		}
		

		do species_specific_init();
		
		// Attack Defense
    	ad_attack <- ad_total * ad_ratio;
		ad_defense <- ad_total * (1 - ad_ratio);
		
		// If New Run, start reproduction moment random
		if parent = nil {
			reproduction_v <- rnd(0.0, reproduction_m);
		} else {
			reproduction_v <- 0.0;
		}
		
		do generate_sensors();
		nn_f_in <- get_features_vector();
    }
      
    	// Only for Prey   
    reflex exhaustion when: (exhausted or speed <= 0.0) and !freeze {
    	do resting();	
    }
    
    	// Only for Predator
	reflex digestion when: digesting and !freeze {
		do digest();
	}
	          
    reflex sense when: !exhausted and !freeze  {
		do generate_sensors();
		
    }
    
    reflex think  when: !exhausted and !digesting and !freeze {    	
    	nn_f_in <- get_features_vector();
    	
    	matrix<float> f_hidden <- (matrix(nn_f_in) . transpose(nn_w_in)) + nn_b_in;
    	if use_hn_memory {
    		if nn_memory_hidden = nil {
    			nn_memory_hidden <- f_hidden;
    		} else {
    			nn_memory_hidden <- memory_discount_factor * nn_memory_hidden + (1 - memory_discount_factor) * f_hidden;
    		}
    	}
		
		matrix<float> f_out;
		if nn_n_hidden_neurons = 0 {
			f_out <- f_hidden;
		} else {
    		f_out <- world.relu_matrix(f_hidden) . transpose(nn_w_hidden) + nn_b_hidden;
    	}

    	float temp_heading_delta <- (world.sigmoid(column_at(f_out, 0)[0]) - 0.5) * 360.0 * heading_max_turning_ratio;
  		if log_agents {
			nn_f_out_flat_pre <- list(f_out);
  			heading_delta_delta <- temp_heading_delta - heading_delta;
  			energy_consumption <- energy_consumption + energy_consumption_thinking_c;
    	}
    	    	
  		heading_delta <- temp_heading_delta;
  		
//   		write 'Heading: ' + string(heading) + ' Heading Delta: ' + heading_delta;

  		heading <- heading + heading_delta;
  		
//   		write 'New Heading: ' + string(heading);

  		speed <- world.sigmoid(column_at(f_out, 1)[0]) * speed_max;
  		
//  		write string(self) + ': ' + nn_f_out_flat_pre + '-' + string(heading_delta) + ' - ' + string(speed);
  		
    	energy <- energy - energy_consumption_thinking_c;
    }
        
    reflex move  when: !exhausted and !digesting and !freeze {
    	
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
    	
		float energy_consumption_movement <- energy_consumption_moving_c * speed^2;
		if log_agents {
  			energy_consumption <- energy_consumption + energy_consumption_movement;		
  		}
		energy <- energy - energy_consumption_movement;
    }
    
    reflex reproduce when: !attacked and !exhausted and !freeze {
				
		if reproduction_v >= reproduction_m and flip(local_p_density) {
			reproduction_v <- reproduction_v - reproduction_m;
			create species(self) with:[
				parent::self
			];
			
			offspring_count <- offspring_count + 1;
		}
	}
    
	reflex attack when: !exhausted and !freeze {
		
		float attack_to_inflict <- ad_attack;
		if length(enemy_in_range) > 0 and attack_to_inflict > 0.0 {	
			if attack_rollover {		
				loop i from: 0 to: length(enemy_in_range) - 1 {
					attack_to_inflict <- attack_target(attack_to_inflict, enemy_in_range[i]);
					
					if attack_to_inflict <= 0.0 {break;}
				}	
			} else {
				do attack_target(attack_to_inflict, enemy_in_range[0]);
				attack_to_inflict <- 0.0; 
			}
		}
		
		if attack_close and attack_to_inflict > 0.0 {
			list<animal> enemies_in_range_circle;
			if enemy_species = 'prey' {
				enemies_in_range_circle <- prey at_distance(body_radius/2);
			} else if enemy_species = 'predator' {
				enemies_in_range_circle <- predator at_distance(body_radius/2);
			}
			if length(enemies_in_range_circle) > 0 {
				if attack_rollover {
					loop i from: 0 to: length(enemies_in_range_circle) - 1 {
						attack_to_inflict <- attack_target(attack_to_inflict, enemies_in_range_circle[i]);
						
						if attack_to_inflict <= 0.0 {break;}
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
    		health <- health + health_regen_rate*health_max;
    	}
    	
    	if in_mountains {
       		health <- health - mountain_health_reduction_ratio;
       	}
       	if health < 0.0 {
       		do die;
       	}
    	
    	do species_specific_survive();
	}     

		// Helper Functions
	action calculate_sensor_angle {
		float angle_step <- 2 * asin(sensor_precision / (2 * sensor_distance_range));
		int n_rays <- int(ceil(sensor_angle_range / angle_step));
		float new_angle_step <- sensor_angle_range / n_rays;
		
		sensor_angles <- [];
    	float angle <- - (sensor_angle_range / 2.0);		// Calculate the distance between the max range points
    	loop i from: 0 to: n_rays {
    		sensor_angles <+ angle;
    		angle <- angle + new_angle_step;
    	}
//    	sensor_angles <- sensor_angles + (sensor_angle_range / 2.0);
//    	
    		// If sensors so small, that not enough to group
    	if length(sensor_angles) < nn_n_sensor_groups {
    		sensor_angles <- [];
    		float angle_step_t <- sensor_angle_range / (nn_n_sensor_groups - 1);
	    	loop i from: 0 to: nn_n_sensor_groups - 1 {
    			sensor_angles <+ (i * angle_step_t - sensor_angle_range / 2.0);
	    	}
    	}
	}

    action generate_sensors {
    	
		list<animal> agents_in_sensor_radius <- prey at_distance(sensor_distance_range - default_body_radius);
		agents_in_sensor_radius <- agents_in_sensor_radius + (predator at_distance(sensor_distance_range + default_body_radius));

		sensed_agents <- [];
		sensed_agents_dist <- [];
    	enemy_in_range <- [];

    	loop ray_agl over: sensor_angles {
    		bool ray_block <- false;
    		animal a_sensed;
    		float sensed_dist <- sensor_distance_range;
    		if in_mountains {
    			sensed_dist <- sensed_dist * mountain_visibility_reduction;
    		}
    		
			point r_start <- point({location.x + body_radius * cos(heading + ray_agl), location.y + body_radius * sin(heading + ray_agl)});
			point r_end <- point({location.x + sensed_dist * cos(heading + ray_agl), location.y + sensed_dist * sin(heading + ray_agl)});
			geometry r <- line(r_start, r_end);
			r <- r inter world.shape;
			
			list<animal> a_s <- agents_in_sensor_radius overlapping r; // overlapping
			if length(a_s) > 0 {
				a_sensed <- a_s closest_to self;

				sensed_dist <- self.location distance_to a_sensed;
				ray_block <- true;
				
				if string(species(a_sensed)) = enemy_species {
    				
					count_last_seen_enemy <- 0;
					
					if sensed_dist <= attack_range_ratio*body_radius {
						
						if !attack_infront or abs(ray_agl) < attack_angle {
							int idx <- enemy_in_range index_of a_sensed;
							if idx = -1 {
								enemy_in_range <+ a_sensed;	
							}
						}
					}
				}
			} else {
				if r = nil {
					sensed_dist <- 0.0;
				} else {
					sensed_dist <- r.perimeter + body_radius;
				}
			}
   
			sensed_agents <+ a_sensed;
			sensed_agents_dist <+ sensed_dist; 		
    	}
    }
        
    action get_features_vector {
   
//    	write self;
    	
		closest_sensed_enemy <- false;
		closest_sensed_dist <- sensor_distance_range;
		closest_sensed_angle <- 0.0;
    	
    	list<float> v <- [];
    	sensors_idx_nn <- [];
    	
    	// Add Status Features
    	v <- v + ((energy_max-energy)/energy_max);
//    	v <- v + (health/health_max);
//		v <- v + speed;
//		v <- v + (heading_delta/180.0);
//		v <- v + (heading/180.0);
		v <- v + 1 / (1 + count_last_seen_enemy);
		v <- v + float(in_mountains);
		v <- v + local_p_density;
		
		if use_hn_memory {
//			v <- v + nn_f_hidden_flat;
    		if nn_memory_hidden = nil {
    			loop i from: 0 to: nn_n_hidden_neurons - 1 {
					v <+ 0.0;
				}
			} else {
				v <<+ list(world.tanh_matrix(nn_memory_hidden));
			}
		}    			
    	    	
    	// Add Sensor Features in 5 Groups 	
    	loop idx_ray_group from: 0 to: nn_n_sensor_groups - 1 {
//    		write idx_ray_group;
    		int idx_start <- int(round(idx_ray_group * length(sensor_angles) / nn_n_sensor_groups));
    		int idx_end <- int(round((idx_ray_group + 1) * length(sensor_angles) / nn_n_sensor_groups));
//    		write string(idx_start) + ' ' + string(idx_end);
    		
    		// Get closest agent
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
    				} else {
    					if !sensed {
    						a_distance <- sensed_agents_dist[idx];
    						a_idx <- idx;
    					}
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
    		v <+ (a_angle /  (360.0 * heading_max_turning_ratio));
    		
    		
				// Add Agent Detected Specific Features
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
    		
//    		write 'Sensor Group: ' + string(idx_ray_group) + ' Range: [' + string(sensor_angles[idx_start]) + ', ' + string(sensor_angles[idx_end-1]) + ']';
//    		write 'Angle: ' + string(a_angle) + ' idx: ' + string(a_idx);
//    		write 'Agent Detected: ' + a_sensed + ' Species: ' + a_species;
    		
    		// Add Agent Seen Indicator Variable
    		if a_species = 'prey' {
    			v <+ -1.0;
    		} else if a_species = 'predator' {
    			v <+ 1.0;
    		} else {
    			v <+ 0.0;
    		}
    		
    		// Speed & Heading Observed
    		if use_detected_info {
    			v <+ (a_speed / speed_max);
				v <+ ((heading - a_heading) / 360.0);
    		}    		
    	}
    	
    	return v;
    }
            
    float attack_target(float attack_to_inflict, animal a) {
    	
    	if flip(1 - attack_success_p) {
    		return 0.0;
    	}
    	
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
    	
		ask a {
			do die;
		}
    }
    	
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
			w_std <- std_discount * evolution_w_std* get_normal_std(length(columns_list(nn_b_hidden)), length(rows_list(nn_b_hidden)), false, true);
			nn_b_hidden <- world.add_noise_matrix(w_std, nn_b_hidden);
		}
	}
	   
	float get_normal_std(int n_in, int m_out, bool hidden_layer, bool bias) {
		float std;
		if !bias {
	    	if use_he_normal_weights {
	    		if hidden_layer {
	    			// He Normal
	    			std <- sqrt(2 / (n_in));
	    		} else {
	    			// Glorot / Xavier Normal 
	    			std <- sqrt(2 / (n_in + m_out));
	    		}
	    	} else {
	    		std <- nn_w_std;
	    	}
	    } else {
	    	std <- nn_b_std;
	    }
    			
//    	write string(n_in) + ' ' + string(m_out) + ' ' + string(hidden_layer) + ' ' + string(bias);
//    	write std;
    	
		return std;
	}
		
	action species_specific_init {
	}
    
    action species_specific_survive {
    }
    
    action resting {
    }
    
    action digest {
    }
    
    float growth_value(bool growth, float std) {
    	if growth {
    		return max(truncated_gauss({1.0, std}), 0.1);
    	} else {
    		return 1.0;
    	}
    }

		// Visual Aspects     
    aspect body {
        draw shape color: color border: #black; // (color + 255 * (1.0 - energy/energy_max))
    	geometry heading_line <- line([location, location + {body_radius * 2 * cos(heading), body_radius * 2 * sin(heading)}]);
		draw heading_line color: #black end_arrow: body_radius/2;
		if attacked {
			draw circle(body_radius/2) color: #orange;
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
//			draw string(sensor_nb_of_rays) color: #pink;
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
//	    		if sensed_agents[idx] != nil {
//	    			geometry new_ray <- line([location, location + {sensed_agents_dist[idx] * cos(heading + sensor_angles[idx]), sensed_agents_dist[idx] * sin(heading + sensor_angles[idx])}]);
//					rgb temp_color;
////					if string(species(sensed_agents[idx])) = enemy_species {
////						temp_color <- #red;
////					} else {
////						temp_color <- #green;
////					}
//					draw new_ray color: #green;
//	    		} else {
//	    			geometry new_ray <- line([location, location + {sensor_distance_range * cos(heading + sensor_angles[idx]), sensor_distance_range * sin(heading + sensor_angles[idx])}]);
//	    			draw new_ray inter world.shape color: #darkgrey;
//	    		}
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
			float bar_length <- 2*(body_radius + bar_edge_padding);
			
			point health_bar_tl <- point({
				location.x - bar_length/2, 
				location.y - body_radius - bar_width - bar_gap
			});
			point health_bar_br_full <- point({
				location.x + bar_length/2, 
				location.y - body_radius - bar_gap
			});
			point health_bar_br <- point({
				location.x - bar_length/2 + (health/health_max)*bar_length, 
				location.y - body_radius - bar_gap
			});
			// Full Health Bar
			draw rectangle(health_bar_tl, health_bar_br_full) border: #black wireframe: true;
			// Health Bar
			draw rectangle(health_bar_tl, health_bar_br) color: #green;
			image_file health_icon <- image_file("../includes/health_icon.jpeg");
			draw health_icon at:  point({location.x, location.y - body_radius - bar_width/2 - bar_gap}) size: bar_width;
	//		draw "Health" color: #black at:  point({location.x - body_radius/2, location.y - body_radius - bar_gap}) font:font("Helvetica", 100/environment_size , #plain);
			
			point energy_bar_tl <- point({
				location.x - bar_length/2, 
				location.y - body_radius - 2*bar_width - 2*bar_gap
			});
			point energy_bar_br_full <- point({
				location.x + bar_length/2, 
				location.y - body_radius - bar_width - 2*bar_gap
			});
			point energy_bar_br <- point({
				location.x - bar_length/2 + (energy/energy_max)*bar_length, 
				location.y - body_radius - bar_width - 2*bar_gap
			});
			// Full Health Bar
			draw rectangle(energy_bar_tl, energy_bar_br_full) border: #black wireframe: true;
			// Health Bar
			draw rectangle(energy_bar_tl, energy_bar_br) color: #green;
			image_file energy_icon <- image_file("../includes/energy_icon.png");
			draw energy_icon at:  point({location.x, location.y - body_radius - 3/2*bar_width - 2*bar_gap}) size: bar_width;
	//		draw "Energy" color: #black at:  point({location.x - body_radius/2, location.y - body_radius - bar_width - 2*bar_gap}) font:font("Helvetica", 1 , #plain);		
		}
	} 
}

species prey parent: animal {
	
	bool man_freeze <- false;
	bool freeze update: prey_freeze or man_freeze;
	
	// Body
	float body_radius <- default_body_radius;
		// Color
	int color_r <- 0 min: 0 max: 255;
	int color_g <- 0 min: 0 max: 255;
	int color_b <- 255 min: 0 max: 255;
	
	// Life Stats
	float ad_ratio <- prey_ad_ratio min: 0.0 max: 1.0;
//	float ad_discount_factor <- prey_discount_factor;
	string enemy_species <- 'predator';	
	
	// Reproduction
	float reproduction_v update: reproduction_v + 1.0;
	
    float energy_resting_capacity;
            
	action species_specific_init {
		energy_resting_capacity <- energy_resting_ratio * energy_max; // energy_max
		reproduction_m <- reproduction_w_prey; // * body_radius
		ad_total <- health_max * ad_health_ratio * prey_ad_discount_factor;
		
		energy <- energy_max/2;
	}
	
	action species_specific_survive {	
    	if energy <= 0.0 {
    		exhausted <- true;
    	}
    	
    	if suffocation_b and local_p_density < suffocating_ratio {
			nb_suffocated <- nb_suffocated + 1;
    		do die;
    	}
    }
	
	action resting {
		if exhausted {
    		speed <- 0.0;
    		heading_delta <- 0.0;
    		reproduction_v <- reproduction_v - 1.0;
    	}
		
		// Simulates Grazing
    	energy <- energy + (energy_resting_capacity / (1 + length(neighbors_at(self, body_radius*population_density_radius))));
    	
		if energy >= (energy_max / 2) {
			exhausted <- false;
		}
		
	}
}

species predator parent: animal {
	
	bool man_freeze <- false;
	bool freeze update: predator_freeze or man_freeze;

	// Body
	float body_radius <- default_body_radius;
		// Color
	int color_r <- 255 min: 0 max: 255;
	int color_g <- 0 min: 0 max: 255;
	int color_b <- 0 min: 0 max: 255;
	
	// Life Stats
	float ad_ratio <- predator_ad_ratio min: 0.0 max: 1.0;
//	float ad_discount_factor <- 1.0;
	string enemy_species <- 'prey';
	
	// Reproduction
	
	float energy_digestion_capacity;
	float energy_to_digest <- 0.0;
		        
    action kill_target(animal a) {
    	kill_count <- kill_count + 1;
    	
    	energy_to_digest <- energy_to_digest + a.energy_max;
    	digesting <- true;
		reproduction_v <- reproduction_v + a.energy_max;
				
		ask a {
			do die;
		}
    }
    
    action species_specific_init {
		energy_digestion_capacity <- energy_digestion_ratio * energy_max;
		reproduction_m <- mass * reproduction_w_predator;
		ad_total <- health_max * ad_health_ratio;
		
//		energy <- energy_max / 2;
	}
   
   	action species_specific_survive {
   		if energy <= 0.0 {
    		do die;
    	}
   	} 
   	
   	action digest {
   		float current_digest_amount <- min(energy_digestion_capacity, energy_to_digest);
		energy <- energy + current_digest_amount;
		energy_to_digest <- energy_to_digest - current_digest_amount;
		
		if energy_to_digest <= 0.0 {
			digesting <- false;
		}
   	}
}


experiment Simulation_Testing type: gui benchmark: true {
	
    	// Environment Parameters
    parameter "Environment Size"  category:"Environment" var: environment_size min: 50 max: 1000 step: 50;
    parameter "Population per Square of 10"  category:"Environment" var: pop_per_10_square min: 0.1 max: 2.5 step: 0.1;
    parameter "Proportion of Predators"  category:"Environment" var: init_predator_prey_ratio min: 0.1 max: 0.9 step: 0.05 colors: [#red, #purple, #blue];
    parameter "Add Mountain"  category:"Environment" var: mountain_b colors: [#green, #grey];
	parameter "Mountain Shape" category:"Environment" var: mountain_range_shape  among: ["circle", "square", "line"];

    	// Recording Parameters
    parameter "Log Cycle Durations"  category:"Logging" var: record_duration colors: [#green, #grey];
	parameter "Log Agents" category:"Logging" var: log_agents colors: [#green, #grey];
		// Visualizing Parameters
    parameter "Health and Energy Bar"  category:"Visualizion" var: visualize_health_energy colors: [#green, #grey];
    parameter "Rays"  category:"Visualizion" var: visualize_rays colors: [#green, #grey];
    parameter "Simulation Metrics Refresh Rate"  category:"Visualizion" var: simulation_charts_refresh_count min: 5 max: 100 step: 5;
    parameter "Agent Behavior Metrics Refresh Rate"  category:"Visualizion" var: behavior_charts_refresh_count min: 5 max: 100 step: 5;
    parameter "Agent Evolution Metrics Refresh Rate"  category:"Visualizion" var: evolution_charts_refresh_count min: 5 max: 100 step: 5;
    parameter "Simulation Performance Metrics Refresh Rate"  category:"Visualizion" var: performance_charts_refresh_count min: 5 max: 100 step: 5;

		// Sensors Parameters
    parameter "Sensor Distance Range"  category:"Agent Default Sensors" var: default_sensor_distance_ratio min: 10.0 max: 50.0 step: 1.0;
    parameter "Sensor Angle Range"  category:"Agent Default Sensors" var: default_sensor_angle_range min: 60.0 max: 360.0 step: 10.0;
    parameter "Sensor Angle Precision"  category:"Agent Default Sensors" var: sensor_precision_ratio min: 0.5 max: 4.0 step: 0.25;
//    parameter "Sensor Step Precision"  category:"Agent Default Sensors" var: ray_dist_incr_ratio min: 0.1 max: 1.0 step: 0.05;

		// Energy Consumption Parameters
    parameter "Movement Energy Consumption Ratio"  category:"Agent Energy Consumption" var: energy_consumption_moving_w min: 0.005 max: 0.05 step: 0.005;
    parameter "Thinking to Moving Energy Consumption"  category:"Agent Energy Consumption" var: moving_to_thinking_ratio min: 1/10 max: 1/1 step: 1/10;
    parameter "Neurons Weight in Energy Consumption"  category:"Agent Energy Consumption" var: hn_w min: 1.0 max: 5.0 step: 0.5;
    parameter "Number of Rays Weight in Energy Consumption"  category:"Agent Energy Consumption" var: nr_w min: 1.0 max: 5.0 step: 0.5;
    parameter "Population Density Radius"  category:"Agent Energy Consumption" var: population_density_radius min: 1.0 max: 10.0 step: 0.5;

		// Agent Brain Parameters
    parameter "Number of Sensor Groups"  category:"Agent Brain" var: default_sensor_groups min: 2 max: 9 step: 1;
    parameter "Weight Values Distribution"  category:"Agent Brain" var: use_he_normal_weights labels:["He & Glorot Normal","Standard Normal"];
    parameter "Clip NN Weight Values"  category:"Agent Brain" var: clip_weights colors: [#green, #grey];
    parameter "Number of Starting Hidden Neurons"  category:"Agent Brain" var: default_n_hidden_neurons min: 0 max: 12 step: 1;
    parameter "Use Detected Agent Heading and Speed"  category:"Agent Brain" var: use_detected_info colors: [#green, #grey];
    parameter "Use NN Memory"  category:"Agent Brain" var: use_memory colors: [#green, #grey];

		// Agent Evolution Parameters
    parameter "Init Distribution std"  category:"Agent Evolution" var: init_std min: 0.1 max: 0.9 step: 0.1;
    parameter "Init Distribute Body Radius"  category:"Agent Evolution" var: br_init_b colors: [#green, #grey];
    parameter "Init Distribute Attack Defense"  category:"Agent Evolution" var: ad_init_b colors: [#green, #grey];
    parameter "Init Distribute Sensors"  category:"Agent Evolution" var: sensor_init_b colors: [#green, #grey];
    parameter "Init Distribute Hidden Neurons"  category:"Agent Evolution" var: hn_init_b colors: [#green, #grey];
    parameter "Evolution Decay"  category:"Agent Evolution" var: evolution_decay min: 0.5 max: 1.0 step: 0.01;
    parameter "Evolution Std"  category:"Agent Evolution" var: evolution_std min: 0.1 max: 0.9 step: 0.1;
    parameter "Evolve Body Radius"  category:"Agent Evolution" var: br_evolution_b colors: [#green, #grey];
    parameter "Evolve Attack Defense"  category:"Agent Evolution" var: ad_evolution_b colors: [#green, #grey];
    parameter "Evolve Sensors"  category:"Agent Evolution" var: sensor_evolution_b colors: [#green, #grey];
    parameter "Evolve Hidden Neurons"  category:"Agent Evolution" var: hn_evolution_b colors: [#green, #grey];
    parameter "Evolve NN Weights"  category:"Agent Evolution" var: w_evolution_b colors: [#green, #grey];


		// Species Behavior Parameters
    parameter "Attack-Defense Discount Ratio"  category:"Species Behavior" var: ad_health_ratio min: 0.2 max: 1.0 step: 0.05;
    parameter "Attack Rollover"  category:"Species Behavior" var: attack_rollover colors: [#green, #grey];
    parameter "Attack Forward Only"  category:"Species Behavior" var: attack_infront colors: [#green, #grey];
    
    parameter "Suffocation"  category:"Species Behavior" var: suffocation_b colors: [#green, #grey];
    parameter "Successful Attack Probability"  category:"Species Behavior" var: attack_success_p min: 0.5 max: 1.0 step: 0.05;

		// Species Specific Parameters
    parameter "Prey: Resting Energy Ratio"  category:"Species Specific" var: energy_resting_ratio min: 1/50 max: 1/2 step: 1/100;
    parameter "Prey: Attack Defense Ratio"  category:"Species Specific" var: prey_ad_ratio min: 0.0 max: 0.5 step: 1/20;
    parameter "Prey: Attack Defense Discount Ratio"  category:"Species Specific" var: prey_ad_discount_factor min: 0.0 max: 1.0 step: 1/20;
    parameter "Prey: Count to Reproduction"  category:"Species Specific" var: reproduction_w_prey min: 25.0 max: 200.0 step: 5.0;
    parameter "Predator: Digestion Ratio"  category:"Species Specific" var: energy_digestion_ratio min: 1/10 max: 1/1 step: 0.05;
    parameter "Predator: Reproduction Amount Ratio"  category:"Species Specific" var: reproduction_w_predator min: 1.0 max: 5.0 step: 0.5;
    parameter "Predator: Attack Defense Ratio"  category:"Species Specific" var: predator_ad_ratio min: 0.5 max: 1.0 step: 1/20;
	
		// Environment Perturbation
    parameter "Freeze Preys"  category:"Environment Perturbation" var: prey_freeze colors: [#green, #grey];
    parameter "Freeze Predators"  category:"Environment Perturbation" var: predator_freeze colors: [#green, #grey];


    output {
		monitor "Number Preys" value: nb_preys;
    	monitor "Number Predators" value: nb_predators;
    	monitor "Number of Rays" value: default_number_of_rays;
//    	monitor "Number of Calculations per Sensing" value: default_number_of_rays*default_sensor_distance_ratio*ray_dist_incr_ratio*default_body_radius*default_body_radius;

        display map_display autosave: 'Simulation_' + string(environment_size) + '_' + string(default_n_hidden_neurons) + '_cycle' + string(int(cycle / 100)*100) + '.png' { // # autosave: true
        	species mountain aspect: mountain_disp;
            species prey aspect: body;
            species prey aspect: health_energy_bar;
//            species prey aspect: sensors;
//            species prey aspect: active_sensors;
            species prey aspect: neuronal_sensors;
            species predator aspect: body;
            species predator aspect: health_energy_bar;
//            species predator aspect: sensors;
//            species predator aspect: active_sensors;
            species predator aspect: neuronal_sensors;
		}
				
			// Simulation Population Charts
		display Population_Evolution_General refresh: every(simulation_charts_refresh_count#cycles)  type: 2d {
			chart "Species Count Evolution" type: series size: {1, 0.67} position: {0, 0} {
				data "Prey" value: nb_preys color: #blue;
				data "Predator" value: nb_predators color: #red;
//				data "# Animals" value: nb_preys + nb_predators color: #black;
			}
			chart "Predator to Prey Ratio" type: series size: {1, 0.33} position: {0, 0.67} {
				data "" value: nb_predators / nb_preys color: #black;
			}
		}
		
//		display Population_Evolution_Generations refresh: every(simulation_charts_refresh_count#cycles)  type: 2d {
//	        chart "Distinct Family Branches" type: series size: {1, 0.5} position: {0.0, 0.0} {
//	            data "Prey" value: 1/length(prey group_by each.family) color: #blue;
//	            data "Predator" value: 1/length(predator group_by each.family) color: #red;
//	        }
//	        chart "Proportion of Gens" type: series size: {1, 0.5} position: {0.0, 0.5} {
//	            data "Prey 1-3" value: prey count (0 < each.gen_count and each.gen_count <= 3) / nb_preys color: #blue;
//	            data "Prey 4-10" value: prey count (3 < each.gen_count and each.gen_count <= 10) / nb_preys color: #lightblue;
//	            data "Prey 10<" value: prey count (10 < each.gen_count) / nb_preys color: #darkblue;
//	            data "Predator 1-3" value: predator count (0 < each.gen_count and each.gen_count <= 3) / nb_predators color: #red;
//	            data "Predator 4-10" value: predator count (3 < each.gen_count and each.gen_count <= 10) / nb_predators color: #orange;
//	            data "Predator 10<" value: predator count (10 < each.gen_count) / nb_predators color: #darkred;
//	        }
//		}
//		
//		display Energy_Info refresh: every(simulation_charts_refresh_count#cycles)  type: 2d {
//			chart "Prey Energy Distribution" type: histogram size: {0.5, 0.5} position: {0, 0} {
//				datalist (distribution_of(prey collect (each.energy / each.energy_max), 10, 0.0, 1.01) at "legend") 
//		    		value:(distribution_of(prey collect (each.energy / each.energy_max), 10, 0.0, 1.01) at "values")
//		    		color: [#black, #black, #black, #black, #black, #black, #black, #black, #black, #black, #black];
//		    }
//			chart "Predator Energy Distribution" type: histogram size: {0.5, 0.5} position: {0.5, 0} {
//				datalist (distribution_of(predator collect (each.energy / each.energy_max), 10, 0.0, 1.01) at "legend") 
//		    		value:(distribution_of(predator collect (each.energy / each.energy_max), 10, 0.0, 1.01) at "values")
//		    		color: [#black, #black, #black, #black, #black, #black, #black, #black, #black, #black];
//		    }
//			chart "Energy Percentage Prey" type: box_whisker size: {0.5, 0.5} position: {0, 0.5} series_label_position:yaxis {
//				data "prey" 
//					value: [
//						mean(collect(prey, (each.energy / each.energy_max))),
//						median(collect(prey, (each.energy / each.energy_max))),
//		   				quantile((prey sort_by (each.energy / each.energy_max)) collect (each.energy / each.energy_max), 0.25),
//		   				quantile((prey sort_by (each.energy / each.energy_max)) collect (each.energy / each.energy_max), 0.75),
//		   				min(prey collect (each.energy / each.energy_max)),
//		   				max(prey collect (each.energy / each.energy_max))
//		   			]
//					color: #red
//					accumulate_values: true;
//			}
//			chart "Energy Percentage Predator" type: box_whisker size: {0.5, 0.5} position: {0.5, 0.5} series_label_position:yaxis {
//				data "Predator" 
//					value: [
//						mean(collect(predator, (each.energy / each.energy_max))),
//						median(collect(predator, (each.energy / each.energy_max))),
//		   				quantile((predator sort_by (each.energy / each.energy_max)) collect (each.energy / each.energy_max), 0.25),
//		   				quantile((predator sort_by (each.energy / each.energy_max)) collect (each.energy / each.energy_max), 0.75),
//		   				min(predator collect (each.energy / each.energy_max)),
//		   				max(predator collect (each.energy / each.energy_max))
//		   			]
//					color: #red
//					accumulate_values: true;
//			}
//		}
//		display Health_Info refresh: every(2#cycles)  type: 2d {
//			chart "Prey Health Distribution" type: histogram {
//				datalist (distribution_of(prey collect (each.health / each.health_max), 10, 0.0, 1.01) at "legend")
//		    		value:(distribution_of(prey collect (each.health / each.health_max), 10, 0.0, 1.01) at "values")
//		    		color: [#black, #black, #black, #black, #black, #black, #black, #black, #black, #black];
//		    }
//		    
//			chart "Predator Health Distribution" type: histogram {
//				datalist (distribution_of(predator collect (each.health / each.health_max), 10, 0.0, 1.01) at "legend") 
//		    		value:(distribution_of(predator collect (each.health / each.health_max), 10, 0.0, 1.01) at "values")
//		    		color: [#black, #black, #black, #black, #black, #black, #black, #black, #black, #black];	
//		    }
//		}		
//		display Reproduction_Info refresh: every(simulation_charts_refresh_count#cycles)  type: 2d {
//	        chart "Average Offspring Count" type: series size: {1, 0.33} position: {0.0, 0.0} {
//	            data "Prey" value: mean(prey collect each.offspring_count) color: #blue;
//	            data "Predator" value: mean(predator collect each.offspring_count) color: #red;
//	        }
//
//			chart "Reproduction Percentage Prey" type: box_whisker size: {1, 0.33} position: {0, 0.33} series_label_position:yaxis {
//				data "Prey" 
//					value: [
//						mean(collect(prey, (each.reproduction_v / each.reproduction_m))),
//						median(collect(prey, (each.reproduction_v / each.reproduction_m))),
//		   				quantile((prey sort_by (each.reproduction_v / each.reproduction_m)) collect (each.reproduction_v / each.reproduction_m), 0.25),
//		   				quantile((prey sort_by (each.reproduction_v / each.reproduction_m)) collect (each.reproduction_v / each.reproduction_m), 0.75),
//		   				min(prey collect (each.reproduction_v / each.reproduction_m)),
//		   				max(prey collect (each.reproduction_v / each.reproduction_m))
//		   			]
//					color: #blue
//					accumulate_values: true;
//			}
//			chart "Reproduction Percentage Predator" type: box_whisker size: {1, 0.33} position: {0, 0.67} series_label_position:yaxis {
//				data "Predator" 
//					value: [
//						mean(collect(predator, (each.reproduction_v / each.reproduction_m))),
//						median(collect(predator, (each.reproduction_v / each.reproduction_m))),
//		   				quantile((predator sort_by (each.reproduction_v / each.reproduction_m)) collect (each.reproduction_v / each.reproduction_m), 0.25),
//		   				quantile((predator sort_by (each.reproduction_v / each.reproduction_m)) collect (each.reproduction_v / each.reproduction_m), 0.75),
//		   				min(predator collect (each.reproduction_v / each.reproduction_m)),
//		   				max(predator collect (each.reproduction_v / each.reproduction_m))
//		   			]
//					color: #red
//					accumulate_values: true;
//			}
//		}	
		
			// Agent Behavior Charts
//		display Agent_Info_Evolution refresh: every(behavior_charts_refresh_count#cycles)  type: 2d {
//			chart "Prey Age" type: box_whisker size: {0.5, 0.33} position: {0.0, 0.0} series_label_position:yaxis {
//				data "Prey" 
//					value: [
//						mean(collect(prey, each.age_count)),
//						median(collect(prey, each.age_count)),
//		   				quantile((prey sort_by each.age_count) collect each.age_count, 0.25),
//		   				quantile((prey sort_by each.age_count)collect each.age_count, 0.75),
//						quantile((prey sort_by each.age_count) collect each.age_count, 0.05),
////		   				min(collect(prey, each.age_count)),
//						quantile((prey sort_by each.age_count) collect each.age_count, 0.95)
////		   				max(collect(prey, each.age_count))
//		   			]
//					color: #blue
//					accumulate_values: true;
//			}
//			chart "Predator Age" type: box_whisker size: {0.5, 0.33} position: {0.0, 0.33} series_label_position:yaxis {
//				data "Predator" 
//					value: [
//						mean(collect(predator, each.age_count)),
//						median(collect(predator, each.age_count)),
//		   				quantile((predator sort_by each.age_count) collect each.age_count, 0.25),
//		   				quantile((predator sort_by each.age_count)collect each.age_count, 0.75),
//						quantile((predator sort_by each.age_count) collect each.age_count, 0.05),
////		   				min(collect(predator, each.age_count)),
//						quantile((predator sort_by each.age_count) collect each.age_count, 0.95)
////		   				max(collect(predator, each.age_count))
//		   			]
//					color: #red
//					accumulate_values: true;
//			}
//			
//			chart "Prey Enemy Seen Count" type: box_whisker size: {0.5, 0.33} position: {0.5, 0.0} series_label_position:yaxis {
//				data "Prey" 
//					value: [
//						mean(collect(prey, each.count_last_seen_enemy)),
//						median(collect(prey, each.count_last_seen_enemy)),
//		   				quantile((prey sort_by each.count_last_seen_enemy) collect each.count_last_seen_enemy, 0.25),
//		   				quantile((prey sort_by each.count_last_seen_enemy)collect each.count_last_seen_enemy, 0.75),
//		   				min(collect(prey, each.count_last_seen_enemy)),
//		   				max(collect(prey, each.count_last_seen_enemy))
//		   			]
//					color: #blue
//					accumulate_values: true;
//			}
//			chart "Predator Enemy Seen Count" type: box_whisker size: {0.5, 0.33} position: {0.5, 0.33} series_label_position:yaxis {
//				data "Predator" 
//					value: [
//						mean(collect(predator, each.count_last_seen_enemy)),
//						median(collect(predator, each.count_last_seen_enemy)),
//		   				quantile((predator sort_by each.count_last_seen_enemy) collect each.count_last_seen_enemy, 0.25),
//		   				quantile((predator sort_by each.count_last_seen_enemy)collect each.count_last_seen_enemy, 0.75),
//		   				min(collect(predator, each.count_last_seen_enemy)),
//		   				max(collect(predator, each.count_last_seen_enemy))
//		   			]
//					color: #red
//					accumulate_values: true;
//			}
//			chart "Attacked" type: series size: {0.5, 0.33} position: {0.0, 0.67} {
//				data "Prey" value: mean(collect(prey, int(each.attacked))) color: #blue;
//				data "Predator" value: mean(collect(predator, int(each.attacked))) color: #red;
//			}
//			chart "Resting" type: series size: {0.5, 0.33} position: {0.5, 0.67} {
//				data "Prey" value: mean(collect(prey, int(each.exhausted))) color: #blue;
//				data "Predator" value: mean(collect(predator, int(each.digesting))) color: #red;
//			}
//		}
//		
//		display Agent_Spatial_Evolution refresh: every(behavior_charts_refresh_count#cycles)  type: 2d {
//			chart "Distance Covered" type: series size: {0.5, 0.5} position: {0, 0} {
//				data "Average Prey" value: mean(collect(prey, each.dist_covered)) color: #blue;
//				data "Max Prey" value: max(collect(prey, each.dist_covered)) color: #lightblue;
//				data "Average Predator" value: mean(collect(predator, each.dist_covered)) color: #red;
//				data "Max Predator" value: max(collect(predator, each.dist_covered)) color: #darkred;
//			}
//			chart "Area Covered Relative to Environment" type: series size: {0.5, 0.5} position: {0, 0.5} {
//				data "Average Prey" value: mean(collect(prey, ((each.loc_x_max-each.loc_x_min)*(each.loc_y_max-each.loc_y_min))/(environment_size^2))) color: #blue;
////				data "Max Prey" value: max(collect(prey, (each.loc_x_max-each.loc_x_min)*(each.loc_y_max-each.loc_y_min))) color: #lightblue;
//				data "Average Predator" value: mean(collect(predator, ((each.loc_x_max-each.loc_x_min)*(each.loc_y_max-each.loc_y_min))/(environment_size^2))) color: #red;
////				data "Max Predator" value: max(collect(predator, (each.loc_x_max-each.loc_x_min)*(each.loc_y_max-each.loc_y_min))) color: #darkred;
//			}
//			chart "Area Covered" type: series size: {0.5, 0.5} position: {0.5, 0} {
//				data "Average Prey" value: mean(collect(prey, (each.loc_x_max-each.loc_x_min)*(each.loc_y_max-each.loc_y_min))) color: #blue;
////				data "Max Prey" value: max(collect(prey, (each.loc_x_max-each.loc_x_min)*(each.loc_y_max-each.loc_y_min))) color: #lightblue;
//				data "Average Predator" value: mean(collect(predator, (each.loc_x_max-each.loc_x_min)*(each.loc_y_max-each.loc_y_min))) color: #red;
////				data "Max Predator" value: max(collect(predator, (each.loc_x_max-each.loc_x_min)*(each.loc_y_max-each.loc_y_min))) color: #darkred;
//			}
//			chart "Area Covered Per Distance" type: series size: {0.5, 0.5} position: {0.5, 0.5} {
//				data "Average Prey" value: mean(collect(prey, (each.loc_x_max-each.loc_x_min)*(each.loc_y_max-each.loc_y_min) / max(1.0, each.dist_covered))) color: #blue;
//				data "Max Prey" value: max(collect(prey, (each.loc_x_max-each.loc_x_min)*(each.loc_y_max-each.loc_y_min) / max(1.0, each.dist_covered))) color: #lightblue;
//				data "Average Predator" value: mean(collect(predator, (each.loc_x_max-each.loc_x_min)*(each.loc_y_max-each.loc_y_min) / max(1.0, each.dist_covered))) color: #red;
//				data "Max Predator" value: max(collect(predator, (each.loc_x_max-each.loc_x_min)*(each.loc_y_max-each.loc_y_min) / max(1.0, each.dist_covered))) color: #darkred;
//			}
//		}
//	
		display Movement_Evolution refresh: every(behavior_charts_refresh_count#cycles)  type: 2d {
			chart "Speed Prey" type: box_whisker size: {0.5, 0.5} position: {0.0, 0.0} series_label_position:yaxis {
				data "Prey" 
					value: [
						mean(collect(prey where !each.exhausted, each.speed)),
						median(collect(prey where !each.exhausted, each.speed)),
		   				quantile((prey where !each.exhausted sort_by each.speed) collect each.speed, 0.25),
		   				quantile((prey where !each.exhausted sort_by each.speed)collect each.speed, 0.75),
		   				min(collect(prey where !each.exhausted, each.speed)),
		   				max(collect(prey where !each.exhausted, each.speed))
		   			]
					color: #blue
					accumulate_values: true;
			}
			chart "Speed Predator" type: box_whisker size: {0.5, 0.5} position: {0.0, 0.5} series_label_position:yaxis {
				data "Predator" 
					value: [
						mean(collect(predator where !each.digesting, each.speed)),
						median(collect(predator where !each.digesting, each.speed)),
		   				quantile((predator where !each.digesting sort_by each.speed) collect each.speed, 0.25),
		   				quantile((predator where !each.digesting sort_by each.speed)collect each.speed, 0.75),
		   				min(predator where !each.digesting collect each.speed),
		   				max(predator where !each.digesting collect each.speed)
		   			]
					color: #red
					accumulate_values: true;
			}
			
			chart "Delta Heading Prey" type: box_whisker size: {0.5, 0.5} position: {0.5, 0.0} series_label_position:yaxis {
				data "Prey" 
					value: [
						mean(collect(prey where !each.exhausted, abs(each.heading_delta))),
						median(collect(prey where !each.exhausted, abs(each.heading_delta))),
		   				quantile((prey where !each.exhausted sort_by abs(each.heading_delta)) collect abs(each.heading_delta), 0.25),
		   				quantile((prey where !each.exhausted sort_by abs(each.heading_delta)) collect abs(each.heading_delta), 0.75),
		   				min(collect(prey where !each.exhausted, abs(each.heading_delta))),
		   				max(collect(prey where !each.exhausted, abs(each.heading_delta)))
		   			]
					color: #blue
					accumulate_values: true;
			}
			chart "Delta Heading Predator" type: box_whisker size: {0.5, 0.5} position: {0.5, 0.5} series_label_position:yaxis {
				data "Predator" 
					value: [
						mean(collect(predator where !each.digesting, abs(each.heading_delta))),
						median(collect(predator where !each.digesting, abs(each.heading_delta))),
		   				quantile((predator where !each.digesting sort_by abs(each.heading_delta)) collect abs(each.heading_delta), 0.25),
		   				quantile((predator where !each.digesting sort_by abs(each.heading_delta)) collect abs(each.heading_delta), 0.75),
		   				min(predator where !each.digesting collect abs(each.heading_delta)),
		   				max(predator where !each.digesting collect abs(each.heading_delta))
		   			]
					color: #red
					accumulate_values: true;
			}
		}
		
//		display Species_Behavior_Evolution refresh: every(behavior_charts_refresh_count#cycles)  type: 2d {
//			chart "Kills per Age" type: series size: {1.0, 0.33} position: {0.0, 0.0} series_label_position:yaxis {
//				data "Prey" value: (sum(collect(prey, each.kill_count)) / sum(collect(prey, max(1, each.age_count)))) color: #blue;
//				data "Predator" value: (sum(collect(predator, each.kill_count)) / sum(collect(predator, max(1, each.age_count)))) color: #red;
//			}
//	        chart "Enemies in Range" type: series size: {1, 0.33} position: {0.0, 0.33} {
//	            data "Prey" value: mean(collect(prey, length(each.enemy_in_range))) color: #blue;
//	            data "Predator" value: mean(collect(predator, length(each.enemy_in_range))) color: #red;
//	        }
//			chart "Local Population Density" type: series size: {1, 0.33} position: {0.0, 0.67} {
//				data "Prey" value: mean(collect(prey, (each.local_p_density))) color: #blue;
//				data "Predator" value: mean(collect(predator, (each.local_p_density))) color: #red;
//			}
//		}
		
		display Agent_Reaction_Evolution refresh: every(behavior_charts_refresh_count#cycles)  type: 2d {
			chart "Prey Angle Calibration Overall" type: box_whisker size: {0.5, 0.33} position: {0, 0} series_label_position:yaxis {
				data "Prey" 
					value: [
						mean(collect(prey where each.closest_sensed_enemy, abs(each.closest_sensed_angle - each.heading_delta))),
						median(collect(prey where each.closest_sensed_enemy, abs(each.closest_sensed_angle - each.heading_delta))),
		   				quantile((prey where each.closest_sensed_enemy sort_by abs(each.closest_sensed_angle - each.heading_delta)) collect abs(each.closest_sensed_angle - each.heading_delta), 0.25),
		   				quantile((prey where each.closest_sensed_enemy sort_by abs(each.closest_sensed_angle - each.heading_delta)) collect abs(each.closest_sensed_angle - each.heading_delta), 0.75),
		   				min(collect(prey where each.closest_sensed_enemy, abs(each.closest_sensed_angle - each.heading_delta))),
		   				max(collect(prey where each.closest_sensed_enemy, abs(each.closest_sensed_angle - each.heading_delta)))
		   			]
					color: #blue
					accumulate_values: true;
			}
			chart "Predator Angle Calibration Overall" type: box_whisker size: {0.5, 0.33} position: {0.5, 0} series_label_position:yaxis {
				data "Predator" 
					value: [
						mean(collect(predator where each.closest_sensed_enemy, abs(each.closest_sensed_angle - each.heading_delta))),
						median(collect(predator where each.closest_sensed_enemy, abs(each.closest_sensed_angle - each.heading_delta))),
		   				quantile((predator where each.closest_sensed_enemy sort_by abs(each.closest_sensed_angle - each.heading_delta)) collect abs(each.closest_sensed_angle - each.heading_delta), 0.25),
		   				quantile((predator where each.closest_sensed_enemy sort_by (each.closest_sensed_angle - each.heading_delta)) collect abs(each.closest_sensed_angle - each.heading_delta), 0.75),
		   				min(collect(predator where each.closest_sensed_enemy, abs(each.closest_sensed_angle - each.heading_delta))),
		   				max(collect(predator where each.closest_sensed_enemy, abs(each.closest_sensed_angle - each.heading_delta)))
		   			]
					color: #red
					accumulate_values: true;
			}
			chart "Prey Angle Calibration Close" type: box_whisker size: {0.5, 0.33} position: {0, 0.33} series_label_position:yaxis {
				data "Prey" 
					value: [
						mean(collect(prey where (each.closest_sensed_enemy and (each.closest_sensed_dist <  each.sensor_angle_range/2)), abs(each.closest_sensed_angle - each.heading_delta))),
						median(collect(prey where (each.closest_sensed_enemy and (each.closest_sensed_dist <  each.sensor_angle_range/2)), abs(each.closest_sensed_angle - each.heading_delta))),
		   				quantile((prey where (each.closest_sensed_enemy and (each.closest_sensed_dist <  each.sensor_angle_range/2)) sort_by abs(each.closest_sensed_angle - each.heading_delta)) collect abs(each.closest_sensed_angle - each.heading_delta), 0.25),
		   				quantile((prey where (each.closest_sensed_enemy and (each.closest_sensed_dist <  each.sensor_angle_range/2)) sort_by abs(each.closest_sensed_angle - each.heading_delta)) collect abs(each.closest_sensed_angle - each.heading_delta), 0.75),
		   				min(collect(prey where (each.closest_sensed_enemy and (each.closest_sensed_dist <  each.sensor_angle_range/2)), abs(each.closest_sensed_angle - each.heading_delta))),
		   				max(collect(prey where (each.closest_sensed_enemy and (each.closest_sensed_dist <  each.sensor_angle_range/2)), abs(each.closest_sensed_angle - each.heading_delta)))
		   			]
					color: #blue
					accumulate_values: true;
			}
			chart "Predator Angle Calibration Close" type: box_whisker size: {0.5, 0.33} position: {0.5, 0.33} series_label_position:yaxis {
				data "Predator" 
					value: [
						mean(collect(predator where (each.closest_sensed_enemy and (each.closest_sensed_dist < each.sensor_angle_range/2) and (abs(each.closest_sensed_angle) > 10.0)), abs(each.closest_sensed_angle - each.heading_delta))),
						median(collect(predator where (each.closest_sensed_enemy and (each.closest_sensed_dist < each.sensor_angle_range/2) and (abs(each.closest_sensed_angle) > 10.0)), abs(each.closest_sensed_angle - each.heading_delta))),
		   				quantile((predator where (each.closest_sensed_enemy and (each.closest_sensed_dist < each.sensor_angle_range/2) and (abs(each.closest_sensed_angle) > 10.0)) sort_by abs(each.closest_sensed_angle - each.heading_delta)) collect abs(each.closest_sensed_angle - each.heading_delta), 0.25),
		   				quantile((predator where (each.closest_sensed_enemy and (each.closest_sensed_dist < each.sensor_angle_range/2) and (abs(each.closest_sensed_angle) > 10.0)) sort_by abs(each.closest_sensed_angle - each.heading_delta)) collect abs(each.closest_sensed_angle - each.heading_delta), 0.75),
		   				min(collect(predator where (each.closest_sensed_enemy and (each.closest_sensed_dist < each.sensor_angle_range/2) and (abs(each.closest_sensed_angle) > 10.0)), abs(each.closest_sensed_angle - each.heading_delta))),
		   				max(collect(predator where (each.closest_sensed_enemy and (each.closest_sensed_dist < each.sensor_angle_range/2) and (abs(each.closest_sensed_angle) > 10.0)), abs(each.closest_sensed_angle - each.heading_delta)))
		   			]
					color: #red
					accumulate_values: true;
			}		
			chart "Prey Angle Calibration Relative" type: box_whisker size: {0.5, 0.33} position: {0, 0.67} series_label_position:yaxis  y_range:{0.0, 4.0} {
				data "Prey" 
					value: [
						mean(collect(prey where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 10.0)), (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)))),
						median(collect(prey where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 10.0)), (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)))),
		   				quantile((prey where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 10.0)) sort_by (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle))) collect (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)), 0.25),
		   				quantile((prey where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 10.0)) sort_by (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle))) collect (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)), 0.75),
		   				min(collect(prey where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 10.0)), (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)))),
		   				max(collect(prey where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 10.0)), (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle))))
		   			]
					color: #blue
					accumulate_values: true;
			}
			chart "Predator Angle Calibration Relative" type: box_whisker size: {0.5, 0.33} position: {0.5, 0.67} series_label_position:yaxis y_range: {0.0, 2.0} {
				data "Predator"
					value: [
						mean(collect(predator where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 15.0)), (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)))),
						median(collect(predator where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 15.0)), (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)))),
		   				quantile((predator where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 15.0)) sort_by (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle))) collect (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)), 0.25),
		   				quantile((predator where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 15.0)) sort_by (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle))) collect (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)), 0.75),
		   				min(collect(predator where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 15.0)), (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle)))),
		   				max(collect(predator where (each.closest_sensed_enemy and (abs(each.closest_sensed_angle) > 15.0)), (abs(each.heading_delta - each.closest_sensed_angle) / abs(each.closest_sensed_angle))))
		   			]
					color: #red
					accumulate_values: true;
			}	
		}	

//		display Movement_Delta_Evolution refresh: every(10#cycles)  type: 2d {
//			chart "Speed Delta Prey" type: box_whisker size: {0.5, 0.5} position: {0.0, 0.0} series_label_position:yaxis {
//				data "Prey" 
//					value: [
//						mean(collect(prey, abs(each.speed_delta))),
//						median(collect(prey, abs(each.speed_delta))),
//		   				quantile((prey sort_by abs(each.speed_delta)) collect abs(each.speed_delta), 0.25),
//		   				quantile((prey sort_by abs(each.speed_delta)) collect abs(each.speed_delta), 0.75),
//		   				min(collect(prey, abs(each.speed_delta))),
//		   				max(collect(prey, abs(each.speed_delta)))
//		   			]
//					color: #blue
//					accumulate_values: true;
//			}
//			chart "Speed Delta Predator" type: box_whisker size: {0.5, 0.5} position: {0.0, 0.5} series_label_position:yaxis {
//				data "Predator" 
//					value: [
//						mean(collect(predator, abs(each.speed_delta))),
//						median(collect(predator, abs(each.speed_delta))),
//		   				quantile((predator sort_by abs(each.speed_delta)) collect abs(each.speed_delta), 0.25),
//		   				quantile((predator sort_by abs(each.speed_delta)) collect abs(each.speed_delta), 0.75),
//		   				min(predator collect abs(each.speed_delta)),
//		   				max(predator collect abs(each.speed_delta))
//		   			]
//					color: #red
//					accumulate_values: true;
//			}
//			
//			chart "Delta Heading Delta Prey" type: box_whisker size: {0.5, 0.5} position: {0.5, 0.0} series_label_position:yaxis {
//				data "Prey" 
//					value: [
//						mean(collect(prey, abs(each.heading_delta_delta))),
//						median(collect(prey, abs(each.heading_delta_delta))),
//		   				quantile((prey sort_by abs(each.heading_delta_delta)) collect abs(each.heading_delta_delta), 0.25),
//		   				quantile((prey sort_by abs(each.heading_delta_delta))collect abs(each.heading_delta_delta), 0.75),
//		   				min(collect(prey, abs(each.heading_delta_delta))),
//		   				max(collect(prey, abs(each.heading_delta_delta)))
//		   			]
//					color: #blue
//					accumulate_values: true;
//			}
//			chart "Delta Heading Delta Predator" type: box_whisker size: {0.5, 0.5} position: {0.5, 0.5} series_label_position:yaxis {
//				data "Predator" 
//					value: [
//						mean(collect(predator, abs(each.heading_delta_delta))),
//						median(collect(predator, abs(each.heading_delta_delta))),
//		   				quantile((predator sort_by abs(each.heading_delta_delta)) collect abs(each.heading_delta_delta), 0.25),
//		   				quantile((predator sort_by abs(each.heading_delta_delta))collect abs(each.heading_delta_delta), 0.75),
//		   				min(predator collect abs(each.heading_delta_delta)),
//		   				max(predator collect abs(each.heading_delta_delta))
//		   			]
//					color: #red
//					accumulate_values: true;
//			}
//		}
//			
//		display Energy_Consumption_Evolution refresh: every(behavior_charts_refresh_count#cycles)  type: 2d {
//			chart "Energy Consumption Prey" type: box_whisker size: {0.5, 0.5} position: {0.0, 0.0} series_label_position:yaxis {
//				data "Prey" 
//					value: [
//						mean(collect(prey, each.energy_consumption)),
//						median(collect(prey, each.energy_consumption)),
//		   				quantile((prey sort_by each.energy_consumption) collect each.energy_consumption, 0.25),
//		   				quantile((prey sort_by each.energy_consumption)collect each.energy_consumption, 0.75),
//		   				min(collect(prey, each.energy_consumption)),
//		   				max(collect(prey, each.energy_consumption))
//		   			]
//					color: #blue
//					accumulate_values: true;
//			}
//			chart "Energy Consumption Predator" type: box_whisker size: {0.5, 0.5} position: {0, 0.5} series_label_position:yaxis {
//				data "Predator" 
//					value: [
//						mean(collect(predator, each.energy_consumption)),
//						median(collect(predator, each.energy_consumption)),
//		   				quantile((predator sort_by each.energy_consumption) collect each.energy_consumption, 0.25),
//		   				quantile((predator sort_by each.energy_consumption)collect each.energy_consumption, 0.75),
//		   				min(predator collect each.energy_consumption),
//		   				max(predator collect each.energy_consumption)
//		   			]
//					color: #red
//					accumulate_values: true;
//			}
//
//			chart "Energy Consumption Rate Prey" type: box_whisker size: {0.5, 0.5} position: {0.5, 0.0} series_label_position:yaxis {
//				data "Prey" 
//					value: [
//						mean(collect(prey, each.energy_consumption / each.energy_max)),
//						median(collect(prey, each.energy_consumption / each.energy_max)),
//		   				quantile((prey sort_by (each.energy_consumption / each.energy_max)) collect (each.energy_consumption / each.energy_max), 0.25),
//		   				quantile((prey sort_by (each.energy_consumption / each.energy_max)) collect (each.energy_consumption / each.energy_max), 0.75),
//		   				min(collect(prey, (each.energy_consumption / each.energy_max))),
//		   				max(collect(prey, (each.energy_consumption / each.energy_max)))
//		   			]
//					color: #blue
//					accumulate_values: true;
//			}
//			chart "Energy Consumption Rate Predator" type: box_whisker size: {0.5, 0.5} position: {0.5, 0.5} series_label_position:yaxis {
//				data "Predator" 
//					value: [
//						mean(collect(predator, (each.energy_consumption / each.energy_max))),
//						median(collect(predator, (each.energy_consumption / each.energy_max))),
//		   				quantile((predator sort_by (each.energy_consumption / each.energy_max)) collect (each.energy_consumption / each.energy_max), 0.25),
//		   				quantile((predator sort_by (each.energy_consumption / each.energy_max)) collect (each.energy_consumption / each.energy_max), 0.75),
//		   				min(predator collect (each.energy_consumption / each.energy_max)),
//		   				max(predator collect (each.energy_consumption / each.energy_max))
//		   			]
//					color: #red
//					accumulate_values: true;
//			}
//		}

			// Agent Parameters Evolution
//		display Body_Traits_Evolution refresh: every(evolution_charts_refresh_count#cycles)  type: 2d {
//			chart "Body Radius Prey" type: box_whisker size: {0.5,0.25} position: {0.0, 0.0} series_label_position:yaxis {
//				data "Prey" 
//					value: [
//						mean(collect(prey, each.body_radius)),
//						median(collect(prey, each.body_radius)),
//		   				quantile((prey sort_by each.body_radius) collect each.body_radius, 0.25),
//		   				quantile((prey sort_by each.body_radius)collect each.body_radius, 0.75),
//		   				min(collect(prey, each.body_radius)),
//		   				max(collect(prey, each.body_radius))
//		   			]
//					color: #blue
//					accumulate_values: true;
//			}
//			chart "Body Radius Predator" type: box_whisker size: {0.5,0.25} position: {0.5, 0.0} series_label_position:yaxis {
//				data "Predator" 
//					value: [
//						mean(collect(predator, each.body_radius)),
//						median(collect(predator, each.body_radius)),
//		   				quantile((predator sort_by each.body_radius) collect each.body_radius, 0.25),
//		   				quantile((predator sort_by each.body_radius)collect each.body_radius, 0.75),
//		   				min(predator collect each.body_radius),
//		   				max(predator collect each.body_radius)
//		   			]
//					color: #red
//					accumulate_values: true;
//			}
//
//			chart "Mass Prey" type: box_whisker size: {0.5, 0.25} position: {0, 0.25} series_label_position:yaxis {
//				data "Prey"
//					value: [
//						mean(collect(prey, each.mass)),
//						median(collect(prey, each.mass)),
//		   				quantile((prey sort_by each.mass) collect each.mass, 0.25),
//		   				quantile((prey sort_by each.mass)collect each.mass, 0.75),
//		   				min(collect(prey, each.mass)),
//		   				max(collect(prey, each.mass))
//		   			]
//					color: #blue
//					accumulate_values: true;
//			}
//			chart "Mass Predator" type: box_whisker size: {0.5, 0.25} position: {0.5, 0.25} series_label_position:yaxis {
//				data "Predator" 
//					value: [
//						mean(collect(predator, each.mass)),
//						median(collect(predator, each.mass)),
//		   				quantile((predator sort_by each.mass) collect each.mass, 0.25),
//		   				quantile((predator sort_by each.mass)collect each.mass, 0.75),
//		   				min(predator collect each.mass),
//		   				max(predator collect each.mass)
//		   			]
//					color: #red
//					accumulate_values: true;
//			}
//
//			
//			chart "Attack Prey" type: box_whisker size: {0.5, 0.25} position: {0, 0.5} series_label_position:yaxis {
//				data "Prey" 
//					value: [
//						mean(collect(prey, each.ad_attack)),
//						median(collect(prey, each.ad_attack)),
//		   				quantile((prey sort_by each.ad_attack) collect each.ad_attack, 0.25),
//		   				quantile((prey sort_by each.ad_attack)collect each.ad_attack, 0.75),
//		   				min(collect(prey, each.ad_attack)),
//		   				max(collect(prey, each.ad_attack))
//		   			]
//					color: #blue
//					accumulate_values: true;
//			}
//			chart "Attack Predator" type: box_whisker size: {0.5, 0.25} position: {0.5, 0.5} series_label_position:yaxis {
//				data "Predator" 
//					value: [
//						mean(collect(predator, each.ad_attack)),
//						median(collect(predator, each.ad_attack)),
//		   				quantile((predator sort_by each.ad_attack) collect each.ad_attack, 0.25),
//		   				quantile((predator sort_by each.ad_attack)collect each.ad_attack, 0.75),
//		   				min(predator collect each.ad_attack),
//		   				max(predator collect each.ad_attack)
//		   			]
//					color: #red
//					accumulate_values: true;
//			}
//			
//			chart "Defense Prey" type: box_whisker size: {0.5 ,0.25} position: {0, 0.75} series_label_position:yaxis {
//				data "Prey" 
//					value: [
//						mean(collect(prey, each.ad_defense)),
//						median(collect(prey, each.ad_defense)),
//		   				quantile((prey sort_by each.ad_defense) collect each.ad_defense, 0.25),
//		   				quantile((prey sort_by each.ad_defense)collect each.ad_defense, 0.75),
//		   				min(collect(prey, each.ad_defense)),
//		   				max(collect(prey, each.ad_defense))
//		   			]
//					color: #blue
//					accumulate_values: true;
//			}
//			chart "Defense Predator" type: box_whisker size: {0.5, 0.25} position: {0.5, 0.75} series_label_position:yaxis {
//				data "Predator" 
//					value: [
//						mean(collect(predator, each.ad_defense)),
//						median(collect(predator, each.ad_defense)),
//		   				quantile((predator sort_by each.ad_defense) collect each.ad_defense, 0.25),
//		   				quantile((predator sort_by each.ad_defense)collect each.ad_defense, 0.75),
//		   				min(predator collect each.ad_defense),
//		   				max(predator collect each.ad_defense)
//		   			]
//					color: #red
//					accumulate_values: true;
//			}
//		}
//		
//		display Sensor_Traits_Evolution refresh: every(evolution_charts_refresh_count#cycles)  type: 2d {
//			chart "Sensor Distance Range Prey" type: box_whisker size: {0.5,0.5} position: {0.0, 0.0} series_label_position:yaxis {
//				data "Prey" 
//					value: [
//						mean(collect(prey, each.sensor_distance_range)),
//						median(collect(prey, each.sensor_distance_range)),
//		   				quantile((prey sort_by each.sensor_distance_range) collect each.sensor_distance_range, 0.25),
//		   				quantile((prey sort_by each.sensor_distance_range)collect each.sensor_distance_range, 0.75),
//		   				min(collect(prey, each.sensor_distance_range)),
//		   				max(collect(prey, each.sensor_distance_range))
//		   			]
//					color: #blue
//					accumulate_values: true; 
//			}
//			chart "Sensor Distance Range Predator" type: box_whisker size: {0.5, 0.5} position: {0.0, 0.5} series_label_position:yaxis {
//				data "Predator" 
//					value: [
//						mean(collect(predator, each.sensor_distance_range)),
//						median(collect(predator, each.sensor_distance_range)),
//		   				quantile((predator sort_by each.sensor_distance_range) collect each.sensor_distance_range, 0.25),
//		   				quantile((predator sort_by each.sensor_distance_range)collect each.sensor_distance_range, 0.75),
//		   				min(predator collect each.sensor_distance_range),
//		   				max(predator collect each.sensor_distance_range)
//		   			]
//					color: #red
//					accumulate_values: true;
//			}
//			
//			chart "Sensor Angle Range Prey" type: box_whisker size: {0.5,0.5} position: {0.5, 0.0} series_label_position:yaxis y_range: {0.0, 360.0} {
//				data "Prey" 
//					value: [
//						mean(collect(prey, each.sensor_angle_range)),
//						median(collect(prey, each.sensor_angle_range)),
//		   				quantile((prey sort_by each.sensor_angle_range) collect each.sensor_angle_range, 0.25),
//		   				quantile((prey sort_by each.sensor_angle_range)collect each.sensor_angle_range, 0.75),
//		   				min(collect(prey, each.sensor_angle_range)),
//		   				max(collect(prey, each.sensor_angle_range))
//		   			]
//					color: #blue
//					accumulate_values: true;
//			}
//			chart "Sensor Angle Range Predator" type: box_whisker size: {0.5,0.5} position: {0.5, 0.5} series_label_position:yaxis y_range: {0.0, 360.0} {
//				data "Predator" 
//					value: [
//						mean(collect(predator, each.sensor_angle_range)),
//						median(collect(predator, each.sensor_angle_range)),
//		   				quantile((predator sort_by each.sensor_angle_range) collect each.sensor_angle_range, 0.25),
//		   				quantile((predator sort_by each.sensor_angle_range)collect each.sensor_angle_range, 0.75),
//		   				min(predator collect each.sensor_angle_range),
//		   				max(predator collect each.sensor_angle_range)
//		   			]
//					color: #red
//					accumulate_values: true;
//			}
//		}
//		
//					
//		display Brain_Traits_Evolution refresh: every(evolution_charts_(each.gen_count = 0)refresh_count#cycles)  type: 2d {
//			chart "# Hidden Neurons Prey" type: box_whisker size: {0.5, 0.5} position: {0.0, 0.0} series_label_position:yaxis {
//				data "Prey" 
//					value: [
//						mean(collect(prey, each.nn_n_hidden_neurons)),
//						median(collect(prey, each.nn_n_hidden_neurons)),
//		   				quantile((prey sort_by each.nn_n_hidden_neurons) collect each.nn_n_hidden_neurons, 0.25),
//		   				quantile((prey sort_by each.nn_n_hidden_neurons)collect each.nn_n_hidden_neurons, 0.75),
//		   				min(collect(prey, each.nn_n_hidden_neurons)),
//		   				max(collect(prey, each.nn_n_hidden_neurons))
//		   			]
//					color: #blue
//					accumulate_values: true;
//			}
//			chart "# Hidden Neurons Predator" type: box_whisker size: {0.5, 0.5} position: {0.0, 0.5} series_label_position:yaxis {
//				data "Predator" 
//					value: [
//						mean(collect(predator, each.nn_n_hidden_neurons)),
//						median(collect(predator, each.nn_n_hidden_neurons)),
//		   				quantile((predator sort_by each.nn_n_hidden_neurons) collect each.nn_n_hidden_neurons, 0.25),
//		   				quantile((predator sort_by each.nn_n_hidden_neurons)collect each.nn_n_hidden_neurons, 0.75),
//		   				min(predator collect each.nn_n_hidden_neurons),
//		   				max(predator collect each.nn_n_hidden_neurons)
//		   			]
//					color: #red
//					accumulate_values: true;
//			}
//			chart "# Rays Prey" type: box_whisker size: {0.5,0.5} position: {0.5, 0.0} series_label_position:yaxis {
//				data "Prey" 
//					value: [
//						mean(collect(prey, each.sensor_nb_of_rays)),
//						median(collect(prey, each.sensor_nb_of_rays)),
//		   				quantile((prey sort_by each.sensor_nb_of_rays) collect each.sensor_nb_of_rays, 0.25),
//		   				quantile((prey sort_by each.sensor_nb_of_rays)collect each.sensor_nb_of_rays, 0.75),
//		   				min(collect(prey, each.sensor_nb_of_rays)),
//		   				max(collect(prey, each.sensor_nb_of_rays))
//		   			]
//					color: #blue
//					accumulate_values: true;	 
//			}
//			
//			chart "# Rays Predator" type: box_whisker size: {0.5,0.5} position: {0.5, 0.5} series_label_position:yaxis {
//				data "Predator" 
//					value: [
//						mean(collect(predator, each.sensor_nb_of_rays)),
//						median(collect(predator, each.sensor_nb_of_rays)),
//		   				quantile((predator sort_by each.sensor_nb_of_rays) collect each.sensor_nb_of_rays, 0.25),
//		   				quantile((predator sort_by each.sensor_nb_of_rays)collect each.sensor_nb_of_rays, 0.75),
//		   				min(predator collect each.sensor_nb_of_rays),
//		   				max(predator collect each.sensor_nb_of_rays)
//		   			]
//					color: #red
//					accumulate_values: true;
//			}
//
//		}
//	
		display brain_prey_heading_delta  type: 2d { // refresh: every(evolution_charts_refresh_count#cycles)
			chart "Prey Heading Delta Reaction to Sensed Agent Type" type: heatmap x_serie_labels: l_detected_type_idx_short x_label: 'Agent Sensed for Sensor Group' y_label: 'Cycle'
			{
					data "Heading Delta" value: l_detected_type_prey_hd color: [# darkblue, # ghostwhite, # darkgreen] accumulate_values: false;
			}	
		}
		display brain_prey_speed  type: 2d { // refresh: every(evolution_charts_refresh_count#cycles)
			chart "Prey Speed Reaction to Sensed Agent Type" type: heatmap x_serie_labels: l_detected_type_idx_gen x_label: 'Agent Sensed for Sensor Group' y_label: 'Cycle'
			{
					data "Speed" value: l_detected_type_prey_sp color: [# skyblue, # darkblue] accumulate_values: false;
			}	
		}
		display brain_predator_heading_delta  type: 2d { // refresh: every(evolution_charts_refresh_count#cycles)
			chart "Predator Heading Delta Reaction to Sensed Agent Type" type: heatmap x_serie_labels: l_detected_type_idx_short x_label: 'Agent Sensed for Sensor Group' y_label: 'Cycle'
			{
					data "Heading Delta" value: l_detected_type_predator_hd color: [# darkblue, # ghostwhite, # darkgreen] accumulate_values: false;
			}
		}		
		display brain_predator_speed  type: 2d { // refresh: every(evolution_charts_refresh_count#cycles)
			chart "Predator Speed Reaction to Sensed Agent Type" type: heatmap x_serie_labels: l_detected_type_idx_gen x_label: 'Agent Sensed for Sensor Group' y_label: 'Cycle'
			{
					data "Speed" value: l_detected_type_predator_sp color: [# skyblue, # darkblue] accumulate_values: false;
			}
		}		
	}
}
