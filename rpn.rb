require './methods.rb'



if ARGV.size !=0
    #run based on arg file
end



while true
    print "> "
    input = gets
    input_stack = input.chomp().gsub(/\s+/m, ' ').strip.split(" ")
    result = process(input_stack)
    print "#{result.to_s}\n"
    @lines += 1
end

#type of input
#1 simple arithmetic
#2 LET
#3 PRINT
#0 QUIT
#-1 something is wrong or nil

