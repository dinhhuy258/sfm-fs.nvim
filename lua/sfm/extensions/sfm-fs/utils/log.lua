local M = {}

function M.info(message)
	vim.notify("[sfm-fs] " .. message, vim.log.levels.INFO)
end

function M.warn(message)
	vim.notify("[sfm-fs] " .. message, vim.log.levels.WARN)
end

function M.error(message)
	vim.notify("[sfm-fs] " .. message, vim.log.levels.ERROR)
end

return M
