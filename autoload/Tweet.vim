let s:save_cpo = &cpo
set cpo&vim

set rtp+=webapi-vim

function! Tweet#Post() abort
    let post_url = 'https://api.twitter.com/1.1/statuses/update.json'
    let ret = webapi#oauth#post(post_url, s:Oauth(), {}, {'status': s:returnTweet()})
    echo ''
    if ret['status'] == 200
        echo 'success!!'
    else
        echomsg 'error'
    endif
endfunction

function! Tweet#Reply() abort
    let post_url = 'https://api.twitter.com/1.1/statuses/update.json'
    let tweet_id = input('tweet_id: ' )
    let ret = webapi#oauth#post(post_url, s:Oauth(), {} ,{'in_reply_to_status_id':tweet_id, 'status':s:returnTweet()})
    echo "\n"
    if ret['status'] == 200
        echo 'success!!'
    else
        echomsg 'error'
    endif
    return ret
endfunction

function! Tweet#Look() abort
    let screen_name = input('screenname: ')
    let l:count = input('count: ')
    call delete(expand("$HOME/TL.txt"))
    let get_url = 'https://api.twitter.com/1.1/statuses/user_timeline.json'
    let ret = webapi#oauth#get(get_url, s:Oauth(), {}, {'screen_name':screen_name,"count": l:count})
    if ret['status'] == 200
        let dict = webapi#json#decode(ret.content)
        let TLList = []
        let outputfile = expand("$HOME/TL.txt")

        for item in dict
            call add(TLList, item['text'])
            call add(TLList, 'Tweet_id: '.item['id'])
            call add(TLList, '')
        endfor
        call writefile(TLList,  outputfile)
        execute("vnew $HOME/TL.txt")
    else
        echomsg 'error'
    endif
endfunction

function Tweet#Retweet()
    let retweet_id = input('id :')
    let post_url = 'https://api.twitter.com/1.1/statuses/retweet/'.retweet_id.'.json'
    echo post_url
    let  ret = webapi#oauth#post(post_url, s:Oauth(), {}, {'id':retweet_id})
    if ret['status'] == 200
        echo 'success!!'
    else
        echomsg 'error'
    endif
    return ret
endfunction

function Tweet#Edit()
    let inputfile = "$HOME/test.txt"
    execute ":new " . escape(inputfile, ' ')
endfunction

function Tweet#PostFavo()
    let favo_url = "https://api.twitter.com/1.1/favorites/create.json"
    let tweet_id = input('id :' )
    let ret = webapi#oauth#post(favo_url, s:Oauth(), {} ,{'id':tweet_id})
    echo ''
    if ret['status'] == 200
        echo 'success!'
    else
        echomsg 'error!'
    endif
    return ret
endfunction

function s:returnTweet()
    let list = []
    let inputfile = (expand('$HOME/test.txt'))
    for line in readfile(inputfile)
        call add(list, line)
    endfor
    call delete(expand('$HOME/test.txt'))
    return join(list, "\n")
endfunction

function s:Oauth()
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
    return ctx
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
