
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kafka High Watermark Lag Incident
---

Kafka High Watermark Lag Incident is an incident that occurs in a Kafka environment when the high watermark, which is the highest offset that has been replicated to all in-sync replicas, lags behind the low watermark, which is the offset of the last message written to the partition. This happens when Kafka consumers are not consuming messages at the same rate as they are being produced, causing a backlog of messages that have not been processed. This lag can lead to data loss, as messages that have not been replicated to all in-sync replicas may be lost if a replica fails. It is important to monitor Kafka high watermark lag and take corrective actions to ensure that it does not exceed a certain threshold.

### Parameters
```shell
export BOOTSTRAP_SERVER="PLACEHOLDER"

export TOPIC_NAME="PLACEHOLDER"

export BROKER_LIST="PLACEHOLDER"

export PARTITION_NUMBER="PLACEHOLDER"

export THRESHOLD="PLACEHOLDER"

export ZOOKEEPER_PORT="PLACEHOLDER"

export NUMBER_OF_PARTITIONS="PLACEHOLDER"

export ZOOKEEPER_HOST="PLACEHOLDER"

```

## Debug

### List all topics in Kafka
```shell
kafka-topics.sh --bootstrap-server ${BOOTSTRAP_SERVER} --list
```

### Describe a topic to get its configuration, including replication factor and partition count
```shell
kafka-topics.sh --bootstrap-server ${BOOTSTRAP_SERVER} --describe --topic ${TOPIC_NAME}
```

### Get the current high watermark for a partition
```shell
kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list ${BROKER_LIST} --topic ${TOPIC_NAME} --partition ${PARTITION_NUMBER} --time -1 --offsets 1 | awk -F ":" '{print $3}'
```

### Get the current low watermark for a partition
```shell
kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list ${BROKER_LIST} --topic ${TOPIC_NAME} --partition ${PARTITION_NUMBER} --time -2 --offsets 1 | awk -F ":" '{print $3}'
```

### Get the lag for a partition by subtracting the high watermark from the low watermark
```shell
lag=$(($(kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list ${BROKER_LIST} --topic ${TOPIC_NAME} --partition ${PARTITION_NUMBER} --time -2 --offsets 1 | awk -F ":" '{print $3}') - $(kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list ${BROKER_LIST} --topic ${TOPIC_NAME} --partition ${PARTITION_NUMBER} --time -1 --offsets 1 | awk -F ":" '{print $3}')))
```

### Check if the lag for a partition exceeds a certain threshold
```shell
if [ $lag -gt ${THRESHOLD} ]; then

  echo "Lag for partition ${PARTITION_NUMBER} in topic ${TOPIC_NAME} is $lag"

  # Additional commands to investigate the root cause of the lag

fi
```

## Repair

### Increase the replication factor to ensure that messages are replicated to more in-sync replicas.
```shell


#!/bin/bash



# Set the replication factor

REPLICATION_FACTOR="PLACEHOLDER"



# Get the list of Kafka topics

TOPICS=$(kafka-topics --zookeeper ${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT} --list)



# Loop through the topics and set the replication factor for each

for TOPIC in $TOPICS

do

    kafka-topics --zookeeper ${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT} --alter --topic $TOPIC --partitions ${NUMBER_OF_PARTITIONS} --replication-factor $REPLICATION_FACTOR

done



# Restart the Kafka brokers for the changes to take effect

systemctl restart kafka


```