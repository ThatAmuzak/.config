return {
  "cappyzawa/trim.nvim",
  opts = {
    -- ignore markdown file
    ft_blocklist = { "markdown" },
    -- remove multiple blank lines
    patterns = {
      [[%s/\(\n\n\)\n\+/\1/]], -- replace multiple blank lines with a single line
    },
    -- disable trim on write by default
    trim_on_write = false,
    -- don't highlight trailing spaces
    highlight = false,
  },
}
