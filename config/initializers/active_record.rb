::ActiveSupport::Cache.format_version = 7.1
# Skip printing SQL queries in the logs
::ActiveRecord::Base.logger.level = ::Logger::INFO