vim9script

var lspServers = [
  {
    name: 'typescript',
    filetype: ['javascript', 'typescript', 'javascriptreact', 'typescriptreact'],
    path: 'typescript-language-server',
    args: ['--stdio']
  },
  {
    name: 'python',
    filetype: ['python'],
    path: 'pylsp',
    args: []
  },
  {
    name: 'html',
    filetype: ['html'],
    path: 'vscode-html-language-server',
    args: ['--stdio']
  },
  {
    name: 'css',
    filetype: ['css', 'scss', 'less'],
    path: 'vscode-css-language-server',
    args: ['--stdio']
  },
  {
    name: 'json',
    filetype: ['json'],
    path: 'vscode-json-language-server',
    args: ['--stdio']
  },
  {
    name: 'vim',
    filetype: ['vim'],
    path: 'vim-language-server',
    args: ['--stdio']
  },
  {
    name: 'bash',
    filetype: ['sh', 'bash'],
    path: 'bash-language-server',
    args: ['start']
  },
  {
    name: 'clangd',
    filetype: ['c', 'cpp', 'objc', 'objcpp'],
    path: 'clangd',
    args: []
  }
]

autocmd VimEnter * call LspAddServer(lspServers)
