require "pagy"

options = {
  limit: 10,
  client_max_limit: 100,
  jsonapi: true,
  page_key: "page",
  limit_key: "limit"
}

options.each { |setting, value| Pagy::OPTIONS[setting] = value }
