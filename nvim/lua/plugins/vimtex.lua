return {
  "lervag/vimtex",
  lazy = false, -- we don't want to lazy load VimTeX
  -- tag = "v2.15", -- uncomment to pin to a specific release
  init = function()
    -- VimTeX configuration goes here, e.g.
    vim.g.vimtex_view_method = "skim"

    -- Set the compiler method
    vim.g.vimtex_compiler_method = "latexmk"

    -- Configure latexmk options
    vim.g.vimtex_compiler_latexmk = {
      build_dir = "",
      callback = 1,
      continuous = 1,
      executable = "latexmk",
      hooks = {},
      options = {
        "-verbose",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
      },
    }

    -- Configure Skim for forward/backward search
    vim.g.vimtex_view_general_viewer = "skim"
    vim.g.vimtex_view_general_options = "-r @line @pdf @tex"

    -- Disable overfull/underfull \hbox and all package warnings
    vim.g.vimtex_quickfix_latexlog = {
      packages = {
        default = 0,
      },
      references = {
        default = 1,
      },
      overfull = 0,
      underfull = 0,
      font = 0,
      fixme = 0,
      fancyhdr = 0,
      hyperref = 0,
    }

    -- Configure which files to clean
    vim.g.vimtex_compiler_clean_paths = {
      "*.aux",
      "*.bbl",
      "*.bcf",
      "*.blg",
      "*.fdb_latexmk",
      "*.fls",
      "*.log",
      "*.nav",
      "*.out",
      "*.run.xml",
      "*.snm",
      "*.synctex.gz",
      "*.toc",
      "*.vrb",
      "_minted*",
    }

    -- Fold configuration
    vim.g.vimtex_fold_enabled = 1
    vim.g.vimtex_fold_manual = 1

    -- Don't open quickfix automatically
    vim.g.vimtex_quickfix_mode = 0

    -- Ignore some warnings
    vim.g.vimtex_log_ignore = {
      "Underfull",
      "Overfull",
      "specifier changed to",
      "Token not allowed in a PDF string",
    }
  end,
}
