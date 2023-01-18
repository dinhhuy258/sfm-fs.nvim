local config = require("sfm.extensions.sfm-fs.config")
local ctx = require("sfm.extensions.sfm-fs.context")

local M = {}

--- render selection for the given entry
---@return table
function M.render_selection(entry)
	if ctx.is_selected(entry) then
		return {
			text = config.opts.icons.selection .. " ",
			highlight = "SFMSelection",
		}
	end

	return {
		text = nil,
		highlight = nil,
	}
end

return M
