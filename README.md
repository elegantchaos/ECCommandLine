ECCommandLine
=============

ECCommandLine provides support to simplify building command line tools that work like xcbuild, git, and many others.

In these tools you have a single executable, which then typically takes one or more related commands as the first parameter(s), eg:

> burgermeister open
> burgermeister make...
> burgermeister sell...
> burgermeister close

These commands determine which action the tool does, and the tool may then interpret additional arguments, eg

> burgermeister make cheeseburger
> burgermeister make quarterpounder

They may also react to a number of unix style options, eg

> burgermeister make quarterpounder --cheese=NO --fries=YES --no-mayo.

All of this fancy-shmancy parsing of the input makes the command easy to use, but it's mostly repetitive drudge work to code. In a nutshell, what ECCommandLine does is supply all the plumbing for this, such that:

- you describe all the commands and options with info.plist entries
- this includes help text, short and long option variants, default values, etc
- you list the class which implements each command

When you build a tool with ECCommandLine

- you automativally get a formatted "usage" output if the user fails to supply a command
- you automatically get a help command which inspects the info.plist to supply help
- you automatically get a version command (and --version option) which report version info
- arguments that the user supplies are automatically checked against the info.plist for basic validity
- default values are supplied for missing options (when the info.plist has defined them)
- your predefined class is constructed and invoked to perform the command the user chose
- your class is given the remaining unprocessed arguments
- all --option parameters are parsed for you and can be examined via an API
- support is included for commands which output stuctured data, such that the output can then be automatically formatted as text, or json (so that a user can get the text, but a tool can get the json)

