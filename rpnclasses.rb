# Class for rpn includes methods to do repl eval and file eval
class RPN
  attr_accessor :variables
  attr_accessor :values
  attr_accessor :lines

  def initialize
    @variables = []
    @values = []
  end

  def process(input_stack)
    type = what_type(input_stack[0])
    if type.zero?
      exit
    elsif type == 1
      arithmetic(input_stack)
    elsif type == 2
      let(input_stack)
    elsif type == 3
      result = print_stk(input_stack).to_s
      print("#{result}\n")
    else
      return nil
    end
  end

  def process_repl(input_stack)
    type = what_type(input_stack[0])
    if type.zero?
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

    result
  end

  def valid_token?(token)
    if token.i?
      true
    elsif token.letter?
      return true if @variables.include? token.downcase
      raise UninitializedVariable, token
    elsif !token.numeric?
      raise UnkownKeyword, token
    elsif !token.i?
      raise OtherError, "#{token} is not an integer"
    end
  end

  def what_type(first_token)
    if first_token.nil? || first_token =~ /^\s*$/
      -1
    elsif first_token.casecmp('LET').zero?
      2
    elsif first_token.casecmp('Print').zero?
      3
    elsif first_token.casecmp('QUIT').zero?
      0
    elsif first_token.letter? || first_token.i?
      1
    elsif first_token.numeric?
      raise OtherError, "#{first_token} is not an integer"
    else
      raise UnkownKeyword, first_token
    end
  end

  def print_stk(input_stack)
    input_stack.shift
    result = arithmetic(input_stack)
    result
  end

  def arithmetic(input_stack)
    vars = []
    input_stack.each do |token|
      if token.operation?
        raise TooManyOperationsError, token if vars.length < 2
        var1 = vars.pop
        var2 = vars.pop
        vars.push(operate(token, var2, var1).to_s)
      elsif valid_token?(token)
        vars.push(token)
      end
    end
    raise ElementsInStackAfterEval, vars.length if vars.length != 1
    returnval = vars.pop
    return @values[@variables.index(returnval.downcase)] if returnval.letter?
    returnval.to_i
  end

  def operate(operation, var1, var2)
    val1 = 0
    if var1.letter?
      @variables.index(var1)
      val1 = @values[@variables.index(var1.downcase)]
    else
      val1 = var1.to_i
    end
    val2 = 0
    if var2.letter?
      @variables.index(var2)
      val2 = @values[@variables.index(var2.downcase)]
    else
      val2 = var2.to_i
    end

    case operation
    when '+'
      return val1 + val2
    when '-'
      return val1 - val2
    when '*'
      return val1 * val2
    when '/'
      raise OtherError, 'Divide by zero error' if val2.zero?
      return val1 / val2
    end
  end

  def let(input_stack)
    input_stack.shift
    raise OtherError, 'Let keyword with no stack' if input_stack.empty?
    varname = input_stack.shift
    unless varname.letter?
      msg = "#{varname} is not a valid variable following LET keyword"
      raise OtherError, msg
    end
    result = arithmetic(input_stack)
    if @variables.include? varname.downcase
      @values[@variables.index(varname.downcase)] = result.to_i
    else
      @variables << varname.downcase
      @values << result.to_i
    end
    result
  end
end

# RPNError class that contains the exit code for the specific error
class RPNError < StandardError
  def initialize(msg, code)
    @code = code
    super(msg)
  end
end

# RPNError for when a variable is not initialized
class UninitializedVariable < RPNError
  def initialize(variable)
    msg = "Variable #{variable} is not initialized"
    super(msg, 1)
  end
end

# RPNError for when an operator is applied to an empty stack
class TooManyOperationsError < RPNError
  def initialize(operator)
    msg = "Operator #{operator} applied to empty stack"
    super(msg, 2)
  end
end

# RPNError for when there are more than 1 elements in the stack after eval
class ElementsInStackAfterEval < RPNError
  def initialize(elements)
    msg = "#{elements} elements in stack after evaluation"
    super(msg, 3)
  end
end

# RPNError for when there is an unknown keyword
class UnkownKeyword < RPNError
  def initialize(keyword)
    msg = "Unkown keyword #{keyword.to_s.upcase}"
    super(msg, 4)
  end
end

# Error with error code 5 to cover all RPNErrors not caught
class OtherError < RPNError
  def initialize(msg)
    super(msg, 5)
  end
end

# Modifications for the String Class
class String
  def i?
    self =~ /\A[-+]?\d+\z/
  end

  def letter?
    if length == 1
      self =~ /[[:alpha:]]/
    else
      false
    end
  end

  def operation?
    ['+', '-', '*', '/'].include?(self)
  end

  def numeric?
    !Float(self).nil?
  rescue StandardError
    false
  end
end
