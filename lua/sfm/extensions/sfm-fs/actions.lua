local api = require("sfm.api")

local ctx = require("sfm.extensions.sfm-fs.context")
local path = require("sfm.utils.path")
local input = require("sfm.extensions.sfm-fs.utils.input")
local fs = require("sfm.extensions.sfm-fs.utils.fs")
local log = require("sfm.extensions.sfm-fs.utils.log")

local M = {}

--- delete a file/directory
function M.delete()
	local entry = api.entry.current()
	input.confirm("Are you sure you want to delete file " .. entry.name .. "? (y/n)", function()
		-- on yes
		input.clear()

		if fs.remove(entry.path) then
			log.info(entry.path .. " has been deleted")
		else
			log.error("Deletion of file " .. entry.name .. " failed due to an error.")
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

	input.prompt("Create file " .. path.add_trailing(entry.path), nil, "file", function(name)
		input.clear()
		if name == nil or name == "" then
			return
		end

		local fpath = path.join({ entry.path, name })

		if path.exists(fpath) then
			log.warn(fpath .. " already exists")

			return
		end

		local ok = true
		if path.has_trailing(name) then
			-- create directory
			ok = fs.create_dir(fpath)
		else
			-- create file
			ok = fs.create_file(fpath)
		end

		if ok then
			-- reload the explorer
			api.explorer.reload()
			-- focus file
			api.navigation.focus(fpath)

			log.info(fpath .. " created")
		else
			log.error("Creation of file " .. fpath .. " failed due to an error.")
		end
	end)
end

--- rename a current file/directory
function M.rename()
	local entry = api.entry.current()
	local from_path = entry.path

	if entry.is_root then
		return
	end

	local parent = entry.parent

	input.prompt("Rename to " .. path.add_trailing(parent.path), path.basename(from_path), "dir", function(name)
		input.clear()
		if name == nil or name == "" then
			return
		end

		local to_path = path.join({ parent.path, name })

		if path.exists(to_path) then
			log.warn(to_path .. " already exists")

			return
		end

		if fs.rename(from_path, to_path) then
			-- reload the explorer
			api.explorer.reload()
			-- focus file
			api.navigation.focus(to_path)

			log.info(
				string.format("Renaming file %s ➜ %s complete", path.basename(from_path), path.basename(to_path))
			)
		else
			log.error(string.format("Renaming file %s failed due to an error", path.basename(from_path)))
		end
	end)
end

--- delete selected files/directories
function M.delete_selections()
	local selections = ctx.get_selections()
	if vim.tbl_count(selections) then
		log.warn("No files selected. Please select at least one file to proceed.")

		return
	end

	input.confirm("Are you sure you want to delete the selected files/directories? (y/n)", function()
		-- on yes
		input.clear()

		local paths = {}
		for fpath, _ in pairs(selections) do
			table.insert(paths, fpath)
		end
		paths = path.unify(paths)

		local success_count = 0
		for _, fpath in ipairs(paths) do
			if fs.remove(fpath) then
				success_count = success_count + 1
			end
		end

		log.info(
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
---@param paths table
---@param action_fn function
local function _paste(paths, action_fn)
	local dest_entry = M.renderer:get_current_entry()
	if not dest_entry.is_dir or not dest_entry.is_open then
		dest_entry = dest_entry.parent
	end

	local success_count = 0
	local continue_processing = true

	for _, fpath in ipairs(paths) do
		local basename = path.basename(fpath)
		local dest_path = path.join({ dest_entry.path, basename })

		if path.exists(dest_path) then
			input.confirm(dest_path .. " already exists. Rename it? (y/n)", function()
				-- on yes
				input.clear()
				input.prompt("New name " .. path.add_trailing(dest_entry.path), basename, "file", function(name)
					input.clear()
					if name == nil or name == "" then
						return
					end

					dest_path = path.join({ dest_entry.path, name })

					if path.exists(dest_path) then
						log.warn(dest_path .. " already exists")

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

	log.info(
		string.format(
			"Copy/move process complete. %d files copied/moved successfully, %d files failed.",
			success_count,
			vim.tbl_count(paths) - success_count
		)
	)
end

--- copy selected files/directories to a current opened entry or it's parent
function M.copy_selections()
	local selections = ctx.get_selections()
	if vim.tbl_count(selections) then
		log.warn("No files selected. Please select at least one file to proceed.")

		return
	end

	local paths = {}
	for fpath, _ in pairs(selections) do
		table.insert(paths, fpath)
	end

	_paste(paths, fs.copy)

	ctx.clear_selections()
	api.explorer.reload()
end

--- move selected files/directories to a current opened entry or it's parent
function M.move_selections()
	local selections = ctx.get_selections()
	if vim.tbl_count(selections) then
		log.warn("No files selected. Please select at least one file to proceed.")

		return
	end

	local paths = {}
	for fpath, _ in pairs(selections) do
		table.insert(paths, fpath)
	end
	paths = path.unify(paths)

	_paste(paths, fs.move)

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

return M
