//
//  ViewController.h
//  EZPassRecordingToFFTV1
//
//  Created by David Carter on 4/28/15.
//  Copyright (c) 2015 Team16. All rights reserved.
//

#import <UIKit/UIKit.h>

//Import Accelerate Framework
#import <Accelerate/Accelerate.h>

//Import EZAudio header
#import "EZAudio.h"

//Import chatterFunctions
#import "chatterFunctions.h"

//default audio file example

#define kAudioFileDefault [[NSBundle mainBundle] pathForResource:@"simple-drum-beat" ofType:@"wav"]

// Using EZOutput Data Source to provide output data to the EZOutput component.

@interface ViewController : UIViewController <EZAudioFileDelegate, EZOutputDataSource>

#pragma mark - Componenets 

//EZAudioFile currently selected audio file

@property (nonatomic, strong)EZAudioFile *audioFile;

//AudioPlot
@property (weak, nonatomic) IBOutlet EZAudioPlot *audioPlot;

//AudioPlot for Frequency
@property (weak, nonatomic) IBOutlet EZAudioPlot *audioPlotFrequency;

//label to diplay the  current file path with waveform shown
@property (weak, nonatomic) IBOutlet UILabel *filePathLabel;

//slider to indicate the current frame position in the audio file
@property (weak, nonatomic) IBOutlet UISlider *framePositionSlider;

//Bool indicating wheter or not we've reached the end of the file
@property (nonatomic,assign) BOOL eof;

#pragma mark- Actions 

//Switches the plot drawing type between buffer plot and rolling plot

- (IBAction)changePlotType:(id)sender;

//begins playback if a file is loaded. pauses if the file is already playing
- (IBAction)play:(id)sender;

//seeks to a specific frame in the audio file
- (IBAction)seekToFrame:(id)sender;

//function get new spindle speed (maybe have button to call this funciton in future)
//-(float) getSpindleSpeed: (float[])frequecies;


@end

