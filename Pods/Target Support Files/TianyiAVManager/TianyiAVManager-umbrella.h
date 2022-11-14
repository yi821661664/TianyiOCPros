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
#import "TYAudioQueueRecorder.h"
#import "TYAudioRecorder.h"
#import "TYAudioSystemRecoder.h"
#import "TYAudioUnitRecorder.h"
#import "AudioSoundTouchOperation.h"
#import "WaveHeader.h"
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

FOUNDATION_EXPORT double TianyiAVManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char TianyiAVManagerVersionString[];

