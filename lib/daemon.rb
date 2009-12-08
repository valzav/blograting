require 'logger'

class Daemon
  $AFTER_TASK_SLEEP_TIME = 1

  attr_reader :log, :logfile, :pidfile

  def initialize
    @pidfile = "log/#{self.class.to_s.downcase}.pid"
    @logfile = "log/#{self.class.to_s.downcase}.log"
    @args = nil
  end

  def run
    @args = ARGV
    param = @args[0]
    unless param
      puts "Usage: ruby #{self.class.to_s.downcase}.rb [start|stop|restart|task]"
      return
    end

    if param == "start"
      start()
    elsif param == "stop"
      stop()
    elsif param == "restart"
      restart()
    elsif param == "task"
      @log = Logger.new(STDOUT)
      @log.level = Logger::DEBUG
      task()
    else
      puts "Daemon: Unknown command - #{param}"
      puts "Usage: ruby #{self.class.to_s.downcase}.rb [start|stop|restart|task]"
    end
  end

  def wexitstatus(s)
    (s >> 8) & 0xff
  end

  def start
    puts "starting in daemon mode.."

    @log = Logger.new(@logfile)
    @log.level = Logger::DEBUG
    @log.formatter = proc{|s,t,p,m|"%5s [%s] %s\n" % [s, t.strftime("%Y-%m-%d %H:%M:%S"), m]}

    $stdin.close
    $stdout.reopen(@logfile)

    log.debug "before fork"
    exit!(0) if fork
    Process.setsid
  
    while(true) do

      pid = fork do
        Signal.trap("TERM") { exit!(100) }
        while(true) do
          begin
            task()
            log.info "----------------------------"
          rescue Exception => e
            log.error "task failed, exception: #{e.to_s}\n#{e.backtrace.join("\n")}"
          end
          sleep($AFTER_TASK_SLEEP_TIME)
        end
      end

      File.open(@pidfile,"w") { |f| f << "#{pid}\n" }
      log.info "worker's pid : #{pid}"
      pid, status = Process.waitpid2(pid)
      break if wexitstatus(status) == 100
      log.error "worker #{pid} exited with status #{wexitstatus(status)}"
      sleep(10)
    end
    File.unlink(@pidfile)
    log.info "process finished"
  end

  def stop
    unless File.exists?(@pidfile)
      puts "this process doesn't seem to be running"
      return
    end
    pid = ""
    File.open(@pidfile,"r"){ |f| pid = f.readline.to_i }
    puts "pid to stop #{pid}"
    Process.kill("TERM",pid)
    while(true)
      sleep(1)
      break unless File.exists?(@pidfile)
      puts "waiting while process #{pid} is finished.."
    end
  end

  def restart
    stop()
    start()
  end

end


