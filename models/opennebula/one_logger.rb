module OpenNebula
  class OneLogger
    require 'logger'
    require 'sinatra'
    require 'rubygems'
    DEBUG_LEVEL = [
      Logger::ERROR, # 0
      Logger::WARN,  # 1
      Logger::INFO,  # 2
      Logger::DEBUG  # 3
    ]

    # Mon Feb 27 06:02:30 2012 [Clo] [E]: Error message example
    MSG_FORMAT  = %{%s [%s]: %s\n}

    # Mon Feb 27 06:02:30 2012
    DATE_FORMAT = "%a %b %d %H:%M:%S %Y"

    # Patch logger class to be compatible with Rack::CommonLogger
    class OpenLog < Logger
      def initialize(path)
        super(path)
      end

      def write(msg)
        info msg.chop
      end

      def add(severity, message = nil, progname = nil, &block)
        rc = super(severity, message, progname, &block)
        @logdev.dev.flush

        rc
      end
    end

    def initialize()

    end

    def enable_logging(path=nil, debug_level=3)
      path ||= $stdout
      logger = OpenLog.new(path)
      logger.level = DEBUG_LEVEL[debug_level]
      logger.formatter = proc do |severity, datetime, progname, msg|
        MSG_FORMAT % [
          datetime.strftime(DATE_FORMAT),
          severity[0..0],
          msg ]
      end

      # Add the logger instance to the Sinatra settings
      #set :logger, logger

      # The logging will be configured in Rack, not in Sinatra
      # disable :logging

      # Use the logger instance in the Rack  methods
      #use Rack::CommonLogger, logger

      #helpers do
      def logger
        settings.logger
      end
      # end

      logger
    end
  end
end