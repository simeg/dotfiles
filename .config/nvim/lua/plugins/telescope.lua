-- Telescope Configuration
-- Modern fuzzy finder for files, buffers, and more

local status_ok, telescope = pcall(require, 'telescope')
if not status_ok then
  return
end

telescope.setup {
  defaults = {
    prompt_prefix = ' ',
    selection_caret = ' ',
    path_display = { 'smart' },
    file_ignore_patterns = {
      '.git/',
      'node_modules/',
      '%.lock',
    },

    mappings = {
      i = {
        ['<C-n>'] = require('telescope.actions').move_selection_next,
        ['<C-p>'] = require('telescope.actions').move_selection_previous,
        ['<C-c>'] = require('telescope.actions').close,
        ['<Down>'] = require('telescope.actions').move_selection_next,
        ['<Up>'] = require('telescope.actions').move_selection_previous,
        ['<CR>'] = require('telescope.actions').select_default,
        ['<C-x>'] = require('telescope.actions').select_horizontal,
        ['<C-v>'] = require('telescope.actions').select_vertical,
        ['<C-t>'] = require('telescope.actions').select_tab,
        ['<C-u>'] = require('telescope.actions').preview_scrolling_up,
        ['<C-d>'] = require('telescope.actions').preview_scrolling_down,
        ['<PageUp>'] = require('telescope.actions').results_scrolling_up,
        ['<PageDown>'] = require('telescope.actions').results_scrolling_down,
        ['<Tab>'] = require('telescope.actions').toggle_selection + require('telescope.actions').move_selection_worse,
        ['<S-Tab>'] = require('telescope.actions').toggle_selection + require('telescope.actions').move_selection_better,
        ['<C-q>'] = require('telescope.actions').send_to_qflist + require('telescope.actions').open_qflist,
        ['<M-q>'] = require('telescope.actions').send_selected_to_qflist + require('telescope.actions').open_qflist,
        ['<C-l>'] = require('telescope.actions').complete_tag,
        ['<C-_>'] = require('telescope.actions').which_key, -- keys from pressing <C-/>
      },

      n = {
        ['<esc>'] = require('telescope.actions').close,
        ['<CR>'] = require('telescope.actions').select_default,
        ['<C-x>'] = require('telescope.actions').select_horizontal,
        ['<C-v>'] = require('telescope.actions').select_vertical,
        ['<C-t>'] = require('telescope.actions').select_tab,
        ['<Tab>'] = require('telescope.actions').toggle_selection + require('telescope.actions').move_selection_worse,
        ['<S-Tab>'] = require('telescope.actions').toggle_selection + require('telescope.actions').move_selection_better,
        ['<C-q>'] = require('telescope.actions').send_to_qflist + require('telescope.actions').open_qflist,
        ['<M-q>'] = require('telescope.actions').send_selected_to_qflist + require('telescope.actions').open_qflist,
        ['j'] = require('telescope.actions').move_selection_next,
        ['k'] = require('telescope.actions').move_selection_previous,
        ['H'] = require('telescope.actions').move_to_top,
        ['M'] = require('telescope.actions').move_to_middle,
        ['L'] = require('telescope.actions').move_to_bottom,
        ['<Down>'] = require('telescope.actions').move_selection_next,
        ['<Up>'] = require('telescope.actions').move_selection_previous,
        ['gg'] = require('telescope.actions').move_to_top,
        ['G'] = require('telescope.actions').move_to_bottom,
        ['<C-u>'] = require('telescope.actions').preview_scrolling_up,
        ['<C-d>'] = require('telescope.actions').preview_scrolling_down,
        ['<PageUp>'] = require('telescope.actions').results_scrolling_up,
        ['<PageDown>'] = require('telescope.actions').results_scrolling_down,
        ['?'] = require('telescope.actions').which_key,
      },
    },
  },
  pickers = {
    find_files = {
      theme = 'dropdown',
      previewer = false,
      hidden = true, -- Show hidden files
    },
    live_grep = {
      theme = 'ivy',
    },
    buffers = {
      theme = 'dropdown',
      previewer = false,
    },
  },
  extensions = {
    -- Future extensions can be added here
  },
}