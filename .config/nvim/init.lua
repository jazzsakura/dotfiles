if vim.fn.has("nvim-0.11") == 0 then
    vim.notify("NativeVim only supports Neovim 0.11+", vim.log.levels.ERROR)
    return
end

require("core.options")
require("core.statusline")
require("core.remap")

vim.pack.add({
		{ src = "https://github.com/vague2k/vague.nvim"},
		{ src = "https://github.com/neovim/nvim-lspconfig"},
		{ src = "https://github.com/echasnovski/mini.pick"},
	})

require("mini.pick").setup()
require("vague").setup({ transparent = true })
vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")
