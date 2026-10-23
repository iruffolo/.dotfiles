return {
  'coder/claudecode.nvim',
  dependencies = { 'folke/snacks.nvim' },
  opts = {
    terminal = {
      snacks_win_opts = {
        keys = {
          -- Jump from the Claude terminal back to the previous (code) window
          claude_focus_back = {
            '<M-o>',
            function()
              vim.cmd.stopinsert()
              local cur = vim.api.nvim_get_current_win()
              local prev = vim.fn.win_getid(vim.fn.winnr '#')
              local function usable(w)
                return w ~= cur and vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_config(w).relative == '' and vim.bo[vim.api.nvim_win_get_buf(w)].buftype ~= 'terminal'
              end
              if usable(prev) then
                return vim.api.nvim_set_current_win(prev)
              end
              for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                if usable(w) then
                  return vim.api.nvim_set_current_win(w)
                end
              end
            end,
            mode = 't',
            desc = 'Focus code window',
          },
        },
      },
    },
  },
  cmd = {
    'ClaudeCode',
    'ClaudeCodeFocus',
    'ClaudeCodeSelectModel',
    'ClaudeCodeAdd',
    'ClaudeCodeSend',
    'ClaudeCodeTreeAdd',
    'ClaudeCodeStatus',
    'ClaudeCodeStart',
    'ClaudeCodeStop',
    'ClaudeCodeOpen',
    'ClaudeCodeClose',
    'ClaudeCodeDiffAccept',
    'ClaudeCodeDiffDeny',
    'ClaudeCodeCloseAllDiffs',
  },
  keys = {
    { '<leader>a', nil, desc = 'AI/Claude Code' },
    { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude' },
    { '<M-o>', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
    { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
    { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume Claude' },
    { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
    { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select Claude model' },
    { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
    { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
    { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
    { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny diff' },
  },
}
