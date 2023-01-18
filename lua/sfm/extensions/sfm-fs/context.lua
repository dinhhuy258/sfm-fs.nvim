local M = {
	_selections = {},
}

--- bookmark the given entry
function M.set_selection(entry)
	if M.is_selected(entry) then
		return
	end

	M._selections[entry.path] = true
end

--- remove the given entry out of the bookmarks list
function M.remove_selection(entry)
	if not M.is_selected(entry) then
		return
	end

	M._selections[entry.path] = nil
end

--- check if the given entry is selected
function M.is_selected(entry)
	return M._selections[entry.path] and true or false
end

--- clear the bookmarks list
function M.clear_selections()
	M._selections = {}
end

--- get the bookmarks list
function M.get_selections()
	return M._selections
end

return M
