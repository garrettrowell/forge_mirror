require 'logger'

module ForgeMirror
  def self.log
    if @logger.nil?
      @logger = Logger.new(STDOUT)
      @logger.formatter = proc { |severity, datetime, progname, msg| "#{severity} #{datetime}; #{progname}: #{msg}\n" }
    end
    @logger
  end
end
