-----------------------------------------------------------
-- BASIC OPTIONS
-----------------------------------------------------------

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

vim.opt.termguicolors = true
vim.opt.mouse = "a"

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.clipboard = "unnamedplus"

vim.opt.updatetime = 250
vim.opt.timeoutlen = 400

-----------------------------------------------------------
-- LAZY.NVIM
-----------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- PLUGINS
-----------------------------------------------------------

require("lazy").setup({

    -------------------------------------------------------
    -- CATPPUCCIN THEME
    -------------------------------------------------------

    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,

        config = function()
            require("catppuccin").setup({
                flavour = "mocha",

                transparent_background = false,

                integrations = {
                    telescope = true,
                    nvimtree = true,
                    treesitter = true,
                    gitsigns = true,
                },
            })

            vim.cmd.colorscheme("catppuccin-mocha")
        end,
    },

    -------------------------------------------------------
    -- FILE ICONS
    -------------------------------------------------------

    {
        "nvim-tree/nvim-web-devicons",
    },

    -------------------------------------------------------
    -- FILE EXPLORER
    -------------------------------------------------------

    {
        "nvim-tree/nvim-tree.lua",

        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },

        config = function()
            require("nvim-tree").setup({

                view = {
                    width = 32,
                    side = "left",
                },

                renderer = {
                    group_empty = true,
                    highlight_git = true,
                    highlight_opened_files = "name",
                },

                filters = {
                    dotfiles = false,
                },

                git = {
                    enable = true,
                    ignore = false,
                },
            })
        end,
    },

    -------------------------------------------------------
    -- TELESCOPE
    -------------------------------------------------------

    {
        "nvim-telescope/telescope.nvim",

        dependencies = {
            "nvim-lua/plenary.nvim",
        },

        config = function()
            require("telescope").setup({})
        end,
    },

    -------------------------------------------------------
    -- TREESITTER
    -------------------------------------------------------

    {
        "nvim-treesitter/nvim-treesitter",

        branch = "main",
        lazy = false,
        build = ":TSUpdate",

        config = function()
            require("nvim-treesitter").setup({
                install_dir = vim.fn.stdpath("data") .. "/site",
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = {
                    "rust",
                    "lua",
                    "bash",
                    "json",
                    "toml",
                    "yaml",
                    "markdown",
                    "vim",
                    "vimdoc",
                },

                callback = function()
                    vim.treesitter.start()
                end,
            })
        end,
    },

    -------------------------------------------------------
    -- LSP CONFIGURATION
    -------------------------------------------------------

    {
        "neovim/nvim-lspconfig",
    },

    -------------------------------------------------------
    -- AUTOCOMPLETION
    -------------------------------------------------------

    {
        "hrsh7th/nvim-cmp",

        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",

            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },

        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({

                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },

                mapping = cmp.mapping.preset.insert({

                    ["<C-Space>"] = cmp.mapping.complete(),

                    ["<CR>"] = cmp.mapping.confirm({
                        select = true,
                    }),

                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()

                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()

                        else
                            fallback()
                        end
                    end, { "i", "s" }),

                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()

                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)

                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),

                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                },
            })
        end,
    },

    -------------------------------------------------------
    -- GIT SIGNS
    -------------------------------------------------------

    {
        "lewis6991/gitsigns.nvim",

        config = function()
            require("gitsigns").setup()
        end,
    },

    -------------------------------------------------------
    -- STATUS LINE
    -------------------------------------------------------

    {
        "nvim-lualine/lualine.nvim",

        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },

        config = function()
            require("lualine").setup({
                options = {
                    theme = "auto",
                    globalstatus = true,

                    component_separators = "",
                    section_separators = "",
                },
            })
        end,
    },

    -------------------------------------------------------
    -- WHICH-KEY
    -------------------------------------------------------

    {
        "folke/which-key.nvim",

        event = "VeryLazy",

        config = function()
            require("which-key").setup({})
        end,
    },
})

