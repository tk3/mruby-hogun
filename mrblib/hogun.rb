class Hogun
  def self.desc(usage, description)
    @previous_defined ||= []
    current_defined = instance_methods(false)
    diff = current_defined - @previous_defined
    if diff.length > 0    # TODO: 
      @command_config ||= {}
      @command_config[diff[0]] = @variables
      @variables = {}
    end
    @variables ||= {}
    @variables[:desc] = {:usage => usage, :description => description}
    @previous_defined = instance_methods(false)
  end

  def self.start(argv = ARGV)
    current_defined = instance_methods(false)
    diff = current_defined - @previous_defined
    if diff.length > 0    # TODO: 
      @command_config ||= {}
      @command_config[diff[0]] = @variables
    end

    cmd = ARGV[0] || ""
    if cmd.empty? || (cmd == "help" && argv.length == 1)
      print_usage
      return 0
    end
    if cmd == "help" && argv.length > 1
      return print_command_help(argv[1])
    end

    task = self.new
    if !task.respond_to?(cmd.to_sym)
      $stderr.puts %Q(Could not find command "#{cmd}".)
      return 1
    end

    task_argv = argv.dup.drop(1)
    task.send(cmd.to_sym, *(task_argv))
  rescue ArgumentError => e
    $stderr.puts %Q(ERROR: "#{$0} #{cmd}" was called with arguments #{task_argv})
  end

  private
  def self.print_usage
    puts "Commands:"

    @command_config.each_key do |key|
      desc = @command_config[key][:desc]
      puts "  %s" % [$0 + " " + desc[:usage] +  "  # " + desc[:description]]
    end

    puts "  #{$0} help [COMMAND]  # Describe available commands or one specific command"
    puts ""
  end

  def self.print_command_help(cmd)
    unless @command_config.key?(cmd.to_sym)
      $stderr.puts %Q(Could not find command "#{cmd}".)
      return 1
    end
    desc = @command_config[cmd.to_sym][:desc]

    puts "Usage:"
    puts "  %s" % [$0 + " " + desc[:usage]]
    puts ""
    puts "%s" % [desc[:description]]

    return 0
  end
end
