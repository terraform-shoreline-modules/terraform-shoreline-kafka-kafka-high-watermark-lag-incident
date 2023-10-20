

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