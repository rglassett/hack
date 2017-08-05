module CoreExtensions
  module String
    def strip_heredoc
      leading_indents = scan(/^[ \t]*(?=\S)/)
      indent_level = leading_indents.any? ? leading_indents.min.size : 0
      gsub(/^[ \t]{#{indent_level}}/, '')
    end
  end
end
