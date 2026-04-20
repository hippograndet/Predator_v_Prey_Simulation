/**
* Name: Mountain
* Static terrain obstacle. Reduces agent speed, visibility, and health
* while agents are within its bounds.
* Author: hippolytegrandet
*/

model Mountain

import "../includes/parameters.gaml"

species mountain {

    init {
        if mountain_range_shape = 'circle' {
            shape <- circle(environment_size * 1/5);
        } else if mountain_range_shape = 'square' {
            shape <- square(environment_size * 1/5);
        } else if mountain_range_shape = 'line' {
            shape <- rectangle(environment_size * 1/10, environment_size * 1/2);
        } else {
            shape <- circle(environment_size * 1/5);
        }
        location <- point({environment_size / 2, environment_size / 2});
    }

    aspect mountain_disp {
        if mountain_b {
            draw shape color: #darkgrey;
        }
    }
}
