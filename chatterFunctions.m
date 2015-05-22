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

#pragma mark - filter out toothPassingFrequencyBins

NSArray* filterOutToothPassingFrequencyHarmonics(int i, float amp, int toothpassingFreq, int nOver2){
    // convert bin index to frequency data
    int freqBin = i * 22000/nOver2;
    
    // initialize storage array
    //NSMutableArray *frequencyBins = [[NSMutableArray alloc]init];
    
    
    // apply toothpass freq filter (can later be chanegd to comb filter)
    // intigers used as resoultion of comb (currently set to +/- 7 Hz)
    
    for (int j = 1; j<= nOver2; j++){
        if ((freqBin <= j*toothpassingFreq +7 && freqBin >= j*toothpassingFreq - 7) || freqBin == 0){
            amp = 0;
        }
    }
    
    // Convert freq and magnitude to NSInteger
    NSNumber *freq = [NSNumber numberWithInt:freqBin];
    
    NSNumber *magnitude = [NSNumber numberWithFloat:amp];
    
    // Create freq mag pair array
    NSArray *freqMagPair = [NSArray arrayWithObjects: magnitude, freq, nil];
    
    return freqMagPair;
    
}

//NSMutableArray* filterOutToothPassingFrequencyHarmonics(NSMutableArray* freqBins,int toothpassingFreq){
//    
//    // function to do data analysis getSpindleSpeed (note frequency bins array is now sorted)
//    
//    for (int i = 0; i <= freqBins.count; i++){
//        NSNumber *freq; NSNumber *mag;
//        NSMutableArray *data = [NSMutableArray arrayWithObjects:freq, mag, nil];
//        freqBins[i] = data;
//        for (int n = 0; n <= (20000/toothpassingFreq); n++) {
//            if ( n*toothpassingFreq-5 <= (int)data[0] && (int)data[0]<= n*toothpassingFreq+5 ){
//                data[1] = 0;
//            }
//        }
//        
//        
//    }



//
//    // function to do data analysis getSpindleSpeed (note frequency bins array is now sorted)
//      [frequencyBins sortUsingComparator:^(id a, id b){
//        return[b[0] compare:a[0]];
//    }];
//    
//    return freqBins;
//}


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
