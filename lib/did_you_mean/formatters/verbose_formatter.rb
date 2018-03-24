# frozen-string-literal: true

module DidYouMean
  class VerboseFormatter
    def message_for(suggestions)
      return "" if suggestions.empty?

      output = "\n\n    Did you mean? ".dup
      output << suggestions.join("\n                  ")
      output << "\n "
    end
  end
end
