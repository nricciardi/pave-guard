from sklearn.metrics import make_scorer
import numpy as np


def custom_scorer(estimator, X, y_true):

    y_pred = estimator.predict(X)

    error = np.mean(np.abs(y_pred - y_true))
    feature_importance = np.sum(np.abs(estimator.coef_))

    score = error + 0.1 * feature_importance

    return score


custom_scorer_func = make_scorer(custom_scorer, greater_is_better=False)


