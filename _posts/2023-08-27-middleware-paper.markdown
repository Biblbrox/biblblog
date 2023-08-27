---
layout: splash
classes:
  - landing
  - dark-theme
---

FastDDS and ros2 node correspondence
==============
**Author** - Kuchkov Aleksey

**Created On** - 27.08.2023

## Introduction
Hello everyone. I have a deal with ROS/ROS2 very often due to my professional needs and hobby interests. My latest hobby project is tightly coupled with such low-level tools as ROS2 middlewares, which represent internal implementation of ROS nodes, topics, subscribers, publishers, services, etc. In most cases, it is unnecessary to think about such low-level features being satisfied with ROS api/cli only. Having said that, sometimes you may run into obstacles due to ROS2 limitation, especially in topology discovering and diagnostic. For example, if you want to find the IP address of the machine ROS2 node runs on, you may struggle with CLI limitations. 

I had a struggle with FastDDS for a while, and I want to share some of the knowledge I had obtained during the hard research process. Maybe it could help someone to save time a little bit. 

ROS2 uses FastDDS middleware by default, so this note is about FastDDS although all of the middlewares implement DDS standard more-less. Therefore, the knowledge about FastDDS concerns is not only applicable to eProsima implementation but to all of the middlewares, in terms of DDS standard at least.

Firstly, it is unnecessary to get an idea about what the middleware serve for in ROS ecosystem.  The main task of a middleware is to provide an internal implementation of ros2 entities. Due to a variety of the platforms in which ros2 can be run on, it is necessary to have multiple implementations with transparent internal switching mechanism. For example, eProsima FastDDS is the default ros2 middleware, while there are such implementations as Eclipse Cyclone DDS, Connext DDS, GurumDDS and Micro XRCE-DDS (for MicroROS).

