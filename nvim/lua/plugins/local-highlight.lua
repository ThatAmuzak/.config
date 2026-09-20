-- Highlight all instances of the word under the cursor (screen area)
return {
  {
    "tzachar/local-highlight.nvim",
    event = "LazyFile",
    config = function()
      require("local-highlight").setup({
        highlight_group = "Substitute",
      })
    end,
  },
}
