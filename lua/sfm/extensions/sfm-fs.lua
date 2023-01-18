local event = require("sfm.event")

local config = require("sfm.extensions.sfm-fs.config")
local selection_renderer = require("sfm.extensions.sfm-fs.selection_renderer")

local M = {}

function M.setup(sfm_explorer, opts)
	config.setup(opts)

	sfm_explorer:subscribe(event.ExplorerOpened, function(payload)
		local bufnr = payload["bufnr"]
		local options = {
			noremap = true,
			silent = true,
			expr = false,
		}
		for _, map in pairs(config.opts.mappings.list) do
			if type(map.key) == "table" then
				for _, key in pairs(map.key) do
					vim.api.nvim_buf_set_keymap(
						bufnr,
						"n",
						key,
						"<CMD>lua require('sfm.extensions.sfm-fs.actions')." .. map.action .. "()<CR>",
						options
					)
				end
			else
				vim.api.nvim_buf_set_keymap(
					bufnr,
					"n",
					map.key,
					"<CMD>lua require('sfm.extensions.sfm-fs.actions')." .. map.action .. "()<CR>",
					options
				)
			end
		end
	end)

  -- indent(10), indicator(20), icon(30), selection(31), name(40)
  sfm_explorer:register_renderer("sfm-fs-selection", 39, selection_renderer.render_selection)
end

return M
