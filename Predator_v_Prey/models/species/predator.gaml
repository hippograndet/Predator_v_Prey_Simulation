/**
* Name: Predator
* Red agents. Hunt prey to absorb energy via a digestion buffer,
* and reproduce based on total prey energy consumed.
* Author: hippolytegrandet
*/

model Predator

species predator parent: animal {

    bool man_freeze <- false;
    bool freeze update: predator_freeze or man_freeze;

    // --- Body ---
    float body_radius <- default_body_radius;
    int color_r <- 255 min: 0 max: 255;
    int color_g <- 0 min: 0 max: 255;
    int color_b <- 0 min: 0 max: 255;

    // --- Combat ---
    float ad_ratio <- predator_ad_ratio min: 0.0 max: 1.0;
    string enemy_species <- 'prey';

    // --- Digestion ---
    float energy_digestion_capacity;
    float energy_to_digest <- 0.0;


    // Overrides animal.kill_target: stores prey energy in the digestion buffer.
    action kill_target(animal a) {
        kill_count <- kill_count + 1;
        energy_to_digest <- energy_to_digest + a.energy_max;
        digesting <- true;
        reproduction_v <- reproduction_v + a.energy_max;
        ask a { do die; }
    }

    action species_specific_init {
        energy_digestion_capacity <- energy_digestion_ratio * energy_max;
        reproduction_m <- mass * reproduction_w_predator;
        ad_total <- health_max * ad_health_ratio;
    }

    action species_specific_survive {
        if energy <= 0.0 {
            do die;
        }
    }

    // Absorbs a portion of digestion buffer into energy each cycle.
    action digest {
        float current_digest_amount <- min(energy_digestion_capacity, energy_to_digest);
        energy <- energy + current_digest_amount;
        energy_to_digest <- energy_to_digest - current_digest_amount;
        if energy_to_digest <= 0.0 {
            digesting <- false;
        }
    }
}
