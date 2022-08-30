# On-demand Energy-efficient Localization in Wireless Sensor Networks using Sink-Path approach

![alt text](https://github.com/sameerkhule1/localizationApplication/blob/main/matlabSorceCode/imageMatlabApplication.png)

# Introduction:

The Wireless Sensor Networks (WSN) technology has immensely contributed to many
fields of research. To maintain installation flexibility and to reduce the high costs of
wired power supply, the wireless sensor nodes are becoming battery-powered. Since
the in-built battery source of the wireless sensor node has a limited energy capacity,
it is necessary to find methods to optimize the power consumption within the sensor
node. The wireless node must be maintained at its lowest power consumption level to
increase the limited battery life of the wireless sensor node, which is called sleep
mode, as long as it is possible. This work presents an energy-efficient on-
demand sink-path protocol for the WSN-based localization platform. In this protocol,
each node has stored the shortest path to sink while also maintaining a low power idle
listening mode using low power built-in Wake-Up receiver which activates only when
a request occurs. Once the localization is done, the new node needs to find the sink
to relay its location to the sink. For this, the node obtains the most efficient path
available to it from its neighbors and using that path, the new node will communicate
with the sink. This method permits optimizing the activity time of the wireless node and utilizes
fewer nodes as possible in the whole communication process, which extends the
network lifetime. The theoretical results calculated by the computer simulation
platform confirm the efficiency of our proposed approaches. The proposed technique
has been created and implemented by using MATLAB R2020a.

# Application Manual:

The application is created on MATLAB R2020a and can also run using the higher
version of MATLAB.

There are 3 tabs on the application
interface: Setup, Output, and Matrices. On the Setup tab, the user can create and
control the scenario and other scenario-related settings. On the Output tab, the user
can analyze the results after the simulation run is complete. Also, the Output tab
shows the results of the ongoing simulation, which can help the user to understand
the flow and working of the simulation in a better way. The Matrices tab shows the
matrices related to the databases used in the simulation.
The Setup has the edit and other control fields by using which the user can create a
specific scenario and change simulation parameters. The Setup tab has the following
setup panels: Scenario, Packet. Node status, Simulation, Energy, Comparison, and
Graph.

The scenario setup panel is used to edit the scenario controlling parameters like
anchor deployment and shape of the network. The fields in the Scenario setup panels
are as follows:

• Network size
The network itself is the square or rectangular shape area in which the sensor nodes
will be deployed. The user needs to enter the length and width of the box in a meter
separated by a space. E.g., ‘100 200’ will create a rectangular shape network area with
length (horizontal axis) 100m and width (vertical axis) 200m.

• Node number
The number of normal nodes the user wants to deploy in the network.

• Normal node range (m)
Communication range of the normal node in meters.

• Node deployment
The ‘Node deployment’ drop-down menu has 2 options:
Pre-saved and Random. The ‘Pre-saved’ option deploys the normal nodes with respect
to a pre-saved matrix in the code and the network size. There are 1000 pre-saved
entries in that matrix. Since it is ‘saved’, the normal node deployment will be the same
for each simulation run with the same network size entries. The Random option
deploys the normal nodes randomly in the network and the deployment will be
different for each simulation run even with the same network size entries.
• Anchor deployment
The‘ Anchor deployment’ drop-down menu with 3 options: Square
Grid, Hexagonal Grid, and Triangular Grid. The Square Grid, Hexagonal Grid, and
Triangular Grid options create a grid of anchor nodes deployed in a square, hexagonal,
and triangular grid formation respectively, and will retain the deployment of the
Network size and Anchor node range unchanged. Squared Random creates Randomly
deployed anchor node fields, which will be different for each simulation run.

• Anchor range (m)
Communication range of the anchor node in meters. Changing the Anchor node range
directly affects the Anchor deployment and Anchor number.

• Side (m)
The Side field is activated only when ‘Triangular Grid’ or ‘Hexagonal Grid’ options are
selected in the ‘Anchor deployment’ field. The ‘Side’ represents the edge and side of
a hexagon and triangle respectively, so in other words, it represents the distance
between anchors. The user can change the density of anchors in the network area by
changing the value of ‘Side’ filed in the interface. If the user leaves the ‘Side’
field blank, the application automatically selects the ‘Side’. For hexagonal deployment:
half of the Anchor range and for triangular deployment: same as the Anchor range.

• Sink
Once the anchors are deployed the application automatically chooses an Anchor node
closest to the center of the network as a Sink node. The user can check the Anchor
deployment and Sink node assignment by clicking on the ‘Create scenario’ button. If
the user wants to assign a different anchor node as a Sink, the node number of that
particular node needs to be specified in the ‘Sink’ field.

• Anchor number
Anchor number is an ‘auto-generated field’, depending upon the Network size and
Anchor node range of the network. Anchor number can be calculated by clicking on
the ‘Create scenario’ button.

In the Packet size setup panel, the packet size of different types of packets is set in this
panel. The fields in the Packet size setup panels are as follows: Wake-up, Broadcast,
Data. The Wake-up packet is the WuReq packet sent by the sender node and received
by the idle-listening WuRx of the sleeping node. The broadcast packet is the packets
sent by the new node in the network to find its neighbor nodes. The data packet is
always sent by the main radio and contains localization and other information.
The Energy setup panel is used to set parameters related to the energy model, RSSI,
and other energy-related variables. The fields in the Energy setup panels are as
follows:

• Initial energy (J)
The initial energy of every incoming node in the network in Joules.

• WuRx Energy consumption (W)
The Wake-up receiver consumes constant energy per sec to keep listening to the
channel, while the Main radio is disabled. This field takes the energy consumption of
the Wake-up receiver in Watts from the user.

• Critical power (%)
When the remaining battery power of the node reaches ‘Critical power’ (%), the node
notifies the sink about its energy status. The sink changes the status of this node from
‘Online’ to ‘Critical’ in its database. The sink then finds the alternative sink-paths for
the neighbor of the critical node by using the data from the database, for the nodes
which include the critical node in their sink-paths and notifies the concerning nodes in
the network about the change in the sink-path.

The Simulation setup panel has control and edit fields related to simulation duration,
node events, and simulation pause settings. The fields in the Simulation setup panels
are as follows:

• Simulation Time (sec)
The total duration of the simulation is seconds. The duration starts after the anchor
deployment is complete.

• Node Events
‘Node Event’ field specifies the birth time of all normal nodes in the network in the
simulation time duration. In other words, these are the time stamps at which the
nodes become active for the first time in the network. The ‘Node Events’ has 2 radio
buttons to select the nature of node events: Random and Manual.
When the user selects the ‘Random’ option, the node events are generated randomly
in the bounds of ‘Simulation time’ and the number of events is equal to the ‘Node
number’. The user can determine the random node events before the simulation by
selecting the ‘Random’ radio button and then clicking on the ‘Generate node events’
button. Generated node events along with the node IDs can be seen in the table below
the ‘Generate node events’ button.
The user can give manual events by selecting the ‘Manual’ radio button option,
entering the events in the blank field after the Manual radio button, and then clicking
on the ‘Generate node events’ button. The events should be entered separated by
spaces or in the form column matrix and the user should make sure that the number
of events and the Node number is the same, to avoid error messages. As described
before, the table below the ‘Generate node events’ button shows the generated node
events.

• Pause simulation checkboxes
The user can control the simulation run by pausing the simulation for specific events
like node deployment, dead node detection, critical node detection, and restored
node detection.
The status of a specific node at the specific event can be controlled in the ‘Node status
setup’ panel. The fields in the Node status setup panels are as follows:
The user can change the status of any node (normal node or anchor node) in the
network to ‘dead’ to simulate the dead node in the network. First, the node ID and
that specific node event are entered in the ‘Node ID’ and ‘Node Event’ edit fields, and
then click on the ‘Add to dead nodes’ button. The user can also restore the ‘dead node’
in the network similarly, by clicking on the ‘Add to restored nodes’ button, before
entering the node details in ‘Node ID’ and ‘Node Event’ edit fields. The dead or
restored nodes are displayed in the ’Dead nodes’ and ‘Restored nodes’ tables. The
user can clear the tables by clicking on the ‘clear table’ button above each table, to
start editing that particular table from the beginning.

In the graph setup panel, to analyze and evaluate the purposes of the results, the user
can select the checkboxes to get different types of graphs according to the need and
choices of the user.
The comparison panel can save up to three different scenarios and provides the
following comparison graphs: Energy consumption wrt Time and Localization error.
The user can start the execution of the simulation by clicking on the ‘Run Simulation
button. The displaying values of node events and node status tables are taken into
consideration, rather than creating random data for every run. The ‘clear cache’
button clears all temporary variables created in the previous simulation run, all
Figures, the residual data in all tables, and the Manual node events field in the
Simulation setup panel, all edit fields in the Graph setup panel, and all fields in Output
and Matrices tab. It does not clear the fields, which have values given by default when
the application starts. The ‘clear all’ button clears everything including all the default
fields.
