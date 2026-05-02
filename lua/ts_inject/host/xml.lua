local M = {}

local util = require("ts_inject.host._util")

local function join_tags(items)
  local out = {}
  for _, item in ipairs(items or {}) do
    out[#out + 1] = util.q(item)
  end
  return table.concat(out, " ")
end

local function render_xml_tag(rule)
  local tags = join_tags(rule.tags)
  return {
    ([[
(
  (element
    (STag
      (Name) @_tag)
    (content
      (CharData) @injection.content)
    (ETag
      (Name) @_end_tag))
  (#any-of? @_tag %s)
  (#any-of? @_end_tag %s)
  (#set! injection.language %s))
]]):format(tags, tags, util.q(rule.lang)),
    ([[
(
  (element
    (STag
      (Name) @_tag)
    (content
      (CDSect
        (CData) @injection.content))
    (ETag
      (Name) @_end_tag))
  (#any-of? @_tag %s)
  (#any-of? @_end_tag %s)
  (#set! injection.language %s))
]]):format(tags, tags, util.q(rule.lang)),
  }
end

M.build = util.build_dispatcher({
  header = "; extends",
  renderers = {
    xml_tag = render_xml_tag,
  },
})

return M
