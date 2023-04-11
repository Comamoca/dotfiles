vim.api.nvim_create_augroup("lazy_load", {})
function LazyLoad(event, callback)
	vim.api.nvim_create_augroup("lazy_load", {})
	vim.api.nvim_create_autocmd(event, {
		group = "lazy_load",
		callback = callback,
	})
end

return {
	LazyLoad = LazyLoad,
}
