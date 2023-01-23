local api = require("sfm.api")

local ctx = require("sfm.extensions.sfm-fs.context")
local input = require("sfm.extensions.sfm-fs.utils.input")
local fs = require("sfm.extensions.sfm-fs.utils.fs")

local M = {}

local Actions = {}

--- delete a file/directory
function M.delete()
	local entry = api.entry.current()
	input.confirm("Are you sure you want to delete file " .. entry.name .. "? (y/n)", function()
		-- on yes
		input.clear()

		if fs.rm(entry.path) then
			api.log.info(entry.path .. " has been deleted")
		else
			api.log.error("Deletion of file " .. entry.name .. " failed due to an error.")
		end

		-- reload the explorer
		api.explorer.reload()
	end, function()
		-- on no
		input.clear()
	end, function()
		-- on cancel
		input.clear()
	end)
end

--- add a file; leaving a trailing `/` will add a directory
function M.create()
	local entry = api.entry.current()
	if (not entry.is_dir or not entry.is_open) and not entry.is_root then
		entry = entry.parent
	end

	input.prompt("Create file ", api.path.add_trailing(entry.path), "file", function(fpath)
		input.clear()
		if fpath == nil or fpath == "" then
			return
		end

		if api.path.exists(fpath) then
			api.log.warn(fpath .. " already exists")

			return
		end

		local ok = true
		if api.path.has_trailing(fpath) then
			-- create directory
			ok = fs.mkdir(fpath)
		else
			-- create file
			ok = fs.touch(fpath)
		end

		if ok then
			-- reload the explorer
			api.explorer.reload()
			-- focus file
			api.navigation.focus(fpath)

			api.log.info(fpath .. " created")
		else
			api.log.error("Creation of file " .. fpath .. " failed due to an error.")
		end
	end)
end

--- delete selected files/directories
function M.delete_selections()
	local selections = ctx.get_selections()
	if vim.tbl_isempty(selections) then
		api.log.warn("No files selected. Please select at least one file to proceed.")

		return
	end

	input.confirm("Are you sure you want to delete the selected files/directories? (y/n)", function()
		-- on yes
		input.clear()

		local paths = {}
		for fpath, _ in pairs(selections) do
			table.insert(paths, fpath)
		end
		paths = api.path.unify(paths)

		local success_count = 0
		for _, fpath in ipairs(paths) do
			if fs.rm(fpath) then
				success_count = success_count + 1
			end
		end

		api.log.info(
			string.format(
				"Deletion process complete. %d files deleted successfully, %d files failed.",
				success_count,
				vim.tbl_count(paths) - success_count
			)
		)

		-- clear selections
		ctx.clear_selections()

		-- reload the explorer
		api.explorer.reload()
	end, function()
		-- on no
		input.clear()
	end, function()
		-- on cancel
		input.clear()
	end)
end

--- move/copy selected files/directories to a current opened entry or it's parent
---@param from_paths table
---@param to_dir string
---@param action_fn function
local function _paste(from_paths, to_dir, action_fn)
	local success_count = 0
	local continue_processing = true

	for _, fpath in ipairs(from_paths) do
		local basename = api.path.basename(fpath)
		local dest_path = api.path.join({ to_dir, basename })

		if api.path.exists(dest_path) then
			input.confirm(dest_path .. " already exists. Rename it? (y/n)", function()
				-- on yes
				input.clear()
				input.prompt("New name " .. api.path.add_trailing(to_dir), basename, "file", function(name)
					input.clear()
					if name == nil or name == "" then
						return
					end

					dest_path = api.path.join({ to_dir, name })

					if api.path.exists(dest_path) then
						api.log.warn(dest_path .. " already exists")

						return
					end

					if action_fn(fpath, dest_path) then
						success_count = success_count + 1
					end
				end)
			end, function()
				-- on no
				input.clear()
			end, function()
				-- on cancel
				input.clear()
				continue_processing = false
			end)
		else
			if action_fn(fpath, dest_path) then
				success_count = success_count + 1
			end
		end

		if not continue_processing then
			break
		end
	end

	api.log.info(
		string.format(
			"Copy/move process complete. %d files copied/moved successfully, %d files failed.",
			success_count,
			vim.tbl_count(from_paths) - success_count
		)
	)
