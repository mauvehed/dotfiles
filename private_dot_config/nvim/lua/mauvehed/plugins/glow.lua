return {
	"ellisonleao/glow.nvim",

	config = true,

	cmd = "Glow",

	keys = {
		{ "<leader>lr", "<cmd>Glow<CR>", desc = "Show markdown rendered preview" },
		{ "<leader>lx", "<cmd>Glow!<CR>", desc = "Close markdown rendered preview" },
	},
}
