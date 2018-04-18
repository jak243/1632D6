require './rpnclasses.rb'

lines = 1
interpreter = RPN.new

unless ARGV.empty?
  ARGV.each do |arg|
    begin
      File.open(arg, 'r') do |f|
        f.each_line do |line|
          input_stack = line.chomp.gsub(/\s+/m, ' ').strip.split(' ')
          begin
            interpreter.process(input_stack)
          rescue RPNError => e
            print("Line #{lines}: #{e}\n")
            exit e.code
          end
          lines += 1
        end
      end
    rescue IOError => e
      print "\nThere has been an error opening the file #{arg}."
      print "\"#{e}\" Exiting!"
      exit 5
    rescue Errno::ENOENT => e
      print "\nThere has been an error opening the file #{arg}."
      print "\n\"#{e}\" \nExiting!"
      exit 5
    end
  end
  exit
end

loop do
  print '> '
  input = ' '
  begin
    input = gets
  rescue Interrupt
    exit 5
  end
  unless input.nil?
    begin
      input_stack = input.chomp.gsub(/\s+/m, ' ').strip.split(' ')
      result = interpreter.process_repl(input_stack)
      print "#{result}\n" unless result.nil?
    rescue RPNError => e
      print("Line #{lines}: #{e}\n")
    end
  end
  lines += 1
end
