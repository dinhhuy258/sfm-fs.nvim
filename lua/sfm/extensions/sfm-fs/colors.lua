local M = {}

local function get_color_from_hl(hl_name, fallback)
	local id = vim.api.nvim_get_hl_id_by_name(hl_name)
	if not id then
		return fallback
	end

	local foreground = vim.fn.synIDattr(vim.fn.synIDtrans(id), "fg")
	if not foreground or foreground == "" then
		return fallback
	end

	return foreground
end

local function get_hl_groups()
	local blue = vim.g.terminal_color_4 or get_color_from_hl("Include", "Blue")

	return {
		SFMSelection = { fg = blue },
	}
end

function M.setup()
	local higlight_groups = get_hl_groups()
	for k, d in pairs(higlight_groups) do
		local gui = d.gui and " gui=" .. d.gui or ""
		local fg = d.fg and " guifg=" .. d.fg or ""
		local bg = d.bg and " guibg=" .. d.bg or ""
		vim.api.nvim_command("hi def " .. k .. gui .. fg .. bg)
	end
end

return M
