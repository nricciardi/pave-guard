from model.dataset.ind_generator import IndependentGenerator
import numpy as np


class UniformGenerator(IndependentGenerator):

    def generate_next_value(self, previous_value, **kwargs):
        return previous_value + np.random.uniform(-self.max_change, self.max_change)