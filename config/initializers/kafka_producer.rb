# Configure the Kafka client with the broker hosts and the Rails
# logger.
$kafka = Kafka.new([ ENV['KAFKA_HOST'] ], logger: Rails.logger, client_id: ENV['KAFKA_CLIENT_ID'])
$kafka_producer = $kafka.async_producer

# Rails.logger.debug($kafka.client_id)
# Make sure to shut down the producer when exiting.
at_exit { $kafka_producer.shutdown }

$KAFKA_VIBE_TOPIC = ENV['KAFKA_VIBE_TOPIC']
$KAFKA_FLOW_TOPIC = ENV['KAFKA_FLOW_TOPIC']