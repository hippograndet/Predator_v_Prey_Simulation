/**
* Name: Prey
* Blue agents. Graze to recover energy, reproduce frequently,
* and are vulnerable to predators.
* Author: hippolytegrandet
*/

model Prey

import "animal.gaml"

species prey parent: animal {

    bool man_freeze <- false;
    bool freeze update: prey_freeze or man_freeze;

    // --- Body ---
    float body_radius <- default_body_radius;
    int color_r <- 0 min: 0 max: 255;
    int color_g <- 0 min: 0 max: 255;
    int color_b <- 255 min: 0 max: 255;

    // --- Combat ---
    float ad_ratio <- prey_ad_ratio min: 0.0 max: 1.0;
    string enemy_species <- 'predator';

    // --- Reproduction ---
    float reproduction_v update: reproduction_v + 1.0;

    float energy_resting_capacity;


    action species_specific_init {
        energy_resting_capacity <- energy_resting_ratio * energy_max;
        reproduction_m <- reproduction_w_prey;
        ad_total <- health_max * ad_health_ratio * prey_ad_discount_factor;
        energy <- energy_max / 2;
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

    // Grazing: recover energy when resting; clear exhaustion once half-full.
    action resting {
        if exhausted {
            speed <- 0.0;
            heading_delta <- 0.0;
            reproduction_v <- reproduction_v - 1.0;
        }
        energy <- energy + (energy_resting_capacity / (1 + length(neighbors_at(self, body_radius * population_density_radius))));
        if energy >= (energy_max / 2) {
            exhausted <- false;
        }
    }
}
