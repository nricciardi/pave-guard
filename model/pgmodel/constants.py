from enum import Enum


class RawFeatureName(Enum):
    RAINFALL = "rainfall"
    TEMPERATURE = "temperature"
    HUMIDITY = "humidity"
    CRACK = "crack"
    POTHOLE = "pothole"
    TRANSIT_VELOCITY = "transit_velocity"
    TRANSIT_TIME = "transit_time"
    TRANSIT_LENGTH = "transit_length"



class FeatureName(Enum):
    SUBZERO_TEMPERATURE_MEAN = "subzero_temperature_mean"
    TEMPERATURE_MEAN = "temperature_mean"
    HUMIDITY_MEAN = "humidity_mean"
    RAINFALL_QUANTITY = "rainfall_quantity"
    STORM_TOTAL = "storm_total"
    DELTA_TEMPERATURE = "delta_temperature"
    HEAVY_VEHICLES_TRANSIT_TOTAL = "heavy_vehicles_transit_total"
    TRANSIT_TOTAL = "transit_total"
    TRANSIT_DURING_RAINFALL = "transit_during_rainfall"
    HEAVY_VEHICLES_TRANSIT_DURING_RAINFALL = "heavy_vehicles_transit_during_rainfall"
    DAYS = "days"
    POTHOLE_SEVERITY = "pothole_severity"
    CRACK_SEVERITY = "crack_severity"
    IS_RAINING = "is_raining"
    TARGET = "crack_final_severity"


class TargetName(Enum):
    POTHOLE_SEVERITY = "pothole_severity_target"
    CRACK_SEVERITY = "crack_severity_target"
    
    
    