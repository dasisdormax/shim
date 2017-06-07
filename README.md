# SHIM - Shell Highlighting IMproved

An alternative shell syntax highlighting file for VIM

SHIM's philosophy: **Highlight correct code correctly!** I do not care if bad code is lighlighted as if it was good, but I do not want to rewrite my code just to please the highlighter.



## Motivation

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

As I learned VIM syntax highlighting, I soon found out that we cannot model this correctly. So I chose to make a 'dumb' highlighter instead that had almost no idea of your code structure, just highlighting instead of interpreting syntax elements/blocks.

## Special thanks

- The makers and contributors of VIM for an excellent text editor
- The makers and contributors of [Bash Hackers](http://wiki.bash-hackers.org/start) for all the detailed information about bash's syntax elements
