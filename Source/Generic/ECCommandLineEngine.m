// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECCommandLineEngine.h"
#import "ECCommandLineCommand.h"
#import "ECCommandLineOption.h"

#import <getopt.h>
#import <stdarg.h>

typedef NS_ENUM(NSUInteger, ECCommandLineOutputMode)
{
	ECCommandLineOutputText,
	ECCommandLineOutputJSON
};

@interface ECCommandLineEngine()

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSMutableDictionary* commands;
@property (strong, nonatomic) NSMutableDictionary* options;
@property (strong, nonatomic) NSMutableDictionary* optionsByShortName;
@property (strong, nonatomic) ECCommandLineOption* helpOption;
@property (strong, nonatomic) ECCommandLineOption* versionOption;
@property (strong, nonatomic) NSMutableDictionary* infoRecord;
@property (strong, nonatomic) NSMutableArray* infoStack;
@property (strong, nonatomic) NSMutableString* output;
@property (assign, nonatomic) ECCommandLineOutputMode outputMode;
@property (strong, nonatomic) NSURL* outputJSONURL;
@end

@implementation ECCommandLineEngine

- (id)initWithDelegate:(id<ECCommandLineEngineDelegate>)delegate
{
	if ((self = [super init]) != nil)
	{
		self.delegate = delegate;
		self.commands = [NSMutableDictionary dictionary];
		self.options = [NSMutableDictionary dictionary];
		self.optionsByShortName = [NSMutableDictionary dictionary];
		self.infoRecord = [NSMutableDictionary dictionary];
		self.infoStack = [NSMutableArray array];
		self.outputMode = ECCommandLineOutputText;
		self.output = [NSMutableString new];

		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[self.delegate engineDidFinishLaunching:self];
		}];
	}

	return self;
}

ECDefineDebugChannel(CommandLineEngineChannel);

#pragma mark - Commands

+ (void)addCommandNamed:(NSString*)mainName withInfo:(NSDictionary*)info toDictionary:(NSMutableDictionary*)dictionary parentCommand:(ECCommandLineCommand*)parentCommand
{
	NSArray* names = @[mainName];
	NSArray* aliases = info[@"aliases"];
	if (aliases) {
		names = [names arrayByAddingObjectsFromArray:aliases];
		info = [info dictionaryWithoutKey:@"aliases"];
	}

	ECCommandLineCommand* command = [ECCommandLineCommand commandWithName:mainName info:info parentCommand:parentCommand];
	for (NSString* name in names) {
		ECDebug(CommandLineEngineChannel, @"registered command %@", name);
		dictionary[name] = command;
	}
}

- (void)registerCommands:(NSDictionary*)commands
{
	[commands enumerateKeysAndObjectsUsingBlock:^(NSString* name, NSDictionary* info, BOOL *stop) {
			[ECCommandLineEngine addCommandNamed:name withInfo:info toDictionary:self.commands parentCommand:nil];
	}];
}

#pragma mark - Options

- (void)registerOptionNamed:(NSString*)name withInfo:(NSDictionary*)info
{
	ECDebug(CommandLineEngineChannel, @"registered option %@", name);

	ECCommandLineOption* option = [ECCommandLineOption optionWithName:name info:info];
	self.options[name] = option;
	self.optionsByShortName[[NSString stringWithFormat:@"%c", option.shortOption]] = option;
}

- (void)registerOptions:(NSDictionary*)options
{
	[options enumerateKeysAndObjectsUsingBlock:^(NSString* name, NSDictionary* info, BOOL *stop) {
		[self registerOptionNamed:name withInfo:info];
	}];
}

- (void)logArguments:(int)argc argv:(const char **)argv
{
	for (int n = 0; n < argc; ++n)
	{
		NSLog(@"%s", argv[n]);
	}
}

