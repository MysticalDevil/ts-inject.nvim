; extends

([
  (interpreted_string_literal_content)
  (raw_string_literal_content)
] @injection.content
  (#match?
    @injection.content
    "(SELECT|select|INSERT|insert|UPDATE|update|DELETE|delete).+(FROM|from|INTO|into|VALUES|values|SET|set).*(WHERE|where|GROUP BY|group by)?")
  (#set! injection.language "sql"))

([
  (interpreted_string_literal_content)
  (raw_string_literal_content)
] @injection.content
  (#match?
    @injection.content
    "(CREATE|create)[[:space:]]+(TABLE|table|INDEX|index|VIEW|view|TRIGGER|trigger)")
  (#set! injection.language "sql"))

([
  (interpreted_string_literal_content)
  (raw_string_literal_content)
] @injection.content
  (#match?
    @injection.content
    "(ALTER|alter|DROP|drop|TRUNCATE|truncate)[[:space:]]+(TABLE|table|INDEX|index|VIEW|view|TRIGGER|trigger|COLUMN|column)")
  (#set! injection.language "sql"))

([
  (interpreted_string_literal_content)
  (raw_string_literal_content)
] @injection.content
  (#match?
    @injection.content
    "(BEGIN|begin)[[:space:]]*;|(COMMIT|commit)[[:space:]]*;|(ROLLBACK|rollback)[[:space:]]*;")
  (#set! injection.language "sql"))

([
  (interpreted_string_literal_content)
  (raw_string_literal_content)
] @injection.content
  (#match?
    @injection.content
    "([[:space:][:punct:]]REFERENCES[[:space:]])|([[:space:][:punct:]]FOREIGN[[:space:]]+KEY[[:space:]])|([[:space:][:punct:]]PRIMARY[[:space:]]+KEY[[:space:][:punct:]])|([[:space:][:punct:]]NOT[[:space:]]+NULL[[:space:][:punct:]])|([[:space:][:punct:]]DEFAULT[[:space:]])|(--[[:space:]]*sql)")
  (#set! injection.language "sql"))
