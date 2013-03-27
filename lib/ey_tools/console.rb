require 'ey_tools/base'

module EY
  module Tools
    module Console
      class CLI < EY::Tools::CLI::Base
        default_task :console

        desc "console [--environment ENVIRONMENT]", "Open Rails console in environment."

        long_desc <<-DESC
          This command must be run Rails console based on settings in your ey.yml file.
        DESC
        method_option :environment, :type => :string, :aliases => %w(-e),
          :required => true, :default => false,
          :desc => "Environment in which to deploy this application"

        def console
          app_env = fetch_app_environment(options[:app], options[:environment], options[:account])

          hosts = ssh_hosts(options, app_env.environment)

          raise NoCommandError.new if hosts.size != 1

          exits = hosts.map do |host|
            system Escape.shell_command(['ssh', '-t', "#{app_env.environment.username}@#{host}", "cd /data/#{app_env.app.name}/current; RAILS_ENV=production bundle exec rails c"].compact)
            $?.exitstatus
          end
          exit exits.detect {|status| !status.zero?} || 0
        end
      end
    end
  end
end