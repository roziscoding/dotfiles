return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        denols = {
          -- Prevents deno from being loaded into node projects
          root_dir = require("lspconfig").util.root_pattern("deno.json", "deno.jsonc"),
          --   local lspconfig = require("lspconfig")
          --   return lspconfig.util.root_pattern("deno.json", "deno.jsonc")
          -- end,
          init_options = {
            enable = true,
            lint = true,
            unstable = true,
            suggest = {
              imports = {
                hosts = {
                  "https://deno.land",
                  "https://jsr.io",
                },
              },
            },
          },
        },
        tsserver = {
          enabled = false,
        },
        vtsls = {
          single_file_support = false,
          -- explicitly add default filetypes, so that we can extend
          -- them in related extras
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          root_dir = function(filename)
            -- NOTE: root_pattern returns a function that needs to be called with the filename
            local lspconfig = require("lspconfig")
            local denoRootDir = lspconfig.util.root_pattern("deno.json", "deno.jsonc")(filename)
            -- prevents tsserver from attaching in deno projects
            if denoRootDir then
              return nil
            end
            return lspconfig.util.root_pattern("package.json")(filename)
          end,
          settings = {
            complete_function_calls = true,
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = "always" },
              suggest = {
                completeFunctionCalls = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "literal" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
          },
        },
      },
    },
  },
}
