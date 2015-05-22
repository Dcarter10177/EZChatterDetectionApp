//
//  chatterFunctions.h
//  EZPassRecordingToFFTV1
//
//  Created by David Carter on 5/18/15.
//  Copyright (c) 2015 Team16. All rights reserved.
//

#import <Foundation/Foundation.h>



float determineToothPassFrequency(int spindleSpeed, int numFlutes);

float determineChatterFrequency(NSMutableArray* sortedFreqBins, int toothpassFreq);

NSArray* filterOutToothPassingFrequencyHarmonics(int freq, float mag, int toothpassingFreq, int nOver2);