return {
  "akinsho/toggleterm.nvim",
  opts = {
    direction = "float",
    float_opts = {
      border = "curved",
      width = function()
        return vim.o.columns
      end,
      height = function()
        return vim.o.lines
      end,
    },
  },
}
