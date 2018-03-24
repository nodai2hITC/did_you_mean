require 'test_helper'

class MethodNameCheckTest < Minitest::Test
  class User
    def friends; end
    def first_name; end
    def descendants; end
    def call_incorrect_private_method
      raiae NoMethodError
    end

    def raise_no_method_error
      self.firstname
    rescue NoMethodError => e
      raise e, e.message, e.backtrace
    end

    protected
    def the_protected_method; end

    private
    def friend; end
    def the_private_method; end

    class << self
      def load; end
    end
  end

  module UserModule
    def from_module; end
  end

  def setup
    @user = User.new.extend(UserModule)
  end

  def test_suggestions_include_instance_method
    error = assert_raises(NoMethodError){ @user.flrst_name }

    assert_suggestion :first_name, error.suggestions
    assert_match "Did you mean?  first_name",  error.to_s
  end

  def test_suggestions_include_private_method
    error = assert_raises(NoMethodError){ @user.friend }

    assert_suggestion :friends, error.suggestions
    assert_match "Did you mean?  friends", error.to_s
  end

  def test_suggestions_include_method_from_module
    error = assert_raises(NoMethodError){ @user.fr0m_module }

    assert_suggestion :from_module, error.suggestions
    assert_match "Did you mean?  from_module", error.to_s
  end

  def test_suggestions_include_class_method
    error = assert_raises(NoMethodError){ User.l0ad }

    assert_suggestion :load, error.suggestions
    assert_match "Did you mean?  load", error.to_s
  end

  def test_private_methods_should_not_be_suggested
    error = assert_raises(NoMethodError){ User.new.the_protected_method }
    refute_includes error.suggestions, :the_protected_method

    error = assert_raises(NoMethodError){ User.new.the_private_method }
    refute_includes error.suggestions, :the_private_method
  end

  def test_suggestions_when_private_method_is_called_with_args
    error = assert_raises(NoMethodError){ @user.call_incorrect_private_method }

    assert_suggestion :raise, error.suggestions
    assert_match "Did you mean?  raise", error.to_s
  end

  def test_exclude_methods_on_nil
    error = assert_raises(NoMethodError){ nil.map }
    assert_empty error.suggestions
  end

  def test_does_not_exclude_custom_methods_on_nil
    def nil.empty?
    end

    error = assert_raises(NoMethodError){ nil.empty }
    assert_suggestion :empty?, error.suggestions
  ensure
    NilClass.class_eval { undef empty? }
  end

  def test_does_not_append_suggestions_twice
    error = assert_raises NoMethodError do
      begin
        @user.firstname
      rescue NoMethodError => e
        raise e, e.message, e.backtrace
      end
    end

    assert_equal 1, error.to_s.scan(/Did you mean/).count
  end

  def test_does_not_append_suggestions_three_times
    error = assert_raises NoMethodError do
      begin
        @user.raise_no_method_error
      rescue NoMethodError => e
        raise e, e.message, e.backtrace
      end
    end

    assert_equal 1, error.to_s.scan(/Did you mean/).count
  end
end
