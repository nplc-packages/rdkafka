local rdkafka = {
    producer_config = require 'rdkafka/config',
    producer  = require 'rdkafka/producer',
    topic_config  = require 'rdkafka/topic_config',
    topic  = require 'rdkafka/topic'
}

Kafka = Kafka or {}
local KafkaProducer = commonlib.inherit(nil, commonlib.gettable("Kafka.Producer"))
local KafkaTopicCreator = commonlib.gettable("Kafka.TopicCreator")

KafkaProducer.rdkafka = rdkafka
KafkaTopicCreator.rdkafka = rdkafka


function KafkaTopicCreator.create_topic(name, producer_client, options)
    local config = KafkaTopicCreator.create_config(options)
    local topic = rdkafka.topic.create(producer_client, name, config)
    return topic
end

function KafkaTopicCreator.create_config(options)
    local options = options or {}
    local config = rdkafka.topic_config.create()
    for k, v in pairs(options) do
        config[k] = v
    end
    return config
end


function KafkaProducer:init(brokers, event_callbacks, options)
    self:bind_client(brokers, event_callbacks, options)
    return self
end

function KafkaProducer:bind_client(brokers, event_callbacks, options)
    local config = KafkaProducer:create_config(event_callbacks, options)
    local client = rdkafka.producer.create(config)
    self.client = client
    self:add_brokers(brokers)
end

function KafkaProducer:bind_topic(topic_name, options)
    self.topics = self.topics or {}
    self.topics[topic_name] = KafkaTopicCreator.create_topic(
        topic_name, self.client, options)
end

function KafkaProducer:create_config(event_callbacks, options)
    local options = options or {}
    local config = rdkafka.producer_config.create()
    for k, v in pairs(options) do
        config[k] = v
    end
    self:set_config_event_callbacks(config, event_callbacks)
    return config
end

function KafkaProducer:add_brokers(brokers)
    for i, broker in ipairs(brokers) do
        self.client:brokers_add(broker)
    end
end

function KafkaProducer:set_config_event_callbacks(config, event_callbacks)
    local event_callbacks = event_callbacks or {}
    if event_callbacks.delivery_cb then
        config:set_delivery_cb(event_callbacks.delivery_cb)
    end
    if event_callbacks.stat_cb then
        config:set_stat_cb(event_callbacks.stat_cb)
    end
    if event_callbacks.error_cb then
        config:set_error_cb(event_callbacks.error_cb)
    end
    if event_callbacks.log_cb then
        config:set_log_cb(event_callbacks.log_cb)
    end
end

function KafkaProducer:produce(params)
    self.client:produce(params.topic, params.partition, params.payload, params.key)
end

function KafkaProducer:poll(timeout_ms)
    return self.client:poll(timeout_ms)
end


function KafkaProducer:outq_len()
    return self.client:outq_len()
end

function KafkaProducer.thread_cnt()
    return self.client.rd_kafka_thread_cnt()
end
