from sklearn.linear_model import LinearRegression, SGDRegressor
import numpy as np

class SGDWithDirectionPenalty(SGDRegressor):
    def __init__(self, penalty_factor=1.0, **kwargs):
        super().__init__(**kwargs)
        self.penalty_factor = penalty_factor

    def fit(self, X, y):
        # Assuming the first column is the initial value
        X_init = X[:, 0] if isinstance(X, np.ndarray) else X.iloc[:, 0].values

        # Compute sample weights (increase weight if direction is incorrect)
        direction_mask = (y - X_init) >= 0  # True if target should increase
        penalty = np.where(direction_mask & (y < X_init), self.penalty_factor, 1.0)

        # Train with adjusted weights
        return super().fit(X, y, sample_weight=penalty)
