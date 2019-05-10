let s:save_cpo = &cpo
set cpo&vim

set rtp+=webapi-vim

function! Tweet#Post() abort
    let ctx = {}
    let configfile = expand('~/.twitter-vim')
    if filereadable(configfile)
        let ctx = eval(join(readfile(configfile), ''))
    else
        let ctx.consumer_key = input('consumer_key:')
        if ctx.consumer_key == ''
            return
        endif
        let ctx.consumer_secret = input('consumer_secret:')
        if ctx.consumer_secret == ''
            return
        endif

        let request_token_url = 'https://api.twitter.com/oauth/request_token'
        let auth_url =  'https://twitter.com/oauth/authorize'
        let access_token_url = 'https://api.twitter.com/oauth/access_token'

        let ctx = webapi#oauth#request_token(request_token_url, ctx, {'oauth_callback': 'oob', 'dummy': 1})
        if type(ctx) != type({})
            echomsg ctx.response.content
            return
        endif
        if has('win32') || has('win64')
            exe printf('!start rundll32 url.dll,FileProtocolHandler %s?oauth_token=%s', auth_url, .ctx.request_token)
        else
            call system(printf("xdg-open '%s?oauth_token=%s'", auth_url, ctx.request_token))
        endif
        execute "OpenBrowser " . auth_url . "?oauth_token=" . ctx.request_token
        let pin = input('PIN:')
        let ctx = webapi#oauth#access_token(access_token_url, ctx, {'oauth_verifier': pin})
        call writefile([string(ctx)], configfile)
    endif

    let post_url = 'https://api.twitter.com/1.1/statuses/update.json'
    let ret = webapi#oauth#post(post_url, ctx, {}, {'status': s:returnTweet()})
    return ret
endfunction

function! Tweet#Look() abort
    let ctx = {}
    let configfile = expand('~/.twitter-vim')
    if filereadable(configfile)
        let ctx = eval(join(readfile(configfile), ''))
    else
        let ctx.consumer_key = input('consumer_key:')
        if ctx.consumer_key == ''
            return
        endif
        let ctx.consumer_secret = input('consumer_secret:')
        if ctx.consumer_secret == ''
            return
        endif

        let request_token_url = 'https://api.twitter.com/oauth/request_token'
        let auth_url =  'https://twitter.com/oauth/authorize'
        let access_token_url = 'https://api.twitter.com/oauth/access_token'

        let ctx = webapi#oauth#request_token(request_token_url, ctx, {'oauth_callback': 'oob', 'dummy': 1})
        if type(ctx) != type({})
            echomsg ctx.response.content
            return
        endif
        if has('win32') || has('win64')
            exe printf('!start rundll32 url.dll,FileProtocolHandler %s?oauth_token=%s', auth_url, .ctx.request_token)
        else
            call system(printf("xdg-open '%s?oauth_token=%s'", auth_url, ctx.request_token))
        endif
        execute "OpenBrowser " . auth_url . "?oauth_token=" . ctx.request_token
        let pin = input('PIN:')
        let ctx = webapi#oauth#access_token(access_token_url, ctx, {'oauth_verifier': pin})
        call writefile([string(ctx)], configfile)
    endif

    let get_url = 'https://api.twitter.com/1.1/statuses/user_timeline.json'
    let ret = webapi#oauth#get(get_url, ctx, {}, {'screen_name':"get_me_power","count":200})
    let dict = webapi#json#decode(ret.content)
    for item in dict
        echo item["text"]
        echo "\n"
    endfor
endfunction


function Tweet#Edit()
    let inputfile = "$HOME/test.txt"
    execute ":new " . escape(inputfile, ' ')
endfunction

function s:returnTweet()
    let list = []
    let inputfile = (expand('$HOME/test.txt'))
    for line in readfile(inputfile)
        "echo line"
        call add(list, line)
    endfor
    echo join(list, "\n") . "\n"
    return join(list, "\n")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
