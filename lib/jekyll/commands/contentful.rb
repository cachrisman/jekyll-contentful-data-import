require 'jekyll-contentful-data-import/importer'

module Jekyll
  # Module for Jekyll Commands
  module Commands
    # jekyll contentful Command
    class Contentful < Command
      def self.init_with_program(prog)
        prog.command(:contentful) do |c|
          c.syntax 'contentful [OPTIONS]'
          c.description 'Imports data from Contentful'

          options.each { |opt| c.option(*opt) }

          add_build_options(c)

          command_action(c)
        end
      end

      def self.options
        [
          [
            'rebuild', '-r', '--rebuild',
            'Rebuild Jekyll Site after fetching data'
          ],
          [
            'wait', '-w', '--wait',
            'Wait X seconds before fetching data and rebuilding Jekyll Site'
          ]
        ]
      end

      def self.command_action(command)
        command.action do |args, options|
          jekyll_options = configuration_from_options(options)
          contentful_config = jekyll_options['contentful']
          process args, options, contentful_config
        end
      end

      def self.process(_args = [], options = {}, contentful_config = {})
        Jekyll.logger.info 'Starting Contentful import'

        if options['wait']
          if _args[0] and _args[0].to_i > 0
            puts "Waiting for #{_args[0]} seconds"
            sleep(_args[0].to_i)
          else
            raise "Invalid argument for --wait option. Only integers greater than 0 are valid"
          end
        end

        Jekyll::Contentful::Importer.new(contentful_config).run

        Jekyll.logger.info 'Contentful import finished'

        return unless options['rebuild']

        Jekyll.logger.info 'Starting Jekyll Rebuild'
        Jekyll::Commands::Build.process(options)
      end
    end
  end
end
