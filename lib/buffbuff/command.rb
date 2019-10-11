require 'mustache'
require 'thor'
require 'time'

require 'buffbuff/buffer_client'

module Buffbuff
  class Command < Thor
    include Thor::Actions

    def initialize(args = [], options = {}, config = {})
      super

      @template_dir_name = "templates"
      @template_ext = ".mustache"
      @app_root_dir = config[:app_path] || File.expand_path("../../", File.dirname(__FILE__))
      @template_dir = File.join(@app_root_dir, @template_dir_name)
    end

    desc 'list', 'List templates'
    def list
      templates = Dir.glob("#{@template_dir}/*#{@template_ext}")
        .map {|f| File.basename(f, @template_ext) }

      if templates.empty?
        say("There is no template files in templates directory.", color = :red)
      else
        templates.each {|t| say t }
      end
    end

    desc 'post', 'Post to Buffer'
    method_options :d => :string, :args => :array
    def post(template)
      set_scheduled_at(options)

      # check template
      template_file = "#{@template_dir}/#{template}#{@template_ext}"
      unless File.exist?(template_file)
        say("Invalid template name: #{template}. Please check template directory.", color = :red)
        exit 1
      end

      # apply option args to template and generate body
      view = Mustache.new
      view.template_file = template_file
      parsed_args = parse_post_args(options[:args])
      parsed_args.each do |key, value|
        view[key.to_sym] = value
      end
      body = view.render
      say("----------------------------------------")
      say(body)
      say("----------------------------------------")
      say("Will be scheduled at: #{@scheduled_at}")
      unless yes?("Continue to post Buffer with this body? [y/n]", color = :cyan)
        exit 0
      end

      # request Buffer API
      say("Processing to post Buffer...", color = :cyan)
      client = BufferClient.new
      profiles = client.profiles
      result = client.create_update(
        body: {
          text: body,
          profile_ids: profiles.map(&:id),
          scheduled_at: @scheduled_at
        }
      )
      if result.success
        say("Succeeded to post Buffer!", color = :green)
      else
        say("Failed to post Buffer! Buffer API error message:", color = :red)
        say(result.message)
        exit 1
      end
    end

    private
    def parse_post_args(args)
      args.map {|arg| arg.split('=') }.to_h
    end

    def set_scheduled_at(options)
      @scheduled_at = options[:d] || (Time.now + time_offset).xmlschema
    end

    def time_offset
      10
    end
  end
end
