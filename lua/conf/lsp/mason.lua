local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
    print("Error then calling require 'lspconfig' plugin")
    return
end

local status_ok, mason_installer = pcall(require, "conf.lsp.mason_installer")
if not status_ok then
    print("Error then calling 'mason-tool-installer' plugin")
end

local mason, mason_lspconfig
status_ok, mason = pcall(require, "mason")
if not status_ok then
    print("Error then calling require 'mason' plugin")
    return
end


local status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ok then
    print("Error then calling require 'mason-lspconfig' plugin")
    return
end

AUTO_INSTALL_SERVERS = {
    -- Lsp servers
    "sumneko_lua",
    -- "rust_analyzer",
    -- "rust_analyzer@nightly",
    "gopls",
    "jsonls",
    "terraformls",
    "tsserver",
    "yamlls",
    "golangci_lint_ls",
    "solargraph",
    "sorbet",
}

START_SERVERS = {
    -- Lsp servers
    "sumneko_lua",
    "rust_analyzer",
    -- "rust_analyzer@nightly",
    "gopls",
    "jsonls",
    "terraformls",
    "tsserver",
    "yamlls",
    "golangci_lint_ls",
    "solargraph",
    "sorbet",
}

mason.setup({
    ui = {
        border = "rounded",
        icons = {
            package_installed = "◍",
            package_pending = "◍",
            package_uninstalled = "◍",
        },
    },
    log_level = vim.log.levels.INFO,
    max_concurrent_installers = 1,
})

mason_lspconfig.setup({
    ensure_installed = AUTO_INSTALL_SERVERS,
    automatic_installation = false,
})

local opts = {}

for _, server in pairs(START_SERVERS) do
    -- Options for lsp servers
    opts = {
        on_attach = require("conf.lsp.handlers").on_attach,
        capabilities = require("conf.lsp.handlers").capabilities,
    }

    server = vim.split(server, "@", { plain = true })[1]

    if server == "jsonls" then
        local jsonls_opts = require "conf.lsp.settings.jsonls"
        opts = vim.tbl_deep_extend("force", jsonls_opts, opts)
    end

    if server == "yamlls" then
        local yamlls_opts = require "conf.lsp.settings.yamlls"
        opts = vim.tbl_deep_extend("force", yamlls_opts, opts)
    end

    if server == "sumneko_lua" then
        local n_status_ok, neodev = pcall(require, "neodev")
        if not n_status_ok then
            print("error then calling require plugin folke/neodev.nvim")
            return
        end
        local sumneko_status_ok, sumneko_opts = pcall(require, "conf.lsp.settings.sumneko_lua")
        if not sumneko_status_ok then
            print("error then calling require options for plugin sumneko_lua")
            return
        end
        opts = vim.tbl_deep_extend("force",
            opts,
            sumneko_opts
        )

        lspconfig.sumneko_lua.setup(opts)
        goto continue
    end

    if server == "tsserver" then
        local tsserver_opts = require "conf.lsp.settings.tsserver"
        opts = vim.tbl_deep_extend("force", tsserver_opts, opts)
    end

    if server == "rust_analyzer" then
        local rust_opts, rust_tools
        status_ok, rust_opts = pcall(require, "conf.lsp.settings.rust_tools")
        if not status_ok then
            print("Error then calling require 'conf/lsp/settings/rust_tools' script")
            return
        end

        status_ok, rust_tools = pcall(require, "rust-tools")
        if not status_ok then
            print("Error then calling require 'rust-tools' plugin")
            return
        end

        --     {
        --     "server" = {
        --     on_attach = function(_, bufnr)
        --     -- Hover actions
        --     vim.keymap.set(
        --         "n",
        --         "K",
        --         rust_tools.hover_actions.hover_actions, { buffer = bufnr }
        --     )
        --     -- Code action groups
        --     vim.keymap.set(
        --         "n",
        --         "ga",
        --         rust_tools.code_action_group.code_action_group, { buffer = bufnr }
        --     )
        -- end
        -- })
        rust_tools.setup(rust_opts)
        goto continue
    end

    if server == "gopls" then
        local gopls_opts = require "conf.lsp.settings.gopls"
        opts = vim.tbl_deep_extend("force", gopls_opts, opts)
    end

    if server == "terraformls" then
        local terraformls_opts = require("conf.lsp.settings.terraformls")
        opts = vim.tbl_deep_extend("force", terraformls_opts, opts)
    end

    lspconfig[server].setup(opts)
    ::continue::
end
