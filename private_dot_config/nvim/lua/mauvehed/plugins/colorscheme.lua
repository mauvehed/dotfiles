--return {
--  "maxmx03/dracula.nvim",
--  priority = 1000,
--  config = function()
--    vim.cmd("colorscheme dracula")
--  end
--}

return {
  {
    'maxmx03/dracula.nvim',
    lazy = false,
    priority = 1000,
    config = function ()
      ---@type dracula
      local dracula = require "dracula"

      dracula.setup({
      styles = {
        Type = {},
        Function = {},
        Parameter = {},
        Property = {},
        Comment = {},
        String = {},
        Keyword = {},
        Identifier = {},
        Constant = {},
      },
      transparent = false,
      on_colors = function (colors, color)
        ---@type dracula.palette
        return {
          -- override or create new colors
          mycolor = "#ffffff",
          -- mycolor = 0xffffff,
        }
      end,
      on_highlights = function (colors, color)
        ---@type dracula.highlights
        return {
          ---@type vim.api.keyset.highlight
          Normal = { fg = colors.mycolor }
        }
      end,
      })
      vim.cmd.colorscheme 'dracula'
      vim.cmd.colorscheme 'dracula-soft'
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        theme = vim.g.colors_name,
        refresh = {
          statusline = 1000,
        },
      },
    },
  }
}
