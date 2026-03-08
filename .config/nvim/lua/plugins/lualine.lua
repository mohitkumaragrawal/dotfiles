local function generate_winbar_config()
	return {
		lualine_a = {},
		lualine_b = {
			{
				"filetype",
				colored = false, -- Displays filetype icon in color if set to true
				icon_only = true, -- Display only an icon for filetype
			},
		},
		lualine_c = {
			{
				"filename",
				symbols = {
					modified = "", -- Text to show when the file is modified.
					readonly = "", -- Text to show when the file is non-modifiable or readonly.
					unnamed = " ", -- Text to show for unnamed buffers.
					newfile = "+", -- Text to show for new created file before first write
				},
				cond = function()
					-- Only show this 'filename' component if the filetype is NOT 'oil'
					return vim.bo.filetype ~= "oil"
				end,
			},
			{
				function()
					if vim.bo.filetype == "oil" then
						return require("oil").get_current_dir(0)
					end
					return ""
				end,
			},
		},
		lualine_y = {},
		lualine_z = {
			{
				"location",
			},
		},
	}
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", "rebelot/kanagawa.nvim" },
	config = function()
		require("lualine").setup({
			options = {
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				globalstatus = true,
				disabled_filetypes = {
					winbar = {
						"NvimTree",
					},
				},
				always_show_tabline = false,
			},
			sections = {
				lualine_a = { {
					"mode",
					fmt = function(str)
						return str:sub(1, 1)
					end,
				} },
				lualine_b = {
					{
						"branch",
						fmt = function(str)
							local max_len = 25
							if #str > max_len then
								return string.sub(str, 1, 18) .. ".." .. string.sub(str, -5)
							end
						end,
					},
				},
				lualine_c = { { "filename", path = 1 } },
				lualine_x = {
          {
            require("noice").api.status.mode.get,
            cond = require("noice").api.status.mode.has,
            color = { fg = "#ff9e64" },
          },
        },
				lualine_y = {},
				lualine_z = { { "tabs", mode = 0 } },
			},
			winbar = generate_winbar_config(),
			inactive_winbar = generate_winbar_config(),
		})

	end,
}
