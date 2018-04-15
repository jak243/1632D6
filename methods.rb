@variables = Array.new
@values = Array.new
@lines = 0

#type of input
#1 simple arithmetic
#2 LET
#3 PRINT
#0 QUIT
#-1 something is wrong

def process(input_stack)
    type = what_type(input_stack[0])
    if type == 0
        exit
    elsif type == 1
        return arithmetic(input_stack)
    elsif type == 2
        return let(input_stack)
    elsif type == 3
        return print_stk(input_stack)
    else
        return "error in the first token"
    end

    return result
end

class String
    def is_i?
       /\A[-+]?\d+\z/ === self
    end

    def is_letter?
        self =~ /[[:alpha:]]/
    end 

    def is_operation?
        return ["+","-","*","/"].include?(self)
    end 
end

def is_validToken?(token)
    if token.is_i?
        return true
    elsif token.is_letter?
        return @variables.include? token.downcase
    else
        return true
    end 
end

def what_type(firstToken)
    if firstToken.nil?
        return -1
    elsif(firstToken.casecmp("LET") == 0)
        return 2
    elsif (firstToken.casecmp("Print") == 0)
        return 3
    elsif (firstToken.casecmp("QUIT") == 0)
        return 0
    elsif firstToken.is_letter? && firstToken.length == 1 
        return 1
    elsif firstToken.is_i?
        return 1
    else
        return -1
    end    
end

def print_stk(input_stack)
    input_stack.shift
    return arithmetic(input_stack)
end

def arithmetic(input_stack)
    vars = Array.new
    input_stack.each do |token|
        if token.is_operation?
            if vars.length < 2
                print "error of too many operations"
                return -1
            end
            var1 = vars.pop
            var2 = vars.pop
            vars.push(operate(token,var2,var1).to_s)
        elsif is_validToken?(token)
            vars.push(token)
        end
    end
    if vars.length != 1
        print "error of too many numbers"
        return -1
    else
        returnval = vars.pop
        if returnval.is_letter?
            return @values[@variables.index(returnval.downcase)]
        else
            return returnval.to_i
        end
    end
end

def operate(operation, var1, var2)
    val1 = 0
    if var1.is_letter?
        @variables.index(var1)
        val1 = @values[@variables.index(var1.downcase)]
    else
        val1 = var1.to_i
    end 
    val2 = 0
    if var2.is_letter?
        @variables.index(var2)
        val2 = @values[@variables.index(var2.downcase)]
    else
        val2 = var2.to_i
    end 

    case operation
    when "+"
        return val1+val2
    when "-"
        return val1-val2
    when "*"
        return val1*val2
    when "/"
        return val1/val2
    end
end 


def let(input_stack)
    input_stack.shift
    if input_stack.length == 0
        print "no token error"
        return -1
    end
    varname = input_stack.shift
    if !varname.is_letter?
        print "not valid variable token error"
        return -1
    end
    result = arithmetic(input_stack)
    if @variables.include? varname.downcase
        @values[@variables.index(varname.downcase)] = result.to_i
    else
        @variables << varname.downcase
        @values << result.to_i
    end 
    return result
end