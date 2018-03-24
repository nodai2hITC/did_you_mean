module DidYouMean
  module Correctable
    def original_message
      method(:to_s).super_method.call
    end

    def to_s
      msg = super.dup

      if !cause.respond_to?(:suggestions) || cause.suggestions.empty?
        msg << DidYouMean.formatter.message_for(suggestions)
      end

      msg
    rescue
      super
    end

    def suggestions
      spell_checker.suggestions
    end
    alias corrections suggestions

    def spell_checker
      @spell_checker ||= SPELL_CHECKERS[self.class.to_s].new(self)
    end
  end
end
