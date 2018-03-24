require 'test_helper'

class VariableNameCheckTest < Minitest::Test
  class User
    def initialize
      @email_address = 'email_address@address.net'
      @first_name    = nil
      @last_name     = nil
    end

    def first_name; end
    def to_s
      "#{@first_name} #{@last_name} <#{email_address}>"
    end

    private

    def cia_codename; "Alexa" end
  end

  module UserModule
    def from_module; end
  end

  def setup
    @user = User.new.extend(UserModule)
  end

  def test_suggestions_include_instance_method
    error = assert_raises(NameError) do
      @user.instance_eval { flrst_name }
    end

    @user.instance_eval do
      remove_instance_variable :@first_name
      remove_instance_variable :@last_name
    end

    assert_suggestion :first_name, error.suggestions
    assert_match "Did you mean?  first_name", error.to_s
  end

  def test_suggestions_include_method_from_module
    error = assert_raises(NameError) do
      @user.instance_eval { fr0m_module }
    end

    assert_suggestion :from_module, error.suggestions
    assert_match "Did you mean?  from_module", error.to_s
  end

  def test_suggestions_include_local_variable_name
    person = person = nil
    error = (eprson rescue $!) # Do not use @assert_raises here as it changes a scope.

    assert_suggestion :person, error.suggestions
    assert_match "Did you mean?  person", error.to_s
  end

  def test_suggestions_include_ruby_predefined_objects
    some_var = nil

    false_error = assert_raises(NameError) do
      some_var = fals
    end

    true_error = assert_raises(NameError) do
      some_var = treu
    end

    nil_error = assert_raises(NameError) do
      some_var = nol
    end

    assert_suggestion :false, false_error.suggestions
    assert_match "Did you mean?  false", false_error.to_s

    assert_suggestion :true, true_error.suggestions
    assert_match "Did you mean?  true", true_error.to_s

    assert_suggestion :nil, nil_error.suggestions
    assert_match "Did you mean?  nil", nil_error.to_s
  end

  def test_suggestions_include_instance_variable_name
    error = assert_raises(NameError){ @user.to_s }

    assert_suggestion :@email_address, error.suggestions
    assert_match "Did you mean?  @email_address", error.to_s
  end

  def test_suggestions_include_private_method
    error = assert_raises(NameError) do
      @user.instance_eval { cia_code_name }
    end

    assert_suggestion :cia_codename, error.suggestions
    assert_match "Did you mean?  cia_codename",  error.to_s
  end

  @@does_exist = true

  def test_suggestions_include_class_variable_name
    error = assert_raises(NameError){ @@doesnt_exist }

    assert_suggestion :@@does_exist, error.suggestions
    assert_match "Did you mean?  @@does_exist", error.to_s
  end

  def test_struct_name_error
    value = Struct.new(:does_exist).new
    error = assert_raises(NameError){ value[:doesnt_exist] }

    assert_suggestion [:does_exist, :does_exist=], error.suggestions
    assert_match "Did you mean?  does_exist", error.to_s
  end

  def test_exclude_typical_incorrect_suggestions
    error = assert_raises(NameError){ foo }
    assert_empty error.suggestions
  end
end
