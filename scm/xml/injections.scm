; extends

; MyBatis mapper SQL statement bodies.
(
  (element
    (STag
      (Name) @_tag)
    (content
      (CharData) @injection.content)
    (ETag
      (Name) @_end_tag))
  (#any-of? @_tag
    "select"
    "insert"
    "update"
    "delete"
    "sql")
  (#any-of? @_end_tag
    "select"
    "insert"
    "update"
    "delete"
    "sql")
  (#set! injection.language "sql")
)

; MyBatis mapper SQL inside CDATA.
(
  (element
    (STag
      (Name) @_tag)
    (content
      (CDSect
        (CData) @injection.content))
    (ETag
      (Name) @_end_tag))
  (#any-of? @_tag
    "select"
    "insert"
    "update"
    "delete"
    "sql")
  (#any-of? @_end_tag
    "select"
    "insert"
    "update"
    "delete"
    "sql")
  (#set! injection.language "sql")
)