end

--TODO: Remove this method
function M.rename()
	api.log.warn(
		"The action rename() is deprecated and will be removed in a future version. Please use the new action move() instead."
	)
end

--- move/rename a current file/directory
function M.move()
	local entry = api.entry.current()
	local from_path = entry.path

	if entry.is_root then
		return
	end

	input.prompt("Move: ", entry.path, "file", function(to_path)
		input.clear()
		if to_path == nil or to_path == "" then
			return
		end

		if api.path.exists(to_path) then
			api.log.warn(to_path .. " already exists")

			return
		end

		if fs.mv(from_path, to_path) then
			-- reload the explorer
			api.explorer.reload()
			-- focus file
			api.navigation.focus(to_path)

			api.log.info(string.format("Moving file/directory %s ➜ %s complete", from_path, to_path))
		else
			api.log.error(
				string.format("Moving file/directory %s failed due to an error", api.path.basename(from_path))
			)
		end
	end)
end

--- copy file/directory
function M.copy()
	local entry = api.entry.current()
	local from_path = entry.path

	if entry.is_root then
		return
	end

	input.prompt("Copy: " .. from_path .. " -> ", from_path, "file", function(to_path)
		input.clear()
		if to_path == nil or to_path == "" then
			return
		end

		if api.path.exists(to_path) then
			api.log.warn(to_path .. " already exists")

			return
		end

		if fs.cp(entry.path, to_path) then
			-- reload the explorer
			api.explorer.reload()
			-- focus file
			api.navigation.focus(to_path)

			api.log.info(string.format("Copying file/directory %s ➜ %s complete", from_path, to_path))
		else
			api.log.error(
				string.format("Copying file/directory %s failed due to an error", api.path.basename(from_path))
			)
		end
	end)
end

--- copy selected files/directories to a current opened entry or it's parent
function M.copy_selections()
	local selections = ctx.get_selections()
	if vim.tbl_isempty(selections) then
		api.log.warn("No files selected. Please select at least one file to proceed.")

		return
	end

	local paths = {}
	for fpath, _ in pairs(selections) do
		table.insert(paths, fpath)
	end

	local dest_entry = api.entry.current()
	if not dest_entry.is_dir or not dest_entry.is_open then
		dest_entry = dest_entry.parent
	end

	_paste(paths, dest_entry.path, fs.cp)

	ctx.clear_selections()
	api.explorer.reload()
end

--- move selected files/directories to a current opened entry or it's parent
function M.move_selections()
	local selections = ctx.get_selections()
	if vim.tbl_isempty(selections) then
		api.log.warn("No files selected. Please select at least one file to proceed.")

		return
	end

	local paths = {}
	for fpath, _ in pairs(selections) do
		table.insert(paths, fpath)
	end
	paths = api.path.unify(paths)

	local dest_entry = api.entry.current()
	if not dest_entry.is_dir or not dest_entry.is_open then
		dest_entry = dest_entry.parent
	end

	_paste(paths, dest_entry.path, fs.mv)

	ctx.clear_selections()
	api.explorer.reload()
end

--- toggle a current file/directory to bookmarks list
function M.toggle_selection()
	local entry = api.entry.current()
	if entry.is_root then
		return
	end

	if ctx.is_selected(entry) then
		ctx.remove_selection(entry)
	else
		ctx.set_selection(entry)
	end

	api.explorer.refresh()
end

--- clear a bookmarks list
function M.clear_selections()
	ctx.clear_selections()
	api.explorer.refresh()
end

--- run the given action name
---@param action string
function M.run(action)
  local defined_action = Actions[action]
  if defined_action == nil then
    api.log.error(
      string.format(
        "Invalid action name '%s' provided. Please provide a valid action name or check your configuration for any mistakes.",
        action
      )
    )

    return
  end

  defined_action()
end

--- setup
function M.setup()
	Actions = {
		create = M.create,
		delete = M.delete,
		delete_selections = M.delete_selections,
		copy = M.copy,
		copy_selections = M.copy_selections,
		move = M.move,
		move_selections = M.move_selections,
		toggle_selection = M.toggle_selection,
		clear_selections = M.clear_selections,
	}
end

return M
