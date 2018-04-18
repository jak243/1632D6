require 'simplecov'
require 'minitest/autorun'
SimpleCov.start
require './rpnclasses.rb'


class MethodsTest < Minitest::Test
  def setup
    @i = RPN.new
  end

  def test_what_type_nil_or_whitespace
    assert_equal -1, @i.what_type(nil)
    assert_equal -1, @i.what_type('')
    assert_equal -1, @i.what_type(' ')
    assert_equal -1, @i.what_type('   ')
  end

  def test_what_type_let
    assert_equal 2, @i.what_type('LET')
    assert_equal 2, @i.what_type('LeT')
    assert_equal 2, @i.what_type('let')
  end

  def test_what_type_print
    assert_equal 3, @i.what_type('PRInt')
    assert_equal 3, @i.what_type('PRINT')
    assert_equal 3, @i.what_type('print')
  end

  def test_what_type_print
    assert_equal 0, @i.what_type('QUiT')
    assert_equal 0, @i.what_type('QUIT')
    assert_equal 0, @i.what_type('quit')
  end

  def test_what_type_letter_or_int
    assert_equal 1, @i.what_type('123')
    assert_equal 1, @i.what_type('-123')
    assert_equal 1, @i.what_type('-1212323333333333')
    assert_equal 1, @i.what_type('a')
    assert_equal 1, @i.what_type('p')
    assert_equal 1, @i.what_type('T')
    assert_equal 1, @i.what_type('A')
  end

  def test_what_type_non_integer_number
    assert_raises OtherError do
      @i.what_type('1.1')
    end
    assert_raises OtherError do
      @i.what_type('-1.1')
    end
  end

  def test_what_type_invalid_keyword
    assert_raises UnkownKeyword do
      @i.what_type('taco')
    end
    assert_raises UnkownKeyword do
      @i.what_type('8j,4.')
    end
  end

  def test_process_print_called
    stack = %w[print 4]
    assert_output("4\n", nil) { @i.process(stack) }
  end

  def test_process_print_not_called
    int = RPN.new
    stack1 = %w[Let a 4]
    stack3 = ['3', '4', '+']
    stack4 = ['4']
    assert_silent { int.process(stack1) }
    assert_silent { int.process(stack3) }
    assert_silent { int.process(stack4) }
  end

  def test_process_repl_print_not_called
    int = RPN.new
    stack1 = %w[Let a 4]
    stack2 = %w[print 5]
    stack3 = ['3', '4', '+']
    stack4 = ['4']
    assert_silent { int.process_repl(stack1) }
    assert_silent { int.process_repl(stack2) }
    assert_silent { int.process_repl(stack3) }
    assert_silent { int.process_repl(stack4) }
  end

  def test_valid_token_int
    int = RPN.new
    assert int.valid_token?('-1')
    assert int.valid_token?('-9999999999999999999999999999')
    assert int.valid_token?('100000000000000099999999999999999990000000')
    assert int.valid_token?('200')
    assert int.valid_token?('0')
  end

  def test_valid_token_letter
    int = RPN.new
    int.variables = %w[a b z l]
    assert int.valid_token?('a')
    assert int.valid_token?('B')
    assert int.valid_token?('Z')
    assert int.valid_token?('L')
    assert int.valid_token?('l')
  end

  def test_valid_token_invalid
    int = RPN.new
    assert_raises UnkownKeyword do
      int.valid_token?('taco')
    end
    assert_raises OtherError do
      int.valid_token?('4.3')
    end

    assert_raises UninitializedVariable do
      int.valid_token?('a')
    end
  end

  def test_print_stk
    int = RPN.new
    stack1 = ['print', '5']
    int.variables << 'a'
    int.values << 5
    stack2 = ['print', 'a']
    stack3 = ['print', 'a', 'a', '+']
    stack4 = ['print', '-9']
    assert_equal 5, int.print_stk(stack1)
    assert_equal 5, int.print_stk(stack2)
    assert_equal 10, int.print_stk(stack3)
    assert_equal -9, int.print_stk(stack4)
  end

  def test_arithmetic_valid_ints
    int = RPN.new
    stack1 = ["5","-9","+"]
    stack2 = ["9999999999987890343999","234234149123491238471237482","-"]
    stack3 = ["4","6","*"]
    stack4 = ["32","4","/"]
    assert_equal -4,int.arithmetic(stack1)
    assert_equal -234224149123491250580893483,int.arithmetic(stack2)
    assert_equal 24,int.arithmetic(stack3)
    assert_equal 8,int.arithmetic(stack4)
  end

  def test_arithmetic_valid_variables
    int = RPN.new
    int.variables << "a"
    int.variables << "b"
    int.variables << "c"
    int.variables << "d"
    int.variables << "e"
    int.variables << "f"
    int.variables << "g"
    int.values << 5
    int.values << 9
    int.values << 9999999999987890343999
    int.values << 234234149123491238471237482
    int.values << 4
    int.values << 6
    int.values << 32
    stack1 = ["a","B","+"]
    stack2 = ["C","d","-"]
    stack3 = ["e","f","*"]
    stack4 = ["G","E","/"]
    assert_equal 14,int.arithmetic(stack1)
    assert_equal -234224149123491250580893483,int.arithmetic(stack2)
    assert_equal 24,int.arithmetic(stack3)
    assert_equal 8,int.arithmetic(stack4)
  end

  def test_arithmetic_too_many_ops
    int = RPN.new
    stack1 = ["5","9","+","+"]
    stack2 = ["-4","3","234","+","/","-"]
    stack3 = ["4","6","*","*"]
    stack4 = ["32","/"]

    assert_raises TooManyOperationsError do
        int.arithmetic(stack1)
    end
    assert_raises TooManyOperationsError do
        int.arithmetic(stack2)
    end
    assert_raises TooManyOperationsError do
        int.arithmetic(stack3)
    end
    assert_raises TooManyOperationsError do
        int.arithmetic(stack4)
    end
  end

  def test_arithmetic_too_many_elements_in_stack
    int = RPN.new
    stack1 = ["5","9"]
    stack2 = ["-4","3","234","-"]
    stack3 = ["4","6","3","*","*","4"]
    stack4 = ["32","-9"]

    assert_raises ElementsInStackAfterEval do
        int.arithmetic(stack1)
    end
    assert_raises ElementsInStackAfterEval do
        int.arithmetic(stack2)
    end
    assert_raises ElementsInStackAfterEval do
        int.arithmetic(stack3)
    end
    assert_raises ElementsInStackAfterEval do
        int.arithmetic(stack4)
    end
  end

  def test_operate_addition_ints
    int = RPN.new
    assert_equal 34, int.operate("+","21","13")
    assert_equal 823946819783116939437279, int.operate("+","995834593485984934","823945823948523453452345")
    assert_equal 1335399000087606092824, int.operate("+","-8000999912349249521","1343399999999955342345")
    assert_equal -34, int.operate("+","-21","-13")
  end

  def test_operate_addition_vars
    int = RPN.new
    int.variables << "a"
    int.variables << "b"
    int.variables << "c"
    int.variables << "d"
    int.variables << "e"
    int.variables << "f"
    int.variables << "g"
    int.variables << "h"
    int.values << 21
    int.values << 13
    int.values << 995834593485984934
    int.values << 823945823948523453452345
    int.values << -8000999912349249521
    int.values << 1343399999999955342345
    int.values << -21
    int.values << -13
    assert_equal 34, int.operate("+","a","b")
    assert_equal 823946819783116939437279, int.operate("+","c","d")
    assert_equal 1335399000087606092824, int.operate("+","e","f")
    assert_equal -34, int.operate("+","g","h")
  end

  def test_operate_subtraction_ints
    int = RPN.new
    assert_equal 8, int.operate("-","21","13")
    assert_equal -823944828113929967467411, int.operate("-","995834593485984934","823945823948523453452345")
    assert_equal -1351400999912304591866, int.operate("-","-8000999912349249521","1343399999999955342345")
    assert_equal -8, int.operate("-","-21","-13")
  end

  def test_operate_subtraction_vars
    int = RPN.new
    int.variables << "a"
    int.variables << "b"
    int.variables << "c"
    int.variables << "d"
    int.variables << "e"
    int.variables << "f"
    int.variables << "g"
    int.variables << "h"
    int.values << 21
    int.values << 13
    int.values << 995834593485984934
    int.values << 823945823948523453452345
    int.values << -8000999912349249521
    int.values << 1343399999999955342345
    int.values << -21
    int.values << -13
    assert_equal 8, int.operate("-","a","b")
    assert_equal -823944828113929967467411, int.operate("-","c","d")
    assert_equal -1351400999912304591866, int.operate("-","e","f")
    assert_equal -8, int.operate("-","g","h")
  end

  def test_operate_division_ints
    int = RPN.new
    assert_equal 1, int.operate("/","21","13")
    assert_equal 0, int.operate("/","995834593485984934","823945823948523453452345")
    assert_equal -168, int.operate("/","1343399999999955342345","-8000999912349249521",)
    assert_equal 30, int.operate("/","122","4")
    assert_raises OtherError do
        int.operate("/","4","0")
    end
  end

  def test_operate_multiplication_ints
    int = RPN.new
    assert_equal 273, int.operate("*","21","13")
    assert_equal 820513754646252763090869217894074956970230, int.operate("*","995834593485984934","823945823948523453452345")
    assert_equal -10748543282249624500617659276975382266745, int.operate("*","1343399999999955342345","-8000999912349249521",)
    assert_equal 488, int.operate("*","122","4")
  end

  def test_let_errors
    int = RPN.new
    stack1 = ["Let","9"]
    stack2 = ["Let","ab"]
    stack3 = ["Let"]
    assert_raises OtherError do
        int.let(stack1)
    end
    assert_raises OtherError do
        int.let(stack2)
    end
    assert_raises OtherError do
        int.let(stack3)
    end
  end 

  def test_let_initial
    int = RPN.new
    stack1 = ["Let","a","9"]
    stack2 = ["Let","b","99999999999999999999"]
    stack3 = ["Let","c","-99999999999999999999999999999999999"]
    assert_equal 9, int.let(stack1)
    assert_equal 99999999999999999999, int.let(stack2)
    assert_equal -99999999999999999999999999999999999, int.let(stack3)

    assert_equal 9, int.values[int.variables.index("a".downcase)]
    assert_equal 99999999999999999999, int.values[int.variables.index("b".downcase)]
    assert_equal -99999999999999999999999999999999999, int.values[int.variables.index("c".downcase)]
  end 

  def test_string_i
    assert "-1".i?
    assert "-100".i?
    assert "0".i?
    assert "-9999999999999999999999999999999999999999999999".i?
    assert "99999999999999999999999999999999999999999999993923".i?
    assert "54".i?
    assert "12435643214567543567543396486749385730948745869".i?
  end

  def test_string_i_not
    refute "-1.3".i?
    refute "a".i?
    refute "asd7fds".i?
    refute "-99.99999999999999999999999999999999999999999999".i?
    refute "LET".i?
    refute "@!@#".i?
    refute "^".i?
  end

  def test_string_letter
    assert "a".letter?
    assert "A".letter?
    assert "y".letter?
    assert "Z".letter?
    assert "q".letter?
  end

  def test_string_letter_not
    refute "-1.3".letter?
    refute "ab".letter?
    refute "asd7fds".letter?
    refute "-99.99999999999999999999999999999999999999999999".letter?
    refute "LET".letter?
    refute "@!@#".letter?
    refute "^".letter?
  end

  def test_string_operation
    assert "+".operation?
    assert "-".operation?
    assert "*".operation?
    assert "/".operation?
  end

  def test_string_operation_not
    refute "-1.3".operation?
    refute "a+".operation?
    refute "q".operation?
    refute "asd7fds".operation?
    refute "-99.99999999999999999999999999999999999999999999".operation?
    refute "LET".operation?
    refute "@!@#".operation?
    refute "^".operation?
  end

  def test_string_numeric
    assert "4".numeric?
    assert "-234.234".numeric?
    assert "9999999999999999999999999999999999999999999999".numeric?
    assert "999999999999999999999999999999999999999999999999.3".numeric?
  end

  def test_string_numeric_not
    refute "-1.3n".numeric?
    refute "a+".numeric?
    refute "q".numeric?
    refute "asd7fds".numeric?
    refute "-99.99999999999999999.999999999999999999999999999".numeric?
    refute "LET".numeric?
    refute "@!@#".numeric?
    refute "^".numeric?
  end
end
