vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "

-- Disable compatibility with vi which can cause unexpected issues.
vim.cmd("set nocompatible")
vim.cmd("syntax enable")
-- Display line numbers
vim.cmd("set number")
-- Highlight cursor line underneath the cursor horizontally.
vim.cmd("set cursorline")
-- Set shift width to 2 spaces.
vim.cmd("set shiftwidth=2")
-- Set tab width to 2 columns.
vim.cmd("set tabstop=2")
-- Use space characters instead of tabs.
vim.cmd("set expandtab")
-- Do not save backup files.
vim.cmd("set nobackup")
-- Do not let cursor scroll below or above N number of lines when scrolling.
vim.cmd("set scrolloff=10")
-- While searching though a file incrementally highlight matching characters as you type.
vim.cmd("set incsearch")
-- Ignore capital letters during search.
vim.cmd("set ignorecase")
-- Override the ignorecase option if searching for capital letters.
-- This will allow you to search specifically for capital letters.
vim.cmd("set smartcase")
-- Show matching words during a search.
vim.cmd("set showmatch")
-- Use highlighting when doing a search.
vim.cmd("set hlsearch")
-- Set the commands to save in history default number is 20.
vim.cmd("set history=1000")
-- Enable auto completion menu after pressing TAB.
vim.cmd("set wildmenu")
-- Make wildmenu behave like similar to Bash completion.
vim.cmd("set wildmode=list:longest")
-- There are certain files that we would never want to edit with Vim.
-- Wildmenu will ignore files with these extensions.
vim.cmd("set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx")
-- Enables automatic line number changing
 vim.cmd("set number")
 vim.cmd([[augroup numbertoggle
             autocmd!
             autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
             autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
           augroup END]])
-- vim.cmd(" Clears search when hitting return again")
-- vim.cmd("nnoremap <silent> <cr> :noh<CR><CR>")


