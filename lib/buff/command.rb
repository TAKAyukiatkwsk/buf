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
  end
end
