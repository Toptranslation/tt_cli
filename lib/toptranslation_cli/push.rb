module ToptranslationCli
  class Push
    def self.run
      ToptranslationCli.configuration.load
      ToptranslationCli.configuration.files.each do |path_definition|
        placeholder_path = PlaceholderPath.new(path_definition['path'])
        project_locales.each do |locale|
          FileFinder.new(path_definition).files(locale.code).each do |path|

            path_with_placeholder = placeholder_path.for_path(path, locale.code)

            if document = find_document_by_path(path_with_placeholder)
              if document[:translations].nil? || document_changed?(document, path)
                puts "\nAdding translation for: #{ path }"
                project.documents.find(document[:identifier]).add_translation(path, locale.code)
              else
                puts "Skipping unchanged document: #{ path }"
              end
            else
              puts "\nCreating document: #{ path }"
              create_document(path, path_with_placeholder, locale.code)
            end
          end
        end
      end
    end

    private
      def self.document_changed?(document, path)
        document[:translations] && !document[:translations].map(&:sha1).include?( sha1_checksum(path) )
      end

      def self.sha1_checksum(path)
        Digest::SHA1.file(path).hexdigest
      end

      def self.create_document(path, path_with_placeholder, locale_code)
        response = project.upload_document(path, locale_code, { path: path_with_placeholder, name: File.basename(path) })

        @project_documents[path_with_placeholder] = { identifier: response['identifier'] }
      end

      def self.find_document_by_path(path_with_placeholder)
        @project_documents ||= project_documents
        @project_documents[path_with_placeholder]
      end

      def self.project_documents
        project&.documents.inject({}) do |accu, document|
          accu[document.path] = { identifier: document.identifier, translations: document.translations }
          accu
        end
      end

      def self.project_locales
        @project_locales ||= project.locales
      end

      def self.project
        @project ||= ToptranslationCli.connection.projects.find(ToptranslationCli.configuration.project_identifier)
      end
  end
end
