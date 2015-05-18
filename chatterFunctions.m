//
//  chatterFunctions.m
//  EZPassRecordingToFFTV1
//
//  Created by David Carter on 5/18/15.
//  Copyright (c) 2015 Team16. All rights reserved.
//

#import "chatterFunctions.h"


#pragma mark - toothPassingFreqFunciton

// number of flutes * spinldeSpeed/60

int determineToothPassFreq(int spindleSpeed,int numFlutes ){
    int toothPassFreq;
    
    toothPassFreq = numFlutes * spindleSpeed / 60;
    
    return toothPassFreq;
}

#pragma mark - MaxFrequenciesFunction

float determineChatterFrequency(NSMutableArray* freqBins, int toothpassFreq){
    float chatterFrequency; // initailize return variable

    // loop through array and find max freq that isnt a tooth passing freq (need to apply comb filter here later)
    
    
    
    

    // If toolpassfrequency ignore
    
    // filter out natural and tool passing frequencies (comb filter)
    
            //    NSMutableArray * filtered = [NSMutableArray array];
            //    for (MyCustomObject * object in myArray) {
            //        if ([[object aProperty] isEqual:@"someValue"]) {
            //            [filtered addObject:object];
            //        }
            //    }
    
    
    // return chatter frequency
    return chatterFrequency;
}
