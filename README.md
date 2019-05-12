# Tweet.vim

This plugin can tweet from Vim and Neovim

## Requirement

- [webapi-vim](https://github.com/mattn/webapi-vim)

- [open-browser.vim](https://github.com/tyru/open-browser.vim)

## Installtion
If you use [dein.vim](https://github.com/Shougo/dein.vim)

```
call dein#add('kazukazuinaina/Tweet.vim')
```

If you use [Vim-plug](https://github.com/junegunn/vim-plug)

```
Plug 'kazukazuinaina/Tweet.vim'
```


## Usage

**This plugin have three function.**

- TweetEdit
- Tweet
- Look User's tweet
- Retweet

If you want to write sentence to do tweet, do below's command.

```
:TweetEdit
```

You want to do tweet, you run below command.

```
:Tweet
```

You want to look user's tweet and tweet id, you run below command.

```
:TweetLook 'screenname' 'get Tweet count (maximum is 200)'
```

You want to do retweet, you run below command and input tweet id.

```
:RT
```