There is some mess about the RTPS and DDS terminology. Although they are often used together, they represent the different layers in a network. DDS stands for Data Distribution Service that represents publisher-subscriber paradigm with rich type system and QoS (Quality of Service) features built-in. The RTPS (also known as [DDSI-RTPS](https://www.omg.org/spec/DDSI-RTPS/)) has the goal is to provide network and IPC communication at lower level. While the most DDS implementations use RTPS internally for delivering messages, this is not always the case. Furthermore, you can use bare RTPS without any typing system, but you do not have to do such clever tricks mostly. 

| ![DDS_concept.svg](/biblblog/assets/DDS_concept.svg) |
| :---------------------------------: |
|      *FastDDS network example*      |


## Discovering DDS network using FastDDS C++ API
FastDDS has it own mechanism to discover participants, subscribers, and publishers. We can use it with inhereting the class ```eprosima::FastDDS::dds::DomainParticipantListener``` and implementing the methods ```on_participant_discovery```, ```on_subscriber_discovery```, ```on_publisher_discovery``` and ```on_type_discovery```. 

Each of these methods has two arguments: a participant, which a discovered event belongs to, and information about an event. 

**on_participant_discovery** called when a new participant appeared in the network. Keep in mind that one participant may hold multiple ros2 nodes depending on which context these nodes were created. Nodes created in a single context will be stored in a single participant, whereas nodes in different contexts will be stored in separate participants. 

**on_subscriber_discovery** and **on_publisher_discovery** called when a new writer or reader discovered. 

**on_type_discovery** called when a new type is discovered.

## DDS-ROS2 correspondence
ROS2 uses nodes as the main objects that hold subscribers, publishers, and other entities inside. FastDDS, on the other hand, doesn't have such type of objects. Instead, it uses participants as the reader/writer(publisher/subscriber) holders, which may cause some confusion due to the similarity of terms. But there is the caution - there is no direct correspondence between ROS2 nodes and FastDDS participants since Foxy. So, a single participant may hold multiple ROS2 nodes. Moreover, there is no such thing as ROS2 Context in FastDDS. The table below is taken from ROS2 documentation and represents correspondence between ROS2 and FastDDS.

| ROS entity | Fast DDS entity since Foxy | Fast DDS entity in Eloquent & below |
| ---------- | -------------------------- | ----------------------------------- |
| Context    | Participant                | Not DDS direct mapping              |
| Node       | Not DDS direct mapping     | Participant                         |             


What entities we can relay on are publishers and subscribers. So, we have to find some mechanism to find ros2 entity using only publishers and subscribers. We can relay on the fact that every ROS2 node has a built-in topic named /rosout, which is used for logging purposes. So, having found a topic gid, we can find the corresponding topic using ROS2 api. Thus, obtaining a node name becomes an easy goal.
In order to find a topic GID, we may use the method guid() of info object in ```eprosima::fastrtps::rtps::WriterDiscoveryInfo``` argument in ```on_publisher_discovery```. Due to the fact that every node has a single ```/rosout``` topic, we can make a condition to filter other publishers.
The code below demonstrates the general idea:
```c++
void DiscoveryDomainParticipantListener::on_publisher_discovery(
    eprosima::FastDDS::dds::DomainParticipant *participant,
    eprosima::fastrtps::rtps::WriterDiscoveryInfo &&info) {
  static_cast<void>(participant);
  switch (info.status) {
  case eprosima::fastrtps::rtps::WriterDiscoveryInfo::DISCOVERED_WRITER:
    /* Process the case when a new publisher was found in the domain */
    if (info.info.topicName() == "rt/rosout") {
      // ...
      // Extract GID
      // ...
    }
    break;
  case eprosima::fastrtps::rtps::WriterDiscoveryInfo::CHANGED_QOS_WRITER:
    /* Process the case when a publisher changed its QOS */
    break;
  case eprosima::fastrtps::rtps::WriterDiscoveryInfo::REMOVED_WRITER:
    /* Process the case when a publisher was removed from the domain */
    break;
  }
}
```
So, you may notice that FastDDS topic corresponds to the exact topic in ros2 except the "rt" prefix. The primary language of my project is Rust, so I had to write C wrappers in order to use FastDDS capabilities. But the general idea remains the same, so you may adapt the code provided below to C++ without any problems. The process of finding the exact node name with only the topic name known may look like:
```rust
 pub fn node_name_by_gid(&self, topic_name: String, gid_search: String) -> String {
    let data_bytes = Command::new("ros2")
        .arg("topic")
        .arg("info")
        .arg(topic_name)
        .arg("--verbose")
        .output()
        .expect("failed to execute process");

    let re = RegexMatcher::new(r"Node name:").unwrap();
    let mut searcher = SearcherBuilder::new()
        .before_context(0)
        .after_context(4)
        .build();

    let mut matches: Vec<(usize, String)> = vec![];
        searcher.search_slice(
        &re,
        data_bytes.stdout.as_slice(),
        UTF8(|lnum, line| {
            let mymatch = re.find(line.as_bytes())?.unwrap();
            matches.push((lnum.to_usize(), line[mymatch].to_string()));
            Ok(true)
        }),
    ).unwrap();

    for (num, line) in matches {
        if line.starts_with("GID: ") {
            let gid = line.split(": ").collect::<Vec<&str>>()[1];
            if gid.starts_with(gid_search.as_str()) {
                let (_, node_name_line) = matches.iter().find(|(lnum, line)| *lnum == num - 4).unwrap();
                let node_name = node_name_line.split(": ").collect::<Vec<&str>>()[1];
                return node_name.to_string();
            }
        }
    }

    return "".to_string();
}
```

The most easiest way to get info about ROS2 topics (but not the most effective) is to use ROS2 cli as I have done. This is a simplified version of code used in my hobby project. So, I have to rewrite it in a more sophisticated way in the future, but for this moment, that is enough because it works pretty well. 

Also, you have to use the same Domain ID in each program and terminal, of course. 

## Cautions
Besides sourcing ros2 environment with the command ```sh /opt/ros/{version}/setup.sh``` you have to set the environment variable ROS_DISCOVERY_SERVER with the address of the target the server runs on. In the case of localhost, it may look like this: 
```bash
export ROS_DISCOVERY_SERVER="127.0.0.1:11811"
```
Of course, you have to specify the same address and port when you create a discovery server.

## Conclusion
To sum up, despite the fact of a lack of information about a node name in FastDDS middleware due to participant reusing for multiple nodes, there is a way to obtain a node name from topic (Writer or Reader) gid. With the given name, we may extract useful information from FastDDS writer or reader and then use it on the ROS2 side. 

By the way, FastDDS has a great [documentation](https://fast-dds.docs.eprosima.com/en/latest/) with many examples, so if you want to read more don't hesitate to look into.


# Useful links
1. FastDDS docs: https://fast-dds.docs.eprosima.com/en/latest/
2. Enabling discovery server in ros2: https://fast-dds.docs.eprosima.com/en/latest/FastDDS/ros2/ros2.html
3. Using FastDDS features with ROS2: https://docs.ros.org/en/iron/Tutorials/Advanced/FastDDS-Configuration.html
4. An example of implementing listener for FastDDS discovery server: https://fast-dds.docs.eprosima.com/en/latest/fastdds/discovery/disc_callbacks.html
