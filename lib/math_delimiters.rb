module MathDelimiters
  # Convert single-dollar inline math to double-dollar, avoiding \$ escapes and avoiding $$…$$
  def self.normalize_inline(text)
    # text.gsub(/(?<!\\)\$(?!\$)(.+?)(?<!\\)\$(?!\$)/m, '$$\1$$')
    text.gsub(/(?<!\\)(?<!\$)\$(?!\$)(.+?)(?<!\\)(?<!\$)\$(?!\$)/m, '$$\1$$')
  end
end
