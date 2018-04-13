lines = 0


if ARGV.size !=0
    #run based on arg file
end



while true do
    print >
    input = gets
    input_stack = inputgsub(/\s+/m, ' ').strip.split(" ")
    result = process(input_stack)
    lines++
end 

#type of input
#1 simple arithmetic
#2 LET
#3 PRINT
#0 QUIT
#-1 something is wrong

def process(input_stack)
    type = what_type(input_stack[0])
end


def what_type(firstToken)
    case firstToken
    when firstToken.casecmp("LET")
        return 2
    when firstToken.casecmp("Print")
        return 3
    when firstToken.casecmp("LET")
        return 2
    when firstToken.casecmp("Print")
        return 3
end