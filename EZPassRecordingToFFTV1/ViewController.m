//
//  ViewController.m
//  EZPassRecordingToFFTV1
//
//  Created by David Carter on 4/28/15.
//  Copyright (c) 2015 Team16. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    float  *_waveformData;
    UInt32 _waveformDrawingIndex;
    UInt32 _waveformFrameRate;
    UInt32 _waveformTotalBuffers;
    //--------------------for FFT-----------------
    COMPLEX_SPLIT _A;
    FFTSetup      _FFTSetup;
    BOOL          _isFFTSetup;
    vDSP_Length   _log2n;
    float         _i_max;
    
}
@end

// Globals
float fftBuff[8192];            //1024
int samplesRemaining = 8192;    //1024
int samplesToCopy = 512;
int FFTLEN = 8192;              //1024
int fftBuffIndex = 0;


@implementation ViewController
@synthesize audioPlotFrequency;
@synthesize audioFile = _audioFile;
@synthesize audioPlot = _audioPlot;
@synthesize eof = _eof;
@synthesize framePositionSlider = _framePositionSlider;


#pragma mark - Initialization
-(id)init {
    self = [super init];
    if(self){
        [self initializeViewController];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initializeViewController];
    }
    return self;
}

#pragma mark - Initialize View Controller Here
-(void)initializeViewController {
}

#pragma mark - Customize the Audio Plot
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup
    // Plot type
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    // Fill
    self.audioPlot.shouldFill      = YES;
    // Mirror
    self.audioPlot.shouldMirror    = YES;
    
    
    // Try opening the sample file

    [self openFileWithFilePathURL:[NSURL fileURLWithPath:kAudioFileDefault]];

    
    // customize audioPlotFrequency
    self.audioPlotFrequency.shouldFill      = YES;
    self.audioPlotFrequency.plotType        = EZPlotTypeBuffer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - SpindeSpeedFunciton
//+(float)getSpindleSpeed:(float[])frequecy{
//    float newSpindleSpeed; // initialize the return spindle speed variable
//    
//    // iterate through array to get max frequency
//    
//    for (int j = 1; j < 512; j++) //already nested in a loop no need to call another one
//    {
//        printf("%3d\t%6.2f\n", j, frequecy[j]); // normalized magnatudes
//    }
//    // if sampeling at 1023 Hz each bin holds a span of 44hz
//    
//    return newSpindleSpeed;
//}

# pragma mark FFT

//Adapted from http://batmobile.blogs.ilrt.org/fourier-transforms-on-an-iphone/

-(void)createFFTWithBufferSize:(float)bufferSize withAudioData:(float*)data {
    
    // Setup the length
    _log2n = log2f(bufferSize);
    
    // Calculate the weights array. This is a one-off operation. Taxing on Memory
    _FFTSetup = vDSP_create_fftsetup(_log2n, FFT_RADIX2);
    
    // For an FFT, numSamples must be a power of 2, i.e. is always even
    int nOver2 = bufferSize/2;
    
    // Populate *window with the values for a hamming window function
    float *window = (float *)malloc(sizeof(float)*bufferSize);
    vDSP_hamm_window(window, bufferSize, 0);
    
    // Window the samples
    vDSP_vmul(data, 1, window, 1, data, 1, bufferSize);
    free(window);
    
    // Define complex buffer
    _A.realp = (float *) malloc(nOver2*sizeof(float));
    _A.imagp = (float *) malloc(nOver2*sizeof(float));
    
}

-(void)updateFFTWithBufferSize:(float)bufferSize withAudioData:(float*)data {

    // For an FFT, numSamples must be a power of 2, i.e. is always even
    int nOver2 = bufferSize/2;
    
    // Pack samples:
    // C(re) -> A[n], C(im) -> A[n+1]
    vDSP_ctoz((COMPLEX*)data, 2, &_A, 1, nOver2);
    
    // Perform a forward FFT using fftSetup and A
    // Results are returned in A
    vDSP_fft_zrip(_FFTSetup, &_A, 1, _log2n, FFT_FORWARD);
    
    // print bins (real, imaginary) spectrum data
        //    printf("\nSpectrum:\n");
        //    for (int k = 0; k < nOver2; k++)
        //    {
        //        printf("%3d\t%6.2f\t%6.2f\n", k, _A.realp[k], _A.imagp[k]);
        //    }
    
    // Convert COMPLEX_SPLIT A result to magnitudes
    float amp[nOver2];
    float maxMag = 0;
    
    // initialize storage array
    NSMutableArray *frequencyBins = [[NSMutableArray alloc]init];
    // initialize array for storing index and mag pairs
    
    //index for magnitude data
    //printf("\nBin / Mag:\n");
    
    for(int i=0; i<nOver2; i++) {
        // Calculate the magnitude
        float mag = _A.realp[i]*_A.realp[i]+_A.imagp[i]*_A.imagp[i];
        maxMag = mag > maxMag ? mag : maxMag;
        
        // Bind the value to be less than 1.0 to fit in the graph
        amp[i] = [EZAudio MAP:mag leftMin:0.0 leftMax:maxMag rightMin:0.0 rightMax:1.0];
        
        NSArray *freqMagPair = [[NSArray alloc]init];
        
        freqMagPair = filterOutToothPassingFrequencyHarmonics(i, mag, 200, nOver2); // mag switched from amp[i]
        
        // print bins (bin, normalize magnitude) spectrum bin data
        
        // for (int j = 1; j < nOver2; j++) //already nested in a loop no need to call another one
        //        {
        //    printf("%3d\t%6.2f\n", i, amp[i]); // normalized magnatudes
        //        }
        
    // if sampeling at 1023 Hz each bin holds a span of 44hz
        //int freqBin = i * 22000/nOver2;
        
        //NSNumber *freq = [NSNumber numberWithInt:freqBin];
        
        //NSNumber *magnatude = [NSNumber numberWithFloat:amp[i]];
        
        //NSArray *freqMagPair = [NSArray arrayWithObjects:freq, magnatude, nil];
        
        [frequencyBins addObject:freqMagPair];
        
        
        
        // NSLog(@"%i",i);
    }
    
    
    
    
    // function to do data analysis getSpindleSpeed (note frequency bins array is now sorted)
    [frequencyBins sortUsingComparator:^(id a, id b){
        return[b[0] compare:a[0]];
    }];
    
    
    
    // Update the frequency domain plot
    [self.audioPlotFrequency updateBuffer:amp withBufferSize:nOver2];
    
}


#pragma mark - Actions
- (IBAction)changePlotType:(id)sender {
    NSInteger selectedSegment = [sender selectedSegmentIndex];
    switch(selectedSegment){
        case 0:
            [self drawBufferPlot];
            break;
        case 1:
            [self drawRollingPlot];
            break;
        default:
            break;
    }
}
- (IBAction)play:(id)sender {
    if( ![[EZOutput sharedOutput] isPlaying] ){
        if( self.eof ){
            [self.audioFile seekToFrame:0];
        }
        [EZOutput sharedOutput].outputDataSource = self;
        [[EZOutput sharedOutput] startPlayback];
    }
    else {
        [EZOutput sharedOutput].outputDataSource = nil;
        [[EZOutput sharedOutput] stopPlayback];
    }
}
- (IBAction)seekToFrame:(id)sender {
   [self.audioFile seekToFrame:(SInt64)[(UISlider*)sender value]];
}

#pragma mark- Action Extensions
/*
 Give the visualization of the current buffer (this is almost exactly the openFrameworks audio input example)
 */
-(void)drawBufferPlot {
    // Change the plot type to the buffer plot
    self.audioPlot.plotType = EZPlotTypeBuffer;
    // Don't fill
    self.audioPlot.shouldFill = NO;
    // Don't mirror over the x-axis
    self.audioPlot.shouldMirror = NO;
}

/*
 Give the classic mirrored, rolling waveform look
 */
-(void)drawRollingPlot {
    // Change the plot type to the rolling plot
    self.audioPlot.plotType = EZPlotTypeRolling;
    // Fill the waveform
    self.audioPlot.shouldFill = YES;
    // Mirror over the x-axis
    self.audioPlot.shouldMirror = YES;
}

-(void)openFileWithFilePathURL:(NSURL*)filePathURL {
    
    // Stop playback
    [[EZOutput sharedOutput] stopPlayback];
    
    self.audioFile                        = [EZAudioFile audioFileWithURL:filePathURL];
    self.audioFile.audioFileDelegate      = self;
    self.eof                              = NO;
    self.filePathLabel.text               = filePathURL.lastPathComponent;
    self.framePositionSlider.maximumValue = (float)self.audioFile.totalFrames;
    
    // Set the client format from the EZAudioFile on the output
    [[EZOutput sharedOutput] setAudioStreamBasicDescription:self.audioFile.clientFormat];
    
    // Plot the whole waveform
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    self.audioPlot.shouldFill      = YES;
    self.audioPlot.shouldMirror    = YES;
    [self.audioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
        [self.audioPlot updateBuffer:waveformData withBufferSize:length];
    }];
    
}



#pragma mark - EZAudioFileDelegate
-(void)audioFile:(EZAudioFile *)audioFile
       readAudio:(float **)buffer
  withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [EZOutput sharedOutput].isPlaying ){
            if( self.audioPlot.plotType     == EZPlotTypeBuffer &&
               self.audioPlot.shouldFill    == YES              &&
               self.audioPlot.shouldMirror  == YES ){
                self.audioPlot.shouldFill   = NO;
                self.audioPlot.shouldMirror = NO;
            }
            [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
            
            // Setup the FFT if it's not already setup
            
            // change buffer size
            int samplesToCopy = fmin(bufferSize, FFTLEN - fftBuffIndex);
            for (size_t i = 0; i < samplesToCopy; i++){
                fftBuff[fftBuffIndex+i] = buffer[0][i];
            }
            fftBuffIndex           += samplesToCopy;
            samplesRemaining       -= samplesToCopy;
            //
            if( !_isFFTSetup ){
                [self createFFTWithBufferSize:FFTLEN withAudioData:buffer[0]];  // FFTLEN substuted for buffer size
                _isFFTSetup = YES;
            }
            
            // Get the FFT data
            [self updateFFTWithBufferSize:FFTLEN withAudioData:fftBuff];
            fftBuffIndex            = 0;
            samplesRemaining       = FFTLEN;
        }
    });
}

-(void)audioFile:(EZAudioFile *)audioFile
 updatedPosition:(SInt64)framePosition {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( !self.framePositionSlider.touchInside ){
            self.framePositionSlider.value = (float)framePosition;
        }
    });
}

#pragma mark - EZOutputDataSource
-(void)output:(EZOutput *)output shouldFillAudioBufferList:(AudioBufferList *)audioBufferList withNumberOfFrames:(UInt32)frames{
    if( self.audioFile )
    {
        UInt32 bufferSize;
        [self.audioFile readFrames:frames
                   audioBufferList:audioBufferList
                        bufferSize:&bufferSize
                               eof:&_eof];
        if( _eof )
        {
            [self seekToFrame:0];
        }
    }
}

-(AudioStreamBasicDescription)outputHasAudioStreamBasicDescription:(EZOutput *)output {
    return self.audioFile.clientFormat;
}


@end
