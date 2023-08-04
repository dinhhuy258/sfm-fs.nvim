local event = require("sfm.event")

local config = require("sfm.extensions.sfm-fs.config")
local colors = require("sfm.extensions.sfm-fs.colors")
local selection_renderer = require("sfm.extensions.sfm-fs.selection_renderer")
local ctx = require("sfm.extensions.sfm-fs.context")
local actions = require("sfm.extensions.sfm-fs.actions")
local api = require("sfm.api")

local M = {}

function M.setup(sfm_explorer, opts)
  -- deprecated
  api.log.warn("sfm-fs is deprecated, please use builtin fs functionalities in sfm instead")

	config.setup(opts)
	colors.setup()
	actions.setup()

	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = function()
			colors.setup()
		end,
	})

	sfm_explorer:subscribe(event.ExplorerRootChanged, function()
		ctx.clear_selections()
	end)

	sfm_explorer:subscribe(event.ExplorerOpened, function(payload)
		local bufnr = payload["bufnr"]
		local options = { noremap = true, silent = true, nowait = true, buffer = bufnr }

		for _, map in pairs(config.opts.mappings.list) do
			local keys = type(map.key) == "table" and map.key or { map.key }

			for _, key in pairs(keys) do
				vim.keymap.set("n", key, function()
					actions.run(map.action)
				end, options)

				if map.action == "toggle_selection" then
					vim.keymap.set("x", key, function()
						actions.run(map.action)
					end, options)
				end
			end
		end
	end)

	if config.opts.view.render_selection_in_sign then
		selection_renderer.init_sign()

		sfm_explorer:subscribe(event.ExplorerRendered, function(payload)
			local bufnr = payload["bufnr"]
			selection_renderer.render_selection_in_sign(bufnr)
		end)
	else
		-- indent(10), indicator(20), icon(30), selection(31), name(40)
		sfm_explorer:register_renderer("sfm-fs-selection", 39, selection_renderer.render_selection)
	end
end

return M
