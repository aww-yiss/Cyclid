# Top level module for the core Cyclid code.
module Cyclid
  # Module for the Cyclid API
  module API
    # Module for Cyclid Plugins
    module Plugins
      # Ubuntu provisioner
      class Ubuntu < Provisioner
        # Prepare an Ubuntu based build host
        def prepare(transport, buildhost, env = {})
          if env.key? :repos
            env[:repos].each do |repo|
              next unless repo.key? :url

              # Check if it's a PPA, or a traditional repository
              url = repo[:url]
              match = url.match(/\A(ppa|http|https):.*\Z/)
              next unless match

              case match[1]
              when 'ppa'
                add_ppa_repository(transport, url)
              when 'http', 'https'
                add_http_repository(transport, url, repo, buildhost)
              end
            end

            success = transport.exec 'sudo apt-get update'
            raise 'failed to update repositories' unless success
          end

          env[:packages].each do |package|
            success = transport.exec "sudo apt-get install -y #{package}"
            raise "failed to install package #{package}" unless success
          end if env.key? :packages
        rescue StandardError => ex
          Cyclid.logger.error "failed to provision #{buildhost[:name]}: #{ex}"
          raise
        end

        private

        def add_ppa_repository(transport, url)
          success = transport.exec "sudo apt-add-repository -y #{url}"
          raise "failed to add repository #{url}" unless success
        end

        def add_http_repository(transport, url, repo, buildhost)
          raise 'an HTTP repository must provide a list of components' \
            unless repo.key? :components

          # Create a sources.list.d fragment
          release = buildhost[:release]
          components = repo[:components]
          fragment = "deb #{url} #{release} #{components}"

          success = transport.exec \
            "sudo echo '#{fragment}' >> /etc/apt/sources.list.d/cyclid.list"
          raise "failed to add repository #{url}" unless success

          if repo.key? :key_id
            # Import the signing key
            key_id = repo[:key_id]

            success = transport.exec \
              "gpg --keyserver keyserver.ubuntu.com --recv-keys #{key_id}"
            raise "failed to import key #{key_id}" unless success

            success = transport.exec \
              "gpg -a --export #{key_id} | sudo apt-key add -"
            raise "failed to add repository key #{key_id}" unless success
          end
        end

        # Register this plugin
        register_plugin 'ubuntu'
      end
    end
  end
end
