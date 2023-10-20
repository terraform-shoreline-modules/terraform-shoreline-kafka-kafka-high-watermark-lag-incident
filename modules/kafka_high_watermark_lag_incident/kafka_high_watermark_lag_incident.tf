resource "shoreline_notebook" "kafka_high_watermark_lag_incident" {
  name       = "kafka_high_watermark_lag_incident"
  data       = file("${path.module}/data/kafka_high_watermark_lag_incident.json")
  depends_on = [shoreline_action.invoke_check_lag_threshold,shoreline_action.invoke_kafka_replication]
}

resource "shoreline_file" "check_lag_threshold" {
  name             = "check_lag_threshold"
  input_file       = "${path.module}/data/check_lag_threshold.sh"
  md5              = filemd5("${path.module}/data/check_lag_threshold.sh")
  description      = "Check if the lag for a partition exceeds a certain threshold"
  destination_path = "/tmp/check_lag_threshold.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "kafka_replication" {
  name             = "kafka_replication"
  input_file       = "${path.module}/data/kafka_replication.sh"
  md5              = filemd5("${path.module}/data/kafka_replication.sh")
  description      = "Increase the replication factor to ensure that messages are replicated to more in-sync replicas."
  destination_path = "/tmp/kafka_replication.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_check_lag_threshold" {
  name        = "invoke_check_lag_threshold"
  description = "Check if the lag for a partition exceeds a certain threshold"
  command     = "`chmod +x /tmp/check_lag_threshold.sh && /tmp/check_lag_threshold.sh`"
  params      = ["TOPIC_NAME","PARTITION_NUMBER","THRESHOLD"]
  file_deps   = ["check_lag_threshold"]
  enabled     = true
  depends_on  = [shoreline_file.check_lag_threshold]
}

resource "shoreline_action" "invoke_kafka_replication" {
  name        = "invoke_kafka_replication"
  description = "Increase the replication factor to ensure that messages are replicated to more in-sync replicas."
  command     = "`chmod +x /tmp/kafka_replication.sh && /tmp/kafka_replication.sh`"
  params      = ["ZOOKEEPER_HOST","NUMBER_OF_PARTITIONS","ZOOKEEPER_PORT"]
  file_deps   = ["kafka_replication"]
  enabled     = true
  depends_on  = [shoreline_file.kafka_replication]
}

