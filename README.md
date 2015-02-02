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

    > burgermeister make quarterpounder --cheese --fries=curly --no-mayo.

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
- failure to supply the correct number of arguments is reported
- your predefined class is constructed and invoked to perform the command the user chose
- your class is given any named arguments that the info.plist described
- it is also given the remaining unprocessed arguments to use as it needs
- all --option parameters are parsed for you and can be examined via an API
- support is included for commands which output stuctured data, such that the output can then be automatically formatted as text, or json (so that a user can get the text, but a tool can get the json)

### Describing Commands

Commands are described by a top-level dictionary in the Info.plist called "Commands".

The name of each entry represents the argument to match against for the command to be triggered. The value is a dictionary describing the command to run when that argument is supplied.

For example, the following describes the "clean" command.

It takes one parameter - the thing to clean.

It must also be supplied with the --tool option (presumably saying which cleaning tool to use), and can optionally be supplied with the --detergent option.


   "Commands" : {
	   "clean" : {
		   "class" : "CleanCommand",
		   "help" : "Clean things up.",
		   "arguments" : (
			   {
				   "short" : "thing",
				   "description" : "The thing to clean."
			   }
		   ),
		   "options" : {
				required : ( "tool" ),
				optional : ( "detergent" )
			},
	   }
   }


### Describing Options

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>user</key>
	<dict>
		<key>short</key>
		<string>u</string>
		<key>mode</key>
		<string>required</string>
		<key>help</key>
		<string>Github username</string>
		<key>type</key>
		<string>string</string>
		<key>default</key>
		<string>samdeane</string>
	</dict>
	<key>remote</key>
	<dict>
		<key>short</key>
		<string>r</string>
		<key>mode</key>
		<string>required</string>
		<key>help</key>
		<string>Git remote to use</string>
		<key>type</key>
		<string>string</string>
		<key>default</key>
		<string>origin</string>
	</dict>
	<key>branch</key>
	<dict>
		<key>short</key>
		<string>b</string>
		<key>mode</key>
		<string>required</string>
		<key>help</key>
		<string>Git branch to check merged status against</string>
		<key>type</key>
		<string>string</string>
		<key>default</key>
		<string>develop</string>
	</dict>
	<key>password</key>
	<dict>
		<key>short</key>
		<string>p</string>
		<key>mode</key>
		<string>optional</string>
		<key>help</key>
		<string>Github password</string>
		<key>type</key>
		<string>string</string>
	</dict>
</dict>
</plist>
