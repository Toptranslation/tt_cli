# frozen_string_literal: true

module ToptranslationCli
  class Status
    class << self
      def run
        ToptranslationCli.configuration.load

        proj = project

        local_files = FileFinder.local_files(proj)
        remote_files = FileFinder.remote_files(proj)

        only_local, only_remote, changed = diff(local_files, remote_files)

        print_status(only_local, only_remote, changed)

        (only_local + only_remote + changed).length
      end

      private

        def diff(local, remote)
          only_local = local.keys - remote.keys
          only_remote = remote.keys - local.keys
          changed = changed_files(local, remote, only_local, only_remote)

          [only_local, only_remote, changed]
        end

        def changed_files(local, remote, only_local, only_remote)
          (local.to_a - remote.to_a | remote.to_a - local.to_a)
            .flat_map(&:first)
            .uniq - only_remote - only_local
        end

        def print_status(only_local, only_remote, changed)
          print_section 'Local: These documents exist only locally', only_local
          print_section 'Changed: These documents exist both locally and remotely but differ', changed
          print_section 'Remote: These documents exist only remotely', only_remote
        end

        def print_section(description, paths)
          return if paths.empty?

          puts <<~SECTION
            #{description}

            #{paths.sort.map { |path| "\t#{path}" }.join("\n")}

          SECTION
        end

        def project
          ToptranslationCli
            .connection
            .projects
            .find(ToptranslationCli.configuration.project_identifier)
        end
    end
  end
end
