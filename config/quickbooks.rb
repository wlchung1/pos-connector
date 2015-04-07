case ENV['APP_ENV']
when 'development'
  Quickbooks.sandbox_mode = true
  ENV['QB_CONSUMER_KEY'] = 'qyprdPLpxG0V2SEVLMegEN7Pk5oXN3'
  ENV['QB_CONSUMER_SECRET'] = 'CXegh7Ld9R1mzySEDIOuMZNrYLWVy1zUrzCwymty'
end