-----------------------------------------------------------
-- RUST ANALYZER
-----------------------------------------------------------

local capabilities =
    require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("rust_analyzer", {

    capabilities = capabilities,

    settings = {
        ["rust-analyzer"] = {

            cargo = {
                allFeatures = true,
            },

            check = {
                command = "clippy",
            },

            procMacro = {
                enable = true,
            },
        },
    },
})

-----------------------------------------------------------
-- AUTO ENABLE RUST ANALYZER
-----------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {

    pattern = "rust",

    callback = function()
        vim.lsp.enable("rust_analyzer")
    end,

})

-----------------------------------------------------------
-- DIAGNOSTICS
-----------------------------------------------------------

vim.diagnostic.config({

    virtual_text = true,

    signs = true,

    underline = true,

    update_in_insert = false,

    severity_sort = true,

    float = {
        border = "rounded",
        source = true,
    },

})

-----------------------------------------------------------
-- LSP KEYMAPS
-----------------------------------------------------------

vim.keymap.set(
    "n",
    "gd",
    vim.lsp.buf.definition,
    { desc = "Go to definition" }
)

vim.keymap.set(
    "n",
    "gD",
    vim.lsp.buf.declaration,
    { desc = "Go to declaration" }
)

vim.keymap.set(
    "n",
    "gr",
    vim.lsp.buf.references,
    { desc = "Find references" }
)

vim.keymap.set(
    "n",
    "gi",
    vim.lsp.buf.implementation,
    { desc = "Go to implementation" }
)

vim.keymap.set(
    "n",
    "K",
    vim.lsp.buf.hover,
    { desc = "Documentation" }
)

vim.keymap.set(
    "n",
    "<leader>rn",
    vim.lsp.buf.rename,
    { desc = "Rename symbol" }
)

vim.keymap.set(
    "n",
    "<leader>ca",
    vim.lsp.buf.code_action,
    { desc = "Code action" }
)

-----------------------------------------------------------
-- FILE EXPLORER
-----------------------------------------------------------

vim.keymap.set(
    "n",
    "<leader>e",
    ":NvimTreeToggle<CR>",
    { desc = "Explorer" }
)

vim.keymap.set(
    "n",
    "<leader>f",
    ":NvimTreeFindFile<CR>",
    { desc = "Find current file" }
)

-----------------------------------------------------------
-- TELESCOPE
-----------------------------------------------------------

local builtin = require("telescope.builtin")

vim.keymap.set(
    "n",
    "<leader>ff",
    builtin.find_files,
    { desc = "Find files" }
)

vim.keymap.set(
    "n",
    "<leader>fg",
    builtin.live_grep,
    { desc = "Search project" }
)

vim.keymap.set(
    "n",
    "<leader>fb",
    builtin.buffers,
    { desc = "Buffers" }
)

vim.keymap.set(
    "n",
    "<leader>fh",
    builtin.help_tags,
    { desc = "Help" }
)

-----------------------------------------------------------
-- SAVE
-----------------------------------------------------------

vim.keymap.set(
    "n",
    "<C-s>",
    ":w<CR>",
    { desc = "Save" }
)

vim.keymap.set(
    "i",
    "<C-s>",
    "<Esc>:w<CR>a",
    { desc = "Save" }
)

-----------------------------------------------------------
-- WINDOW NAVIGATION
-----------------------------------------------------------

vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-----------------------------------------------------------
-- INSERT MODE ESCAPE
-----------------------------------------------------------

vim.keymap.set("i", "jk", "<Esc>")

-----------------------------------------------------------
-- FORMAT
-----------------------------------------------------------

vim.keymap.set(
    "n",
    "<leader>fm",
    function()
        vim.lsp.buf.format({
            async = true,
        })
    end,
    { desc = "Format" }
)

-----------------------------------------------------------
-- TERMINAL
-----------------------------------------------------------

vim.keymap.set(
    "n",
    "<leader>t",
    ":split | terminal<CR>",
    { desc = "Terminal" }
)