- (struct option*)setupOptionsArrayWithShortOptions:(const char**)shortOptions
{
	NSUInteger optionsCount = [self.options count];
	struct option* optionsArray = calloc(optionsCount + 1, sizeof(struct option));
	__block struct option* optionPtr = optionsArray;
	NSMutableString* shortBuffer = [[NSMutableString alloc] init];
	[self.options enumerateKeysAndObjectsUsingBlock:^(NSString* optionName, ECCommandLineOption* option, BOOL *stop) {
		optionPtr->name = strdup([optionName UTF8String]);
		optionPtr->has_arg = option.mode;
		optionPtr->flag = NULL;
		optionPtr->val = option.shortOption;
		[shortBuffer appendFormat:@"%c", option.shortOption];
		optionPtr++;
	}];

	*shortOptions = strdup([shortBuffer UTF8String]);

	return optionsArray;
}

- (void)cleanupOptionsArray:(struct option*)optionsArray withShortOptions:(const char*)shortOptions
{
	NSUInteger optionsCount = [self.options count];
	for (NSUInteger n = 0; n < optionsCount; ++n)
	{
		free((char*)(optionsArray[n].name));
	}
	free(optionsArray);
	free((void*)shortOptions);
}

- (void)processOption:(ECCommandLineOption*)option value:(id)value
{
	if (!value)
		value = @(YES);

	ECDebug(CommandLineEngineChannel, @"option %@ = %@", option.name, value);
	option.value = value;
}

- (id)optionForKey:(NSString*)key
{
	ECCommandLineOption* option = self.options[key];
	id result = option.value;

	return result;
}

- (CGFloat)doubleOptionForKey:(NSString*)key
{
	ECCommandLineOption* option = self.options[key];
	CGFloat result = [option.value doubleValue];

	return result;
}

- (BOOL)boolOptionForKey:(NSString*)key {
	BOOL result = [[self optionForKey:key] boolValue];

	return result;
}

- (NSString*)stringOptionForKey:(NSString*)key {
	NSString* result = [[self optionForKey:key] description];

	return result;
}

- (NSURL*)urlOptionForKey:(NSString*)key defaultingToWorkingDirectory:(BOOL)defaultingToWorkingDirectory {
	NSString* path = [[self stringOptionForKey:key] stringByStandardizingPath];
	if (!path && defaultingToWorkingDirectory)
		path = [@"./" stringByStandardizingPath];

	NSURL* url = nil;
	if (path)
		url = [NSURL fileURLWithPath:path];

	return url;
}

- (NSArray*)arrayOptionForKey:(NSString *)key separator:(NSString *)separator {
	NSString* value = [self stringOptionForKey:key];
	NSArray* result = [value componentsSeparatedByString:separator];

	return result;
}

- (void)setupFromBundle
{
	NSBundle* bundle = [NSBundle mainBundle];
	NSDictionary* commands = bundle.infoDictionary[@"Commands"];
	NSDictionary* options = bundle.infoDictionary[@"Options"];
	[self registerCommands:commands];
	[self registerOptions:options];

	// TODO: maybe load these from a plist?
	[self registerOptions:
	 @{
	 @"help": @{@"short" : @"h", @"help" : @"show command help"},
	 @"outputJSON": @{@"short" : @"J", @"help" : @"produce output as json rather than text", @"type" : @"path", @"mode" : @"optional"},
	 @"version": @{@"short" : @"v", @"help" : @"show version number"},
	 }
	 ];

	[self registerCommands:
	 @{ @"help": @{@"class" : @"ECCommandLineHelpCommand", @"help" : @"Show this help message."}
	 }
	 ];

	self.versionOption = self.options[@"version"];
	self.helpOption = self.options[@"help"];
}

