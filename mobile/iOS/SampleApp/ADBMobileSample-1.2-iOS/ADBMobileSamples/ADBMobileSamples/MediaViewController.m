/*************************************************************************
 *
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 *  Copyright 2013 Adobe Systems Incorporated
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 *
 **************************************************************************/

#import "MediaViewController.h"
#import "ADBMobile.h"
#import "TMMobile.h"

#import <BrightcovePlayerSDK/BrightcovePlayerSDK.h>
#import <BrightcoveAMC/BrightcoveAMC.h>

#pragma mark - class constants



// ** Customize these values with your own account information **
static NSString * const kViewControllerPlaybackServicePolicyKey = @"BCpkADawqM2oRT4bpKZLwbcYPruSIUwl1sK8tn2gkKWGzNhootPqAk69qrwOT6eP9-yO50sPCQQpPpHWrGd5pLn0sNFkhTPqJ5JeVCMnpyAzvitvdtq0k6ddZFFFJssi4KZDn_Ty2zbZQneI";
static NSString * const kViewControllerAccountID = @"6076300361001";
static NSString * const kViewControllerVideoID = @"6088900645001";

@interface MediaViewController () <BCOVPlaybackControllerDelegate, BCOVAMCSessionConsumerHeartbeatDelegate, BCOVAMCSessionConsumerMeidaDelegate>
    
    @property (nonatomic, strong) BCOVPlaybackService *playbackService;
    @property (nonatomic, strong) id<BCOVPlaybackController> playbackController;
    @property (nonatomic, weak) IBOutlet UIView *videoContainerView;
    @property (nonatomic) BCOVPUIPlayerView *playerView;
    
    @property(nonatomic, strong) IBOutlet UIView* containerView;
    @property(nonatomic, strong) id<BCOVPlaybackController> controller;

    @end

@implementation MediaViewController
    
- (instancetype)initWithCoder:(NSCoder *)coder
    {
        self = [super initWithCoder:coder];
        if (self)
        {
            [self setup];
        }
        return self;
    }
    
- (void)setup
    {
        BCOVPlayerSDKManager *manager = [BCOVPlayerSDKManager sharedManager];
        
        _playbackController = [manager createPlaybackControllerWithViewStrategy:nil];
        _playbackController.delegate = self;
        _playbackController.autoAdvance = YES;
        _playbackController.autoPlay = NO;
        
        //[_playbackController addSessionConsumer: [self mediaAnalyticsSessionConsumer :@"Name" duration:0]];

        
        _playbackService = [[BCOVPlaybackService alloc] initWithAccountId:kViewControllerAccountID
                                                                policyKey:kViewControllerPlaybackServicePolicyKey];
        
    }
    
- (BCOVAMCSessionConsumer *)mediaAnalyticsSessionConsumer:(NSString *)videoName duration:(double)duration playerName:(NSString *)playerName  playerID:(NSString *)playerID
    {
        BCOVAMCMediaSettingPolicy mediaSettingPolicy = ^ADBMediaSettings *(id<BCOVPlaybackSession> session) {
            ADBMediaSettings *settings = [TMMobile tmConfigureVODTracking:videoName mediaLength:duration playerName:playerName playerID:playerID];
            
            return settings;
        };
        
        BCOVAMCAnalyticsPolicy *mediaPolicy = [[BCOVAMCAnalyticsPolicy alloc] initWithMediaSettingsPolicy:mediaSettingPolicy];
        
        return [BCOVAMCSessionConsumer mediaAnalyticsConsumerWithPolicy:mediaPolicy delegate:self];
    }
    
    
#pragma mark view lifecycle
    
- (void)viewDidLoad
    {
        [super viewDidLoad];
        
        [TMMobile tmTrackState:@"media example" subscriptionStatus:true data:nil];
        [TMMobile tmTrackState:@"media example1" subscriptionStatus:true data:nil];
        [TMMobile tmTrackState:@"media example2" subscriptionStatus:true data:nil];
        [TMMobile tmTrackState:@"media example3" subscriptionStatus:true data:nil];
        [TMMobile tmTrackState:@"media example4" subscriptionStatus:true data:nil];

        // Do any additional setup after loading the view, typically from a nib.
        
        [self UISetup];
        
    }
    
- (void)UISetup
    {
        // Create and configure Control View.
        BCOVPUIBasicControlView *controlView = [BCOVPUIBasicControlView basicControlViewWithVODLayout];
        self.playerView = [[BCOVPUIPlayerView alloc] initWithPlaybackController:self.playbackController options:nil controlsView:controlView];
        self.playerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.videoContainerView addSubview:self.playerView];
        [NSLayoutConstraint activateConstraints:@[
                                                  [self.playerView.topAnchor constraintEqualToAnchor:self.videoContainerView.topAnchor],
                                                  [self.playerView.rightAnchor constraintEqualToAnchor:self.videoContainerView.rightAnchor],
                                                  [self.playerView.leftAnchor constraintEqualToAnchor:self.videoContainerView.leftAnchor],
                                                  [self.playerView.bottomAnchor constraintEqualToAnchor:self.videoContainerView.bottomAnchor],
                                                  ]];
        
        [self requestContentFromPlaybackService];
    }
    
    
- (void)requestContentFromPlaybackService
    {
        [self.playbackService findVideoWithVideoID:kViewControllerVideoID parameters:nil completion:^(BCOVVideo *video, NSDictionary *jsonResponse, NSError *error) {
            
            if (video)
            {
                NSLog(@"+++++++++++++ViewController Debug - Error retrieving video playlist: `%@`", video.properties);

                [_playbackController addSessionConsumer: [self mediaAnalyticsSessionConsumer:video.properties[kBCOVVideoPropertyKeyName] duration:0 playerName:@"playerName" playerID:@"playerID"]];
                                
                [self.playbackController setVideos:@[ video ]];
            }
            else
            {
                NSLog(@"ViewController Debug - Error retrieving video playlist: `%@`", error);
            }
            
        }];
    }
    
- (void)playbackController:(id<BCOVPlaybackController>)controller didAdvanceToPlaybackSession:(id<BCOVPlaybackSession>)session
    {
        NSLog(@"++++++ViewController Debug - Advanced to new session.");
    }
    
    
#pragma mark - @protocol BCOVAMCSessionConsumerMediaDelegate <NSObject>
    
- (void)mediaOnSession:(id<BCOVPlaybackSession>)session mediaState:(ADBMediaState *)mediaState;
    {
        NSLog(@"mediaEvent = %@", mediaState.mediaEvent);
        if([mediaState.mediaEvent isEqualToString:@"MILESTONE"])
        {
            NSLog(@"milestone = %lu", (unsigned long)mediaState.milestone);
        }
    }
    
    
    
#pragma mark - UI action handlers
- (IBAction) btnPlayMedia:(id)sender {
    //[self configureMediaTracking];
    
    // begin playing the media item
    [self UISetup];
}
    
    
@end
