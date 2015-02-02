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

The options that a particular command uses are just listed by name.

To allow the tool to give a fuller description of them, supply default, and so on, they are also listed in more detail in their own top-level dictionary in the Info.plist, called "Options".

The name of each entry is the option, and the value is a dictionary describing it.

For example, the following describes the "tool" and "detergent" options. Both are expected to be strings. The tool option has a default value that can be supplied if the user doesn't specify it on the command line.

    "Options" : {
		"tool" : {
			"short" : "t",
			"help" : "Tool to use when cleaning.",
			"type" : "string",
			"default" : "brush"
		},
		"detergent" : {
			"short" : "d",
			"help" : "Detergent to use when cleaning.",
			"type" : "string"
		}
	}

### Implementing A Command

To implement, you make a new class which inherits from ECCommandLineCommand, and override the engine:didProcessWithArguments: method.

This method performs the work of the command, and returns an ECCommandLineResult.

You are passed in any unprocessed arguments, and can call back to the command line engine to obtain values for options, and to output values to stdout or stderr.

Asynchronous commands are supported - if you return StayRunning from the command, the engine will spin in a run loop until you call its exitWithResult method.

Here's a simple example:

	class CleanCommand : ECCommandLineCommand {
    
	    override func engine(engine : ECCommandLineEngine, didProcessWithArguments arguments : NSArray) -> ECCommandLineResult {
	        // do something asynchronous
			doMyAsyncThingWithCompletion { (result : NSError? ) -> Void in
				if (result == nil) {
	                engine.outputDescription("hurrah")
	                engine.exitWithResult(ECCommandLineResult.OK)
					} else {
	                    engine.outputError(error, description:"failed to fetch mentions")
	                    engine.exitWithResult(ECCommandLineResult.ImplementationReturnedError)
			        }
	            })
            
	        return ECCommandLineResult.StayRunning
	    }
