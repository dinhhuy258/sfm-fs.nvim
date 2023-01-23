local api = require("sfm.api")

local config = require("sfm.extensions.sfm-fs.config")
local ctx = require("sfm.extensions.sfm-fs.context")

local M = {
	_sign_name = "sfm-fs-selection",
	_sign_group = "sfm-fs",
	_sign_id = nil,
}

--- init selection sign
function M.init_sign()
	M._sign_id = vim.fn.sign_define(M._sign_name, { text = config.opts.icons.selection, texthl = "SFMSelection" })
end

--- render all selection signs
---@param bufnr integer
function M.render_selection_in_sign(bufnr)
	vim.fn.sign_unplace(M._sign_group)
	local bufname = vim.api.nvim_buf_get_name(bufnr)

	local entries = api.entry.all()
	for lnum, entry in ipairs(entries) do
		if ctx.is_selected(entry) then
			vim.fn.sign_place(M._sign_id, M._sign_group, M._sign_name, bufname, {
				lnum = lnum,
				priority = 1,
			})
		end
	end
end

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
