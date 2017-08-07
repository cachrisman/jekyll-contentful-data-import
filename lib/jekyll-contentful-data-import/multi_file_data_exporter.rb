require 'jekyll-contentful-data-import/base_data_exporter'
require 'yaml'

module Jekyll
  module Contentful
    # Single File Data Exporter Class
    #
    # Serializes Contentful data into a multiple YAML files
    class MultiFileDataExporter < BaseDataExporter
      def run
        data = ::Jekyll::Contentful::Serializer.new(
          entries,
          config
        ).serialize

        data.each do |content_type, entries|
          content_type_directory = File.join(destination_directory, name, content_type.to_s)
          setup_directory(content_type_directory)

          entries.each do |entry|
            puts "Writing file: #{filename(entry)}.yaml"
            yaml_entry = YAML.dump(entry)

            File.open(destination_file(content_type_directory, entry), 'w') do |file|
              file.write(yaml_entry)
            end
          end
        end
      end

      def destination_file(content_type_directory, entry)
        File.join(content_type_directory, "#{filename(entry)}.yaml")
      end

      def filename(entry)
        if config.key?('individual_entry_filename_field')
          filename = instance_eval("entry#{config['individual_entry_filename_field']}")
        else
          filename = entry['sys']['id']
        end

        filename
      end
    end
  end
end
