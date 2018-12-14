module Buffbuff
  class BufferClient
    class Profile
      attr_reader :id, :service, :service_username

      def initialize(id, service, service_username)
        @id = id
        @service = service
        @service_username = service_username
      end
    end
  end
end
