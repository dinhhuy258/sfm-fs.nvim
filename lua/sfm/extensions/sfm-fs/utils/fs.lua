local api = require("sfm.api")

local M = {}

--- create a file
---@param fpath string
---@return boolean
function M.touch(fpath)
	local dir = api.path.dirname(fpath)
	if not api.path.exists(dir) then
		-- create dir
		if not M.mkdir(dir) then
			return false
		end
	end

	local mode = 420
	local fd = vim.loop.fs_open(fpath, "w", mode)
	if not fd then
		return false
	end

	vim.loop.fs_close(fd)

	return true
end

--- create a directory
---@param fpath string
---@return boolean
function M.mkdir(fpath)
	local mode = 493
	local success = vim.loop.fs_mkdir(fpath, mode)

	if not success then
		local dirs = api.path.split(fpath)
		local processed = ""

		for _, dir in ipairs(dirs) do
			if dir ~= "" then
				local joined = api.path.join({ processed, dir })
				if processed == "" and api.path.path_separator == "\\" then
					joined = dir
				end

				if api.path.exists(joined) then
					if api.path.isfile(joined) then
						return false
					elseif api.path.isdir(joined) then
						processed = joined
					end
				else
					if vim.loop.fs_mkdir(joined, mode) then
						processed = joined
					else
						return false
					end
				end
			end
		end
	end

	return true
end

--- scan the dir
---@param fpath string
---@return table
function M.scandir(fpath)
	local paths = {}
	local handle = vim.loop.fs_scandir(fpath)
	if type(handle) == "userdata" then
		local function iterator()
			return vim.loop.fs_scandir_next(handle)
		end

		for name in iterator do
			local absolute_path = api.path.join({ fpath, name })
			table.insert(paths, absolute_path)
		end
	end

	return paths
end

--- remove the file/directory for the given fpath
---@param fpath string
---@return boolean
function M._rmdir(fpath)
	local paths = M.scandir(fpath)
	for _, p in ipairs(paths) do
		M.rm(p)
	end

	return vim.loop.fs_rmdir(fpath)
end

--- remove the file/directory for the given fpath
---@param fpath string
---@return boolean
function M.rm(fpath)
	if not api.path.exists(fpath) then
		return false
	end

	if api.path.isdir(fpath) then
		return M._rmdir(fpath)
	elseif api.path.isfile(fpath) or api.path.islink(fpath) then
		return vim.loop.fs_unlink(fpath)
	else
		-- not recognize the file type
		return false
	end
end

--- copy file/directory from source_path to dest_path
---@param source_path string
---@param dest_path string
---@return boolean
function M.cp(source_path, dest_path)
	if not api.path.exists(source_path) then
		return false
	end

	if source_path == dest_path then
		-- do nothing
		return true
	end

	local to_dir = api.path.dirname(dest_path)
	if not api.path.exists(to_dir) then
		local success = M.mkdir(to_dir)
		if not success then
			return false
		end
	end

	local source_lstat = vim.loop.fs_lstat(source_path)

	if api.path.isfile(source_path) then
		return vim.loop.fs_copyfile(source_path, dest_path)
	elseif api.path.isdir(source_path) then
		local handle = vim.loop.fs_scandir(source_path)
		if type(handle) == "string" then
			return false
		elseif not handle then
			return false
		end

		local success = vim.loop.fs_mkdir(dest_path, source_lstat.mode)
		if not success then
			return false
		end

		while true do
			local name = vim.loop.fs_scandir_next(handle)
			if not name then
				break
			end

			success = M.cp(api.path.join({ source_path, name }), api.path.join({ dest_path, name }))
			if not success then
				return false
			end
		end
	else
		return false
	end

	return true
end

--- rename/move source_path to dest_path
---@param source_path string
---@param dest_path string
---@return boolean
function M.mv(source_path, dest_path)
	if not api.path.exists(source_path) then
		return false
	end

	if source_path == dest_path then
		-- do nothing
		return true
	end

	local to_dir = api.path.dirname(dest_path)
	if not api.path.exists(to_dir) then
		local success = M.mkdir(to_dir)
		if not success then
			return false
		end
	end

	return vim.loop.fs_rename(source_path, dest_path)
end

return M
