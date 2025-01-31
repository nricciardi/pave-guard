# Pave Guard slides presentation

[formal greetings]

## Road maintenance as of now…

Now, road maintenance has two main problems that we must handle:

**Management**: It is not known in advance which roads will require maintenance in the near future. 
Typically, repairs are carried out only when the damage is severe, leading to higher costs and more extensive interventions.

**Planning**: After a major storm, it's not just a single prejudiced road that requires repaving, but many. 
As a result, maintenance takes a long time to complete—potentially leaving roads vulnerable when the next storm arrives.

**Delays**: Roads typically remain in poor condition for three to six months, leading to safety risks and vehicle damage. 
Additionally, prolonged maintenance periods result in dissatisfaction and inconvenience.

Difficulties in management and planning cause that 20% of interventions are *emergency interventions*, 
which have 190% extra cost.

## Our solution

We offer PaveGuard, which is a completely automatized, plug-and-play, cost-efficient, road maintenance planning system.

It continuously monitors road conditions, detects early signs of damage, and optimizes maintenance scheduling, reducing repair costs and delays.

By leveraging smart sensors and predictive analytics, PaveGuard helps to prioritize interventions efficiently, ensuring safer roads and minimizing unnecessary expenses.


## Resources

PaveGuard is composed by different components.

**StaticGuards** are fixed monitoring devices designed to continuously measure atmospheric conditions and traffic volume.

**DynamicGuards** are deployed monitoring devices able to capture the road status for assessing the pavement quality.

**Dashboard** allows managers to analyze future road status and to plan maintenances beforehand. 


## Advantages of PaveGuard

The advantages of PaveGuard are, first of all, very low production and installation costs.

In addiction, we must consider that PaveGuard system performs a fully-automated track of road conditions, reducing number of needed humans supervisors. 

Therefore, adopting PaveGuard we can save a lot of moneys also reducing emergency maintenances thanks to preventive maintenance.

Obviously, more maintenances imply safer roads, decreasing road accident risks. 


## Future plans

To improve capabilities of our system, we have planed to include a solar panel to make our devices energy-independent.

In addiction, given that currently we already track vehicles transits, we want to improve traffic analysis, in order to help maintenances scheduling.


## PaveGuard system: Overview

PaveGuard system, as already mentioned, is composed by many components.

StaticGuards and DynamicGuards use sensors to obtain telemetries from environment and exploit bridges to send them to backed over Internet.

Backend mainly performs two actions: receives telemetries from devices, storing them into database, and serves our clients.

Thanks to backend's API, the model and dashboard can get data. Model use data to perform predictions, dashboard visualizes them.


## StaticGuard

StaticGuard device is placed on a road lamp, in order to capture traffic telemetries from above. 

It uses a micro-controller and a set of sensors to collect information about:

- Temperature
- Humidity
- Rainfall
- Transits of its road 

These information are sent using its bridge to remote server.

Bridge is integrated into micro-controller and it allows to establish a Wi-Fi connection.

Information about environment will be used to provide some historical data for all nearby streets.


## DynamicGuard

TODO

## Backend

Backend is the component that stores and manages information of the entire system.
It is composed by more remote modules.

It stores information about users. There are two types of accounts:

- Administrators
- Citizens, that are common accounts

It creates digital representation of devices, acquiring and storing information about devices.
Each DynamicGuard is associated to citizen’s account.
StaticGuards don’t have a owner and administrators can see their information using the dashboard.

In addiction, it manages data produced by devices and provides their telemetries through API, in order to allow other components (e.g. the model) to use them.




## Dashboard

TODO

## Model

The Model is the game-changer component of our system.
It exploits information about environment and actual road conditions, acquired by devices, to make predictions about future state of the roads.

The model is able to improve its performances, processing new data incoming from devices continuously.

The model provides predictions about future state of the roads, in order to allow administrators to plan targeted interventions.




