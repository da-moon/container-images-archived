" auto import
autocmd BufWritePre *.go :call CocAction('organizeImport')
" add json tags to struct
autocmd FileType go nmap gtj :CocCommand go.tags.add json<cr>
" add yaml tags to struct
autocmd FileType go nmap gty :CocCommand go.tags.add yaml<cr>
" remove tags from struct
autocmd FileType go nmap gtx :CocCommand go.tags.clear<cr>
" generate interface stubs
autocmd FileType go nmap gi :CocCommand go.impl.cursor<cr>
" rename types ( similar to :GoRename )
nmap <silent> rn <Plug>(coc-rename)
