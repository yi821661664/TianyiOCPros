#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "TYAudioPlayer.h"
#import "TYAudioQueuePlayer.h"
#import "TYAudioSystemPlayer.h"
#import "TYAudioUnitPlayer.h"
#import "TYAudioUnitReader.h"
#import "TYAudioQueueRecorder.h"
#import "TYAudioRecorder.h"
#import "TYAudioSession.h"
#import "TYAudioUnitRecorder.h"
#import "AudioDecodeOperation.h"
#import "CADebugMacros.h"
#import "CAMath.h"
#import "CAStreamBasicDescription.h"
#import "CAXException.h"
#import "AudioSoundTouchOperation.h"
#import "WaveHeader.h"
#import "EZAudio.h"
#import "EZAudioDevice.h"
#import "EZAudioDisplayLink.h"
#import "EZAudioFFT.h"
#import "EZAudioFile.h"
#import "EZAudioFloatConverter.h"
#import "EZAudioFloatData.h"
#import "EZAudioiOS.h"
#import "EZAudioOSX.h"
#import "EZAudioPlayer.h"
#import "EZAudioPlot.h"
#import "EZAudioPlotGL.h"
#import "EZAudioUtilities.h"
#import "EZMicrophone.h"
#import "EZOutput.h"
#import "EZPlot.h"
#import "EZRecorder.h"
#import "TPCircularBuffer.h"
#import "AAFilter.h"
#import "BPMDetect.h"
#import "cpu_detect.h"
#import "FIFOSampleBuffer.h"
#import "FIFOSamplePipe.h"
#import "FIRFilter.h"
#import "PeakFinder.h"
#import "RateTransposer.h"
#import "SoundTouch.h"
#import "soundtouch_config.h"
#import "STTypes.h"
#import "TDStretch.h"
#import "TYAudioPageViewController.h"
#import "TYMediaHomePageViewController.h"
#import "TYVideoPageViewController.h"
#import "TYAudioBaseView.h"
#import "TYEncordView.h"
#import "TYEZAudioView.h"
#import "TYRecordView.h"
#import "TYSoundTouchView.h"

FOUNDATION_EXPORT double TianyiAVManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char TianyiAVManagerVersionString[];

