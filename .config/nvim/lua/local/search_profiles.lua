return {
	repos = {
		{
			remote = "git@github.com:mohitkumaragrawal/dotfiles.git",
			profiles = {
				{
					id = "nvim-plugins",
					label = "Neovim Plugins",
					grep = {
						cwd = ".config/nvim/lua/plugins",
					},
				},
			},
		},
	},
}
