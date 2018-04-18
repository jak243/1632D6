require './methods.rb'

if ARGV.size !=0
    ARGV.each do |arg|
        begin
            File.open(arg, "r") do |f|
                f.each_line do |line|
                    input_stack = line.chomp().gsub(/\s+/m, ' ').strip.split(" ")
                    process(input_stack)
                    @lines += 1
                end 
            end 
        rescue IOError => e
            print "\nThere has been an error opening the file #{arg}. \"#{e}\" Exiting!"
            exit
        rescue Errno::ENOENT => e
            print "\nThere has been an error opening the file #{arg}.\n\"#{e}\" \nExiting!"
            exit
        end 
    end
    exit
end

while true
    print "> "
    input = " "
    begin
        input = gets
    rescue Interrupt
        exit
    end
    if !input.nil?
        begin
            input_stack = input.chomp().gsub(/\s+/m, ' ').strip.split(" ")
            result = process_repl(input_stack)
            if !result.nil?
                print "#{result.to_s}\n"
            end
        rescue RPNError => e
            print("Line #{@lines}: #{e}\n")
        end
    end
    @lines += 1
end