- (ECCommandLineResult)processArguments:(int)argc argv:(const char **)argv
{
	self.name = [[[NSString alloc] initWithUTF8String:argv[0]] lastPathComponent];

	//	[self logArguments:argc argv:argv];
	[self setupFromBundle];

	const char* shortOptions = nil;
	struct option* optionsArray = [self setupOptionsArrayWithShortOptions:&shortOptions];
	int optionIndex = -1;
	int shortOption;

	NSUInteger processedOptions = 0;
	while ((shortOption = getopt_long(argc, (char *const *)argv, shortOptions, optionsArray, &optionIndex)) != -1)
	{
		++processedOptions;
		switch (shortOption)
		{
			case '?':
				NSLog(@"unknown option %s", optarg);
				break;

			case ':':
				NSLog(@"missing value %s", optarg);
				break;

			default:
			{
				ECCommandLineOption* option = self.optionsByShortName[[NSString stringWithFormat:@"%c", (char)shortOption]];
				NSString* optionValue = optarg ? [[NSString alloc] initWithCString:optarg encoding:NSUTF8StringEncoding] : nil;
				[self processOption:option value:optionValue];
			}
		}
	}

	[self cleanupOptionsArray:optionsArray withShortOptions:shortOptions];
	[self setupOutput];

	ECCommandLineResult result;
	if ((processedOptions + 1) < (NSUInteger)argc)
	{
		NSMutableArray* remainingArguments = [NSMutableArray arrayWithCapacity:argc - processedOptions];
		for (NSUInteger n = processedOptions + 1; n < (NSUInteger)argc; ++n)
		{
			[remainingArguments addObject:[[NSString alloc] initWithCString:argv[n] encoding:NSUTF8StringEncoding]];
		}

		result = [self processCommands:remainingArguments];
	}
	else
	{
		result = [self processNoCommands];
	}

	switch (result)
	{
		case ECCommandLineResultUnknownCommand:
			[self showUsage];
			break;

		default:
			break;
	}

	if (result == ECCommandLineResultOKButTerminate)
	{
		[self processOutput];
	}

	return result;
}

- (void)setupOutput
{
	id value = [self optionForKey:@"outputJSON"];
	if ([value isKindOfClass:[NSNumber class]] || ([value isKindOfClass:[NSString class]] && ([value isEqualToString:@"YES"] || [value isEqualToString:@"NO"])))
	{
		if ([self boolOptionForKey:@"outputJSON"])
			self.outputMode = ECCommandLineOutputJSON;
	}
	else
	{
		self.outputJSONURL = [self urlOptionForKey:@"outputJSON" defaultingToWorkingDirectory:NO];
	}
}

- (void)processOutput
{
	BOOL printJSON = self.outputMode == ECCommandLineOutputJSON;
	if (printJSON || self.outputJSONURL)
	{
		NSError* error;
		NSData* data = [NSJSONSerialization dataWithJSONObject:self.info options:NSJSONWritingPrettyPrinted error:&error];
		if (!data)
		{
			[self outputError:error format:@"Failed to convert output info to JSON"];
		}
		else
		{
			NSString* text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			if (self.outputJSONURL)
			{
				if (![text writeToURL:self.outputJSONURL atomically:YES encoding:NSUTF8StringEncoding error:&error])
				{
					[self outputError:error format:@"Failed to write info file"];
				}
			}
			else if (printJSON)
			{
				printf("%s\n", [text UTF8String]);
			}
		}
	}
}

- (void)exitWithResult:(ECCommandLineResult)result
{
	[self processOutput];
	exit(result);
}

- (void)outputFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2)
{
	va_list args;
	va_start(args, format);
	NSString* string = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);

	if (self.outputMode == ECCommandLineOutputText)
		printf("%s", [string UTF8String]);
	else
		[self.output appendString:string];
}

- (void)outputError:(NSError *)error format:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);
	NSString* string = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);

	NSString* errorString = error ? [NSString stringWithFormat:@"(%@ %@:%ld)\n", error.localizedFailureReason, error.domain, error.code] : @"";
	fprintf(stderr, "%s\n%s\n", [string UTF8String], [errorString UTF8String]);
}

- (void)outputInfo:(id)info withKey:(NSString*)key {
	self.infoRecord[key] = info;
}

- (void)openInfoGroupWithKey:(NSString*)key {
	NSMutableDictionary* level = [NSMutableDictionary dictionary];
	self.infoRecord[key] = level;
	[self.infoStack addObject:self.infoRecord];
	self.infoRecord = level;
}

- (void)closeInfoGroup {
	NSUInteger count = [self.infoStack count];
	if (count) {
		NSUInteger index = count - 1;
		NSMutableDictionary* level = self.infoStack[index];
		[self.infoStack removeObjectAtIndex:index];
		self.infoRecord = level;
	}
}

- (NSDictionary*)info {
	return self.infoRecord;
}

