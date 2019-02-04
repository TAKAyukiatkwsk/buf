require 'spec_helper'
require 'buffbuff/command'

RSpec.describe Buffbuff::Command do
  describe "#list" do
    it "should print templates list" do
      allow(Dir).to receive(:glob) { ["templates/aaa.mustache", "templates/bbb.mustache", "templates/ccc.mustache"] }
      command = Buffbuff::Command.new([], {}, {app_path: 'foo'})
      expect(capture(:stdout) { command.list }).to eq("aaa\nbbb\nccc\n")
    end

    it "should print no templates message" do
      allow(Dir).to receive(:glob) { [] }
      command = Buffbuff::Command.new([], {}, {app_path: 'foo'})
      expect(capture(:stdout) { command.list }).to match(/There is no template files in templates directory\./)
    end
  end

  describe "#post" do
    # FIXME: When raised SystemExit, rspec process also exits
    it "should post to Buffer" do
      profiles_api_response = <<-EOT
      [{ 
        "avatar" : "http://a3.twimg.com/profile_images/0000000000.png",
        "created_at" :  1320703028,
        "default" : true,
        "formatted_username" : "@example",
        "id" : "000000000000000000000000",
        "schedules" : [{ 
            "days" : [ 
                "mon",
                "tue",
                "wed",
                "thu",
                "fri"
            ],
            "times" : [ 
                "12:00",
                "17:00",
                "18:00"
            ]
        }],
        "service" : "twitter",
        "service_id" : "164724445",
        "service_username" : "example",
        "statistics" : { 
            "followers" : 246 
        },
        "team_members" : [
            "000000000000000000000001"
        ],
        "timezone" : "Europe/London",
        "user_id" : "000000000000000000000000"
      }]
      EOT
      updates_api_response = <<-EOT
      {
        "success": true,
        "buffer_count": 10,
        "buffer_percentage": 20,
        "updates": [{
          "id": "000000000000000000000000",
          "created_at": 1320703582,
          "day": "Saturday 26th November",
          "due_at": 1320742680,
          "due_time": "11:05 am",
          "media": {
            "link": "http://google.com",
            "title": "Google",
            "description": "The google homepage"
          },
          "profile_id": "000000000000000000000000",
          "profile_service": "twitter",
          "status": "buffer",
          "text": "This is an example update",
          "text_formatted": "This is an example update",
          "user_id": "000000000000000000000000",
          "via": "api"
        }]
      }
      EOT
      stub_request(:get, /#{buffer_api_base_url}\/profiles\.json\?access_token=/).to_return(status: 200, body: profiles_api_response)
      stub_request(:post, /#{buffer_api_base_url}\/updates\/create\.json\?access_token=/).
        to_return(status: 200, body: updates_api_response, headers: {})
      expect(Thor::LineEditor).to receive(:readline).with("Continue to post Buffer with this body? [y/n] ", :add_to_history => false).and_return("y")
      command = Buffbuff::Command.new([], {args: ['key1=value1', 'key2=value2'], d: '2019-04-04T21:00:00+09:00'}, {app_path: File.join(File.dirname(__FILE__), '..', 'fixtures')})
      out = capture(:stdout) { command.post('test') }
      expect(out).to match(/^Hello value1. My name is value2./)
      expect(out).to match(/2019-04-04T21:00:00\+09:00/)
      expect(out).to match(/Succeeded/)
    end
  end
end
