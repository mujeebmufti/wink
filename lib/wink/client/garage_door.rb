module Wink
  class Client
    # Provides access to binary switch API commands.
    #
    # garage_door_id - The binary switch id as a Integer
    #
    # Returns a BinarySwitch instance.
    def garage_door(garage_door_id = nil)
      GarageDoor.new self, garage_door_id
    end

    class GarageDoor
      def initialize(client, garage_door_id = nil)
        @client         = client
        @garage_door_id = garage_door_id
      end

      attr_reader :client, :garage_door_id

      def users
        response = client.get('/garage_doors{/garage_door}/users', :garage_door => garage_door_id)
        response.body["data"]
      end

      def subscriptions
        response = client.get('/garage_doors{/garage_door}/subscriptions', :garage_door => garage_door_id)
        response.body["data"]
      end

      def open
        set_position true
      end

      def open?
        position == 1
      end

      def close
        set_position false
      end

      def closed?
        !open?
      end

      def position
        garage_door["last_reading"]["position"]
      end

      def refresh
        response = client.post('/garage_doors{/garage_door}/refresh', :garage_door => garage_door_id)
        response.success?
      end

      private

      def garage_door
        response = client.get('/garage_doors{/garage_door}', :garage_door => garage_door_id)
        response.body["data"]
      end

      def set_position(state)
        body = {
          :desired_state => {
            :position => state ? 1 : 0
          }
        }

        response = client.put('/garage_doors{/garage_door}', :garage_door => garage_door_id, :body => body)
        response.success?
      end
    end
  end
end
