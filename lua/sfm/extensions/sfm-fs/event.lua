local api = require("sfm.api")

local M = {}

M.Event = {
	EntryCreated = "EntryCreated",
	EntryDeleted = "EntryDeleted",
	EntryRenamed = "EntryRenamed",
	EntryWillRename = "EntryWillRename",
}

--- dispatch entry created event
---@param fpath string
function M.dispatch_entry_created(fpath)
	api.event.dispatch(M.EntryCreated, {
		path = fpath,
	})
end

--- dispatch entry deleted event
---@param fpath string
function M.dispatch_entry_deleted(fpath)
	api.event.dispatch(M.EntryDeleted, {
		path = fpath,
	})
end

--- dispatch entry renamed event
---@param from_path string
---@param to_path string
function M.dispatch_entry_renamed(from_path, to_path)
	api.event.dispatch(M.EntryRenamed, {
		from_path = from_path,
		to_path = to_path,
	})
end

--- dispatch entry will rename event
---@param from_path string
---@param to_path string
function M.dispatch_entry_will_rename(from_path, to_path)
	api.event.dispatch(M.EntryWillRename, {
		from_path = from_path,
		to_path = to_path,
	})
end

return M
