-- blink.cmp: buffer-words-only completion
return {
    {
        "saghen/blink.cmp",
        dependencies = { "saghen/blink.lib" },
        build = function() require('blink.cmp').build():pwait() end,
        opts = function(_, opts)
            opts.sources = opts.sources or {}
            -- replace (not merge) LazyVim's default source list
            opts.sources.default = { "buffer" }
            opts.sources.per_filetype = {}
            -- disable cmdline completion (schema: top-level cmdline, sibling of sources)
            opts.cmdline = vim.tbl_deep_extend("force", opts.cmdline or {}, { sources = {} })
            return opts
        end,
    },
}
