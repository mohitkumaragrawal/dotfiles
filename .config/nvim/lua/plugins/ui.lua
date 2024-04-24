return {
  {
    "echasnovski/mini.indentscope",
    enabled = false,
    opts = {
      draw = {
        delay = 0,
        animation = function(s, n)
          return 0
        end,
        priority = 2,
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = true,
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      render = "minimal",
      stages = "static",
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
      lsp = {
        hover = {
          silent = true,
        },
      },
    },
  },
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons", -- optional dependency
    },
    opts = {
      -- configurations go here
    },
  },

  {
    "b0o/incline.nvim",
    config = function()
      local helpers = require("incline.helpers")
      local devicons = require("nvim-web-devicons")
      require("incline").setup({
        window = {
          padding = 0,
          margin = { horizontal = 0 },
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if filename == "" then
            filename = "[No Name]"
          end
          local ft_icon, ft_color = devicons.get_icon_color(filename)
          local modified = vim.bo[props.buf].modified
          return {
            ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
            " ",
            { filename, gui = modified and "bold,italic" or "bold" },
            " ",
            guibg = "#44406e",
          }
        end,
      })
    end,
    -- Optional: Lazy load Incline
    event = "VeryLazy",
  },

  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },

  {
    "rolv-apneseth/tfm.nvim",
    config = function()
      -- Set keymap so you can open the default terminal file manager (yazi)
      vim.api.nvim_set_keymap("n", "<leader><leader>", "", {
        noremap = true,
        callback = require("tfm").open,
      })
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader><leader>", false },
    },
  },

  -- {
  --   "Tummetott/reticle.nvim",
  --   config = function()
  --     require("reticle").setup({})
  --   end,
  -- },
}
