return {
  'nvim-tree/nvim-web-devicons',
  config = function()
    require('nvim-web-devicons').setup {
      override = {
        rs = {
          icon = "󱘗",
          color = "#dea584",
          cterm_color = "216",
          name = "Rs"
        },
      },
      default = true,
      strict = true,
      override_by_filename = {
        [".gitignore"] = {
          icon = "",
          color = "#f1502f",
          name = "Gitignore"
        },
        ["Cargo.toml"] = {
          icon = "󱘗",
          color = "#dea584",
          name = "CargoToml"
        },
        ["Cargo.lock"] = {
          icon = "󱘗",
          color = "#dea584",
          name = "CargoLock"
        },
      },
      override_by_extension = {
        ["rs"] = {
          icon = "󱘗",
          color = "#dea584",
          name = "Rs"
        },
      },
    }
  end,
}