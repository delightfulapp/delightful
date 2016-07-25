require 'droplet_kit'

module Fastlane
  module Actions
    module SharedValues
      CREATE_DROPLET_DROPLET = :CREATE_DROPLET_DROPLET
    end

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/fastlane/fastlane/tree/master/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class CreateDropletAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        token = File.read('./d_o_key')
        client = DropletKit::Client.new(access_token: token)
        droplet = DropletKit::Droplet.new(
          name: 'trovebox-demo',
          region: 'nyc3',
          size: '512mb',
          image: 'ubuntu-14-04-x64',
          ssh_keys: ['b7:5a:fe:8a:7b:e7:a4:8e:25:50:cc:f7:ad:b5:47:f9']
        )
        created = client.droplets.create(droplet)
        UI.message "Created Droplet ID: #{created.id}"
        droplet_ip = nil
        droplet_status = nil
        while droplet_ip == nil && droplet_status != 'active' && droplet_ip != ''
          drop = client.droplets.find(id: created.id)
          if drop['networks'] && drop['networks']['v4'] && drop['networks']['v4'][0]
            droplet_ip = drop['networks']['v4'][0]['ip_address']
          end
          if drop['status']
            droplet_status = drop['status']
          end
        end
        UI.message "Created Droplet IP address: #{droplet_ip}"

        Actions.lane_context[SharedValues::CREATE_DROPLET_DROPLET] = {
          'id' => created.id,
          'ip' => droplet_ip
        }
        #

        # sh "shellcommand ./path"

        # Actions.lane_context[SharedValues::CREATE_DROPLET_CUSTOM_VALUE] = "my_val"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_CREATE_DROPLET_API_TOKEN", # The name of the environment variable
                                       description: "API Token for CreateDropletAction", # a short description of this parameter
                                       verify_block: proc do |value|
                                          UI.user_error!("No API token for CreateDropletAction given, pass using `api_token: 'token'`") unless (value and not value.empty?)
                                          # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :development,
                                       env_name: "FL_CREATE_DROPLET_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one",
                                       is_string: false, # true: verifies the input is a string, false: every kind of value
                                       default_value: false) # the default value if the user didn't provide one
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['CREATE_DROPLET_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["Your GitHub/Twitter Name"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #

        platform == :ios
      end
    end
  end
end
