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
	int result;
	@autoreleasepool {
		
		result = ECCommandLineMain(argc, argv);
		
	}
	
	return result;
}

