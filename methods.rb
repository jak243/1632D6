@variables = Array.new
@values = Array.new
@lines = 1

def process(input_stack)
    type = what_type(input_stack[0])
    if type == 0
        exit
    elsif type == 1
        arithmetic(input_stack)
    elsif type == 2
        let(input_stack)
    elsif type == 3
        result  = print_stk(input_stack).to_s
        print("#{result}\n")
    else
        return nil
    end
end

def process_repl(input_stack)
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
        return nil
    end

    return result
end

class String
    def is_i?
       /\A[-+]?\d+\z/ === self
    end

    def is_letter?
        if self.length == 1
            self =~ /[[:alpha:]]/
        else 
            return false
        end
    end 

    def is_operation?
        return ["+","-","*","/"].include?(self)
    end 

    def numeric?
        return Float(self) != nil rescue false
    end
end

def is_validToken?(token)
    if token.is_i?
        return true
    elsif token.is_letter?        
        if !@variables.include? token.downcase
            raise UninitializedVariable.new(token)
        end 
        return true
    elsif !token.numeric?
        raise UnkownKeyword.new(token)
    elsif !token.is_i?
        raise OtherError("#{token} is not an integer")
    end 
end

def what_type(firstToken)
    if firstToken.nil? || firstToken =~ /^\s*$/
        return -1
    elsif(firstToken.casecmp("LET") == 0)
        return 2
    elsif (firstToken.casecmp("Print") == 0)
        return 3
    elsif (firstToken.casecmp("QUIT") == 0)
        return 0
    elsif firstToken.is_letter?
        return 1
    elsif firstToken.is_i?
        return 1
    elsif firstToken.numeric?
        raise OtherError.new("#{firstToken} is not an integer")
    else 
        raise UnkownKeyword.new(firstToken)
    end    
end

def print_stk(input_stack)
    input_stack.shift
    result = arithmetic(input_stack)
    return result
end

def arithmetic(input_stack)
    vars = Array.new
    input_stack.each do |token|
        if token.is_operation?
            if vars.length < 2
                raise TooManyOperationsError.new(token)
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
        raise ElementsInStackAfterEval.new(vars.length)
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
        if val2 == 0
            raise OtherError.new("Divide by zero error")
        end
        return val1/val2
    end
end

def let(input_stack)
    input_stack.shift
    if input_stack.length == 0
        raise OtherError.new("Let keyword with no stack")
        return -1
    end
    varname = input_stack.shift
    if !varname.is_letter?
        raise OtherError.new("#{varname} is not a valid variable following LET keyword")
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

class RPNError < StandardError
    def initialize(msg, code)
        @code = code 
        super(msg)
    end
end

class UninitializedVariable < RPNError 
    def initialize(variable)
        msg = "Variable #{variable.to_s} is not initialized"
        super(msg, 1)
    end
end


class TooManyOperationsError < RPNError 
    def initialize(operator)
        msg = "Operator #{operator.to_s} applied to empty stack"
        super(msg, 2)
    end
end

class ElementsInStackAfterEval < RPNError 
    def initialize(elements)
        msg = "#{elements.to_s} elements in stack after evaluation"
        super(msg, 3)
    end
end

class UnkownKeyword < RPNError 
    def initialize(keyword)
        msg = "Unkown keyword #{keyword.to_s.upcase}"
        super(msg, 4)
    end
end

class OtherError < RPNError 
    def initialize(msg)
        super(msg, 5)
    end
end