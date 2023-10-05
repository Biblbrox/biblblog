---
layout: post
classes:
  - landing
  - dark-theme
image: "/assets/logo.jpeg"
title: DDS discovery tool for ROS2 ecosystem
---

**Author** - Kuchkov Aleksey


# Introduction
Hello everyone, I want to introduce my hobby project - ROS2 Monitor. The main goal of the project is to provide a detailed information about the ROS2 ecosystem for introspection purposes. The detail information collected with FastDDS middleware (there is the plans to extend information sources) and ROS2 CLI tools. The main benefit of of direct usage the api of middleware is the possibility to obtain details that unaccessible with standard ROS2 CLI. 

To sum up, the program at the current moment is more like a concept (or minimal example) rather than ready to use solution. The main idea is to get feedback about the viability of this approach. And the another goal I am leading to is to find the people who may involve into developing process along with me because the task itself contains a lot of details that can be a hardly implemented single alone. 

The program has client server architecture where the server part is implemented as a system daemon written in Rust, and the client is the C++ gui application. The server api can be accessed through JSON command description written to the daemon's socket file (Unix Domain Socket) - /tmp/ros2monitor.sock. Thus, any program which implements the JSON api may become a client. The examples of information you may obtain from the daemon:
- Information about the host ROS2 node running on (IP, hostname);
- Detailed QOS info, like message transport type: UDPv4, TCPv4, UDPv6, TCPv6, SHM;
- Lifecycle node control: configure, activate, deactivate, cleanup, shutdown (under development)

The tool is supposed to be used with ROS2 ecosystem without any hardware manufacturer lock to make the possibility for nodes to be running on completely different devices in the same network. 

# Inspiration sources
As the main inspiration source, I took the Nvidia SDK, which includes the program with the name Graph Composer. It allows you to create computer vision application with a graphical approach (via graph editing). But the main goals of my prototype are slightly different. They include:
- Provide the topology observation tool with deep traffic data analysis for ROS2 ecosystem;
- Give a possibility to debug ROS2 nodes with their's topics visualization in real-time;
- Provide a tool for lifecycle node control;
- Grant a way for filesystem package observing with corresponding detailed information.

So, my decision was to implement an architecture that would allows to use multiple types of clients, including web ones. The picture below demonstrates this idea:
![./ros2monitor_scheme.svg](/assets/ros2monitor_scheme.webp)

# The daemon architecture
The daemon has several configuration flags that determine it's behavior. At the current moment, there is only two possible variants. The first one, uses the bare ROS2 CLI.
The another uses FastDDS discoverer server. Thus, considering the fact that FastDDS is the default middleware implementation, the combination of ROS2 CLI and FastDDS server covers the major part of needs. Having said that, there is a plan to implement the micro-ros support in the future. 

As being said, the daemon has communication channel through Unix Domain Sockets with JSON requests. The typical request looks like:
```JSON
{ 
    "command": "state", 
    "arguments": [] 
}
```
with the following response:
```JSON
{
   "nodes":[
      {
         "action_clients":[],
         "action_servers":[],
         "host":{
            "ip":"192.168.0.46",
            "name":"raspberrypi.Dlink"
         },
         "is_lifecycle":false,
         "name":"turtlesim",
         "package_name":"",
         "publishers":[
            {
               "guid":"01.0f.04.aa.41.2c.03.e1.01.00.00.00",
               "host":{
                  "ip":"192.168.0.46",
                  "name":"raspberrypi.Dlink"
               },
               "node_name":"turtlesim",
               "topic_name":"ros_discovery_info",
               "topic_type":"rmw_dds_common::msg::dds_::ParticipantEntitiesInfo_"
            },
            {
               "guid":"01.0f.04.aa.41.2c.03.e1.01.00.00.00",
               "host":{
                  "ip":"192.168.0.46",
                  "name":"raspberrypi.Dlink"
               },
               "node_name":"turtlesim",
               "topic_name":"parameter_events",
               "topic_type":"rcl_interfaces::msg::dds_::ParameterEvent_"
            },
            {
               "guid":"01.0f.04.aa.41.2c.03.e1.01.00.00.00",
               "host":{
                  "ip":"192.168.0.46",
                  "name":"raspberrypi.Dlink"
               },
               "node_name":"turtlesim",
               "topic_name":"clearReply",
               "topic_type":"std_srvs::srv::dds_::Empty_Response_"
            },
            {
               "guid":"01.0f.04.aa.41.2c.03.e1.01.00.00.00",
               "host":{
                  "ip":"192.168.0.46",
                  "name":"raspberrypi.Dlink"
               },
               "node_name":"turtlesim",
               "topic_name":"spawnReply",
               "topic_type":"turtlesim::srv::dds_::Spawn_Response_"
            },
            {
               "guid":"01.0f.04.aa.41.2c.03.e1.01.00.00.00",
               "host":{
                  "ip":"192.168.0.46",
                  "name":"raspberrypi.Dlink"
               },
               "node_name":"",
               "topic_name":"killReply",
               "topic_type":"turtlesim::srv::dds_::Kill_Response_"
            },
            {
               "guid":"01.0f.04.aa.41.2c.03.e1.01.00.00.00",
               "host":{
                  "ip":"192.168.0.46",
                  "name":"raspberrypi.Dlink"
               },
               "node_name":"turtlesim",
               "topic_name":"turtle1/set_penReply",
               "topic_type":"turtlesim::srv::dds_::SetPen_Response_"
            }
         ],
         "service_clients":[],
         "service_servers":[],
         "state":"Unconfigured",
         "subscribers":[]
      },
      {
         "action_clients":[],
         "action_servers":[],
         "host":{
            "ip":"192.168.0.46",
            "name":"raspberrypi.Dlink"
         },
         "is_lifecycle":false,
         "name":"turtle_teleop_key",
         "package_name":"",
         "publishers":[
            {
               "guid":"01.0f.04.aa.41.2c.03.e1.01.00.00.00",
               "host":{
                  "ip":"192.168.0.46",
                  "name":"raspberrypi.Dlink"
               },
               "node_name":"turtle_teleop_key",
               "topic_name":"turtle1/pose",
               "topic_type":"turtlesim::msg::dds_::Pose_"
            },
            {
               "guid":"01.0f.04.aa.41.2c.03.e1.01.00.00.00",
               "host":{
                  "ip":"192.168.0.46",
                  "name":"raspberrypi.Dlink"
               },
               "node_name":"turtle_teleop_key",
               "topic_name":"turtle1/color_sensor",
               "topic_type":"turtlesim::msg::dds_::Color_"
            }
         ],
         "service_clients":[],
         "service_servers":[],
         "state":"Unconfigured",
         "subscribers":[]
      }
   ],
   "packages":[],
   "topics":[]
}
```
The daemon's response contains information about two nodes: turtlesim and turtle_teleop_key running on the Raspberry Pi host in the same network.
# The client
The client is written using C++ with Qt and QML. I have chosen these technologies as closest to me. The main task of the client is to provide a user graphical user interface for communicating with the daemon. The client implementation uses Asio library for talking to the daemon. The images below demonstrate the UI of the client:

![ui_client](/assets/client_ui3.png)
On the image above you can find several key elements:
1. Graph area. It is the field where nodes rendered with their topic communication topology;
2. Visualization area. This place is being used for visualizing topic data in real time;
3. Topic list area. It contains all of the topics in the considered domain id;
4. Node observer. Used to show currently running nodes in domain id;
5. Package observer. Contains filesystem ROS2 packages in specific workspace.

One of the major task of the client is the topic visualization feature. To open the visualization widget, you have to click to the plus button near the corresponding topic name on the topic list widget (shown with number 3)

On the proposed video, you can observe the example of the point cloud topic visualization (sensor_msgs::msg::PointCloud2).
<iframe width="420" height="315" src="/assets/Video_demo.mp4" frameborder="0" allowfullscreen></iframe>

# Restrictions
At the current moment, there are many features not yet implemented:
Visualization works correctly with a single publisher per topic only;
- Parameter customizations (like domain id, server ip, server port) are hardcoded;
- It isn't possible to save the current workspace to text file (in plans);
- And another dozens of bugs that I'm fixing little by little.

# Development roadmap
First of all, I want to stabilize the declared features to make them work properly. There is a lot of work with lifecycle node controlling, optimizing the discovery process, and topic visualization. The main goal is to establish the lifecycle node controlling with topic visualization for most widespread types. 

Another goal is to implement the feature for workspace saving into text files and loading workspaces from these files and some sort of node templates. It can be done without huge efforts because the daemon itself uses JSON representation for ROS2 nodes internally. Node templates, in their turn, requires a little more work to have done due to the requirement of writing some wrappers for nodes located in the user's filesystem. These wrappers, having wrote once, would be used as the templates for nodes which perform particular type of task, like object detection, image preprocessing, data visualization, to name a few with minimum amount of the code written by program's user.

