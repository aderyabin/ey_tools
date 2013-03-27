require 'engineyard'
require 'engineyard/error'
require 'engineyard/thor'
require 'engineyard/deploy_config'
require 'engineyard/serverside_runner'
require 'launchy'

module EY
  module Tools
    module CLI
      class Base < EY::Thor
        require 'engineyard/cli/recipes'
        require 'engineyard/cli/web'
        require 'engineyard/cli/api'
        require 'engineyard/cli/ui'
        require 'engineyard/error'
        require 'engineyard-cloud-client/errors'

        include Thor::Actions

        def self.start(given_args=ARGV, config={})
          Thor::Base.shell = EY::CLI::UI
          ui = EY::CLI::UI.new
          super(given_args, {:shell => ui}.merge(config))
        rescue EY::Error, EY::CloudClient::Error => e
          ui.print_exception(e)
          exit 1
        rescue Interrupt => e
          puts
          ui.print_exception(e)
          ui.say("Quitting...")
          raise
        rescue SystemExit, Errno::EPIPE
          # don't print a message for safe exits
          raise
        rescue Exception => e
          ui.print_exception(e)
          raise
        end

        no_tasks do
          def ssh_host_filter(opts)
            return lambda {|instance| true }                                                if opts[:all]
            return lambda {|instance| %w(solo app app_master    ).include?(instance.role) } if opts[:app_servers]
            return lambda {|instance| %w(solo db_master db_slave).include?(instance.role) } if opts[:db_servers ]
            return lambda {|instance| %w(solo db_master         ).include?(instance.role) } if opts[:db_master  ]
            return lambda {|instance| %w(db_slave               ).include?(instance.role) } if opts[:db_slaves  ]
            return lambda {|instance| %w(util).include?(instance.role) && opts[:utilities].include?(instance.name) } if opts[:utilities]
            return lambda {|instance| %w(solo app_master        ).include?(instance.role) }
          end

          def ssh_hosts(opts, environment)
            if opts[:utilities] and not opts[:utilities].respond_to?(:include?)
              includes_everything = []
              class << includes_everything
                def include?(*) true end
              end
              filter = ssh_host_filter(opts.merge(:utilities => includes_everything))
            else
              filter = ssh_host_filter(opts)
            end

            instances = environment.instances.select {|instance| filter[instance] }
            raise NoInstancesError.new(environment.name) if instances.empty?
            return instances.map { |instance| instance.public_hostname }
          end
        end
      end
    end
  end
end