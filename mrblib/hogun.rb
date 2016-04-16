class Hogun
  attr_accessor :options

  def initialize(opts)
    self.options = opts
  end

  def self.desc(usage, description)
    update_command_config
    @variables[:desc] = {:usage => usage, :description => description}
  end

  def self.option(name, options = {})
    update_command_config
    @variables[:option] ||= {}
    @variables[:option][name] = options
  end

  def self.start(argv = ARGV)
    update_command_config

    @args = argv.dup

    cmd = @args.shift || ""
    if cmd.empty? || (cmd == "help" && @args.empty?)
      print_usage
      return 0
    end
    if cmd == "help"
      return print_command_help(@args.first)
    end

    option_parser

    task = self.new(@options)
    if !task.respond_to?(cmd.to_sym)
      $stderr.puts %Q(Could not find command "#{cmd}".)
      return 1
    end
    
    task.send(cmd.to_sym, *(@args))
  rescue ArgumentError => e
    $stderr.puts %Q(ERROR: "#{$0} #{cmd}" was called with arguments #{@args})
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
    config = @command_config[cmd.to_sym]
    desc = config[:desc]

    puts "Usage:"
    puts "  #{$0} #{desc[:usage]}"
    puts

    if config.key?(:option)
      puts "Options:"
      config[:option].keys.each do |name|
        puts "  [--#{name} #{name.upcase}]"
      end
      puts
    end

    puts desc[:description]

    return 0
  end

  def self.update_command_config
    current_defined = instance_methods(false)
    @previous_defined ||= []
    @variables        ||= {}
    diff = current_defined - @previous_defined
    if diff.length > 0
      @command_config ||= {}
      @command_config[diff[0]] = @variables
      @variables = {}
    end
    @previous_defined = current_defined
  end

  def self.option_parser
    @options ||= {}

    while arg = @args.shift
      match = /^--(\w+)$/.match(arg)

      if match
        @options[match[1].to_sym] = @args.shift
      else
        @args.unshift(arg)
        break
      end
    end
  end
end
