## vis-surround

`vis-surround` aims to port Tim Pope's [vim-surround](https://github.com/tpope/vim-surround) to Vis. It is not quite as powerful yet, see the TODO list below.

Add this to your `visrc.lua`:
```
require("vis-surround")
```

### Usage

Use the `cs` prefix and two surrounding characters to change surroundings, use `ds` and a surrounding character to delete a surrounding.

Examples:

Pressing `cs"'` inside
```
"Hello world!"
```
will give you:
```
'Hello world!'
```
Pressing `cs{]` (if you use opening or closing brackets doesn't matter) inside
```
{Hello world!}
```
will give you:
```
[Hello world!]
```
To delete the `[`, `]` characters press `ds[`. This is the result:
```
Hello world!
```

### TODO
- [ ] XML tags
- [ ] Adding tags with text objects