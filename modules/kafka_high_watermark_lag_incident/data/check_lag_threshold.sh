if [ $lag -gt ${THRESHOLD} ]; then

  echo "Lag for partition ${PARTITION_NUMBER} in topic ${TOPIC_NAME} is $lag"

  # Additional commands to investigate the root cause of the lag

fi