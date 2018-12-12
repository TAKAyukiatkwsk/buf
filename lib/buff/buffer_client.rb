require 'buffer'

require 'buff/buffer_client/profile'

module Buff
  class BufferClient
    def initialize
      @client = Buffer::Client.new(ENV["BUFFER_ACCESS_TOKEN"])
    end
  
    def profiles
      profiles = @client.profiles
      profiles.map {|p| Profile.new(p.id, p.service, p.service_username) }
    end
  
    def create_update(options = {})
      @client.create_update(options)
    end
  end
end
