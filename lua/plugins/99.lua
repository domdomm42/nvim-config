return {
  {
    "ThePrimeagen/99",
    config = function()
      local _99 = require("99")

      _99.setup({
        model = "anthropic/claude-sonnet-4-6",
        logger = {
          level = _99.DEBUG,
          path = "/tmp/my-project.99.debug",
          print_on_error = true,
        },
        md_files = {
          "AGENT.md",
        },
      })

      -- Search project with AI prompt
      vim.keymap.set("n", "<leader>9s", function()
        _99.search()
      end)

      -- Act on visual selection (visual mode only)
      vim.keymap.set("v", "<leader>9v", function()
        _99.visual()
      end)

      -- Cancel all in-flight requests
      vim.keymap.set("n", "<leader>9x", function()
        _99.stop_all_requests()
      end)
    end,
  },
}
