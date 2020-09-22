require "nats"

module Finex::Stream
  class Client
    @@connection : NATS::Connection?

    def self.connection
      @@connection ||= NATS::Connection.new(ENV["NATS_URL"])
    end

    def self.disconnect
      @@connection.close
    end

    def self.publish(subject : String | Symbol, payload)
      Client.connection.publish(subject: subject.to_s, msg: payload.to_json)
    end

    def self.subscribe(subject : String | Symbol, &callback : NATS::Msg ->)
      queue_name = "finex.#{Random.new.hex(10)}"

      Client.connection.subscribe(subject: subject.to_s, queue: queue_name, &callback)
    end

  end
end
