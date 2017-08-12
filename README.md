# SHIM - Shell Highlighting IMproved

An alternative shell syntax highlighting file for VIM

SHIM's philosophy: **Highlight correct code correctly!** The highlighter should adapt to the code, not the other way around!



## How to use

Download the file shim.vim and copy it to `~/.vim/syntax/sh.vim`. Any shell files you open should now use SHIM's highlighting. No plugins required!



## History / Motivation

My bash scripts broke VIM's internal bash highlighting ¯\\_(ツ)_/¯

I soon discovered that the original highlighting file was already quite sophisticated and feature-rich, highlighting mismatching if's and fi's as an example. However, those features require all blocks to be closed in the correct order, leading to errors in combination with heredocs.

```bash
print_text () { cat <<-EOF; }
    This is a heredoc that
    spans over multiple lines.
    Note that I closed the function
    block way above already
EOF
```

As making the highlighter 'understand' these constructs looked impossible to me, I chose to make a 'dumb' highlighter instead.



## Issues

While the highlighter works fine with my code, I cannot ensure that for everyone. If you find a problem, just send me an example.

Particularly the following areas are challenging and/or cannot be correctly implemented:
- Escaped spaces `\ `
- Command substitution using backticks, especially when nested

Note that the color scheme is quite different to the standard bash highlighter. I have tuned the colors to subjectively "look good" in my terminal vim, so if you find something not looking right in graphical VIM, feel free to suggest improvements.



## Special thanks

- The makers and contributors of VIM for an excellent text editor
- The makers and contributors of [Bash Hackers](http://wiki.bash-hackers.org/start) for all the detailed information about bash's syntax elements
