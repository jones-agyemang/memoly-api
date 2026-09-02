module CorrespondenceHelper
  QUOTES_FILE_PATH = "docs/quotes.yml".freeze

  def get_quote
    YAML.load_file(QUOTES_FILE_PATH).dig("quotes").sample
  end
end
