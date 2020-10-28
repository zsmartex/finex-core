require "amqp-client"

module Finex::MQ
  class Client
    @@connection : AMQP::Client::Connection?

    property channel : AMQP::Client::Channel
    property exchanges : Hash(String, AMQP::Client::Exchange)

    def self.connection
      options = {
        host:     ENV["RABBITMQ_HOST"] || "0.0.0.0",
        port:     ENV["RABBITMQ_PORT"] || "5672",
        username: ENV["RABBITMQ_USERNAME"],
        password: ENV["RABBITMQ_PASSWORD"],
      }

      @@connection ||= AMQP::Client.new(host: options["host"], port: options["port"].to_i, user: options["username"], password: options["password"]).connect
    end

    def disconnect
      @@connection.close
    end

    def initialize
      @channel = Client.connection.channel
      @exchanges = Hash(String, AMQP::Client::Exchange).new
    end

    def exchange(name : String, type = "topic")
      @exchanges[name] ||= @channel.exchange(name: name, type: type)
    end

    def publish(name : String, type : String, id : String, event : String, payload)
      routing_key = [type, id, event].join(".")
      serialized_data = payload.to_json
      exchange(name).publish(message: serialized_data, routing_key: routing_key)
      Finex.logger.debug { "published event to #{routing_key} " }
    end

    def subscribe(name : String, &callback : AMQP::Client::DeliverMessage ->)
      queue_name = "finex.#{Random.new.hex(10)}"
      queue = @channel.queue(name: queue_name, durable: false, auto_delete: true)
      exchange = queue.bind(exchange: name, routing_key: "#")
      exchange.publish("INIT")

      exchange.subscribe(&callback)
    end

  end
end
