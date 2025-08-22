# Contribution Guidelines

## Code Of Conduct

- Be nice to others
- Stick to the purpose, which is helping handling neovim config snippets
- Remember this is GPL3.0+

## Code Style

The project provides configs for [stylua][3] and editorconfig. Some files (like this readme) migh include a mode line. If you can't honor any of those:

- indent with tabs, shifh width is 4 spaces
- use unix line breaks
- single over double quotes
- you code should not break into new lines with two windows shown side by side with a tree on the left. 78 is the general guideline but 95 might be still ok. Windows in this case means two neovim windows in one terminal or ssh session at 1920x1080 pixel and a side bar / tree on the left not exceeding 30 columns.

The README contains vimdoc sections to avoid formatting issues which some one (may be even you or me) should fix some day. Ensure the help is proper readable.

## Tooling

The project provides a GNU compatible Makefile to run tests, create the test fixture and also the documentation using [panvimdoc][1] as container. The init lua provided as project setting can be loaded with `:source .nvim/init.lua` or by using [tiny-pjs][2]. Either podman or docker is required to run this target.

## Legal requirements

When adding new files please use the GPL notice with your own details. When adding code to a new file you might add yourself to the list of copyright holders in that particular file. The author with the latest change should appear first as currently common practice (when writing this document). An author may only be removed from the copyright holders of a file if at least one of following the conditions are met.

- the author himself removes his credit
- the credit has to be removed for legal purpose by applicabable law
- all code from the author has been removed *AND* at least one of the *above* conditions apply

<!-- vim: set et ts=4 sw=4 tw=0: -->

[1]: https://github.com/hdheepak/panvimdoc
[2]: https://github.com/Coding4Glory/tiny-pjs
[3]: https://github.com/JohnnyMorganz/StyLua
