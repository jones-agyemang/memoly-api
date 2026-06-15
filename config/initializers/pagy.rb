require "pagy"

options = {
  limit: 25,
  client_max_limit: 100,
  page_key: "page",
  limit_key: "limit"
}

options.each { |setting, value| Pagy::OPTIONS[setting] = value }
