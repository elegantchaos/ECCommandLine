//
//  main.swift
//  ECCommandLineTest
//
//  Created by Sam Deane on 27/04/2015.
//  Copyright (c) 2015 Elegant Chaos. All rights reserved.
//

#import <ECCommandLine/ECCommandLine.h>

int main(int argc, const char * argv[])
{
	CGFloat r = [ECRandom randomDoubleFromZeroTo:1.0]; // helpfully, the linker won't link in the ECCore framework if we only use categories from it - so lets use an actual function
	(void)r;
	
	int result;
	@autoreleasepool {
		
		result = ECCommandLineMain(argc, argv);
		
	}
	
	return result;
}

