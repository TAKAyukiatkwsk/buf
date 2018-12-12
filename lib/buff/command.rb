require 'mustache'
require 'thor'

module Buff
  class Command < Thor
    include Thor::Actions

    desc 'list', 'List templates'
    def list
      template_dir_name = "templates"
      template_ext = ".mustache"
      template_dir = File.expand_path("../../#{template_dir_name}", File.dirname(__FILE__))
      templates = Dir.glob("#{template_dir}/*#{template_ext}")
        .map {|f| File.basename(f, template_ext) }

      if templates.empty?
        say("There is no template files in templates directory.", color = :red)
      else
        templates.each {|t| say t }
      end
    end

    desc 'post', 'Post to Buffer'
    method_options :d => :string, :args => :array
    def post(template)
      # check template
      template_dir_name = "templates"
      template_ext = ".mustache"
      template_dir = File.expand_path("../../#{template_dir_name}", File.dirname(__FILE__))
      template_file = "#{template_dir}/#{template}#{template_ext}"
      unless File.exist?(template_file)
        say("Invalid template name: #{template}. Please check template directory.", color = :red)
        exit 1
      end

      # apply args to template and generate body
      view = Mustache.new
      view.template_file = template_file
      say("----------------------------------------")
      say(view.render)
      say("----------------------------------------")
      unless yes?("Continue to post Buffer with this body? [y/n]", color = :cyan)
        exit 0
      end

      # request Buffer API
    end
  end
end
