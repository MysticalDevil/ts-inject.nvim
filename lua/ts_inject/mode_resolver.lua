local M = {}

local query_store = require("ts_inject.query_store")

function M.normalize_enable(enable)
  local normalized = {}
  local supported = query_store.supported_languages()

  for lang, value in pairs(enable or {}) do
    if supported[lang] and value then
      normalized[lang] = true
    end
  end

  return normalized
end

function M.resolve_host_modes(query_mode, warnings)
  local supported = query_store.supported_languages()
  local generated = query_store.generated_languages()
  local host_modes = {}

  for host in pairs(query_mode or {}) do
    if not supported[host] then
      warnings[#warnings + 1] = ("%s: query_mode host is not supported"):format(host)
    end
  end

  for host in pairs(supported) do
    local requested_mode = query_mode and query_mode[host]
    if requested_mode == nil then
      host_modes[host] = generated[host] and "generated" or "static"
    elseif requested_mode == "generated" then
      if generated[host] then
        host_modes[host] = "generated"
      else
        host_modes[host] = "static"
        warnings[#warnings + 1] = ("%s: generated mode is not supported; using static"):format(host)
      end
    elseif requested_mode == "static" then
      host_modes[host] = "static"
      if generated[host] then
        warnings[#warnings + 1] = ("%s: static mode is legacy and not recommended"):format(host)
      end
    else
      host_modes[host] = generated[host] and "generated" or "static"
      warnings[#warnings + 1] = ("%s: unsupported query_mode %q; using default"):format(host, tostring(requested_mode))
    end
  end

  return host_modes
end

return M
