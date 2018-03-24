# frozen-string-literal: true

module DidYouMean
  class PlainFormatter
    def message_for(suggestions)
      suggestions.empty? ? "" : "\nDid you mean?  #{suggestions.join("\n               ")}"
    end
  end
end
