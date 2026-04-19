/**
* Name: NeuralNetworkMath
* Global math helpers for neural network operations:
* activation functions (scalar, list, matrix), weight initialisation,
* Gaussian sampling, and matrix manipulation utilities.
* Author: hippolytegrandet
*/

model NeuralNetworkMath

global {

    // --- Activation functions: scalar ---

    float sigmoid(float x) {
        return 1.0 / (1.0 + exp(-x));
    }

    float relu(float x) {
        return max(0.0, x);
    }

    // --- Activation functions: list ---

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

    // --- Activation functions: matrix (row-wise application) ---

    matrix<float> sigmoid_matrix(matrix<float> m) {
        list<list<float>> rows <- rows_list(m);
        matrix<float> mt <- matrix(list_sigmoid(rows[0]));
        if length(rows) > 1 {
            loop i from: 1 to: (length(rows) - 1) {
                mt <- mt append_vertically matrix(list_sigmoid(rows[i]));
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
        matrix<float> mt <- matrix(list_tanh(rows[0]));
        if length(rows) > 1 {
            loop i from: 1 to: (length(rows) - 1) {
                mt <- mt append_vertically matrix(list_tanh(rows[i]));
            }
        }
        return mt;
    }

    // --- Weight initialisation ---

    // Gaussian matrix with optional dropout and 3-sigma clipping (controlled by global flags).
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
            if flip(dropout_prob) { v <- 0.0; }
            if clip_weights { v <- min(max(v, -3 * std), 3 * std); }
            l <+ v;
        }
        return l;
    }

    // Adds Gaussian noise in-place to an existing weight matrix.
    matrix<float> add_noise_matrix(float std, matrix<float> m) {
        if m != nil {
            matrix<float> m_noise <- get_gauss_matrix(length(columns_list(m)), length(rows_list(m)), std);
            m <- m + m_noise;
        }
        return m;
    }

    // Removes n columns from each side of a matrix (used when shrinking sensor groups).
    matrix<float> remove_surrounding_n_columns(int n_remove, matrix<float> m) {
        list<list<float>> cols <- columns_list(m);
        matrix<float> new_m <- matrix(cols[n_remove]);
        loop i from: n_remove + 1 to: (length(cols) - n_remove - 1) {
            new_m <- new_m append_vertically matrix(cols[i]);
        }
        return transpose(new_m);
    }
}