- (void)showUsage
{
	NSString* usage = [NSString stringWithFormat:@"Usage: %@", self.name];
	NSUInteger paddingLength = [usage length];
	usage = [usage stringByAppendingString:@" <command> [<args>]\n"];
	[self outputFormat:@"%@", usage];
	NSString* padding = [@"" stringByPaddingToLength:paddingLength withString:@" " startingAtIndex:0];
	NSMutableString* string = [NSMutableString stringWithString:padding];
	[self.options enumerateKeysAndObjectsUsingBlock:^(NSString* name, ECCommandLineOption* option, BOOL *stop) {
		NSString* optionString = [NSString stringWithFormat:@" [%@ | %@]", option.longUsage, option.shortUsage];
		if ([string length] + [optionString length] > 70)
		{
			[self outputFormat:@"%@\n", string];
			[string setString:padding];
		}

		[string appendString:optionString];
	}];
	[self outputFormat:@"%@\n", string];

	[self outputFormat:@"\nCommands:\n"];
	[self.commands enumerateKeysAndObjectsUsingBlock:^(NSString* name, ECCommandLineCommand* command, BOOL *stop) {
		[self outputFormat:@"\t%@\n", [command summaryAs:name parentName:nil]];
	}];

	[self outputFormat:@"\n\nSee ‘%@ help <command>’ for more information on a specific command.\n", self.name];
}

- (void)showVersion
{
	NSBundle* bundle = [NSBundle mainBundle];
	NSString* version = [bundle bundleFullVersion];
	if (self.outputMode == ECCommandLineOutputJSON) {
		[self outputInfo:self.name withKey:@"name"];
		[self outputInfo:[bundle bundleVersion] withKey:@"version"];
		[self outputInfo:[bundle bundleBuild] withKey:@"build"];
	} else {
		[self outputFormat:@"%@ %@\n", self.name, version];
	}
}

- (ECCommandLineResult)processCommands:(NSMutableArray*)commands
{
	if ([self.delegate respondsToSelector:@selector(engine:willProcessCommands:)])
		[self.delegate engine:self willProcessCommands:commands];

	NSString* commandName = [commands objectAtIndex:0];
	[commands removeObjectAtIndex:0];

	ECCommandLineResult result;
	if ([commandName isEqualToString:@"--"])
	{
		// skip to next command
		result = [self processCommands:commands];
	}
	else
	{
		// pull out the top level command
		ECCommandLineCommand* command = [self commandWithName:commandName];
		if (command)
		{
			// resolve the actual command, which may be a subcommand - eg might be "export artboards", where "artboards" is a subcommand of "export"
			ECCommandLineCommand* resolved = [command resolveCommandPath:commands];
			result = [resolved engine:self processCommands:commands];
		}
		else
		{
			result = [self processUnknownCommand:commandName];
		}
	}

	if ([self.delegate respondsToSelector:@selector(engine:didProcessCommands:)])
		[self.delegate engine:self didProcessCommands:commands];

	return result;
}

- (ECCommandLineResult)processNoCommands
{
	if ([self.delegate respondsToSelector:@selector(engine:willProcessCommands:)])
		[self.delegate engine:self willProcessCommands:@[]];

	ECCommandLineResult result = ECCommandLineResultOKButTerminate;
	if ([self.versionOption.value boolValue])
	{
		[self showVersion];
	}
	else if ([self.helpOption.value boolValue])
	{
		[self showUsage];
	}
	else
	{
		result = ECCommandLineResultUnknownCommand;
	}

	if ([self.delegate respondsToSelector:@selector(engine:didProcessCommands:)])
		[self.delegate engine:self didProcessCommands:@[]];

	return result;
}

- (ECCommandLineResult)processUnknownCommand:(NSString*)command
{
	[self outputFormat:@"Unknown command ‘%@’\n\n", command];
	return ECCommandLineResultUnknownCommand;
}

- (ECCommandLineCommand*)commandWithName:(NSString *)name
{
	ECCommandLineCommand* result = self.commands[name];

	return result;
}

- (ECCommandLineOption*)optionWithName:(NSString *)name
{
	ECCommandLineOption* result = self.options[name];

	return result;
}

- (NSUInteger)paddingLength
{
	return 15;
}

@end