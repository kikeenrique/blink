//
//  MusicManager.m
//  Blink
//
//  Created by Yury Korolev on 1/23/18.
//  Copyright © 2018 Carlos Cabañero Projects SL. All rights reserved.
//

#import "MusicManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "BKUserConfigurationManager.h"

@implementation MusicManager {
  UIToolbar *_toolbar;
  NSArray<UIKeyCommand *> *_keyCommands;
}

+ (MusicManager *)shared {
  static MusicManager *ctrl = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ctrl = [[self alloc] init];
  });
  return ctrl;
}

- (instancetype)init
{
  if (self = [super init]) {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(_playbackStateDidChange)
                   name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
  }
  
  return self;
}

- (void)onShow
{
  [[self _player] beginGeneratingPlaybackNotifications];
}

- (void)onHide
{
  [[self _player] endGeneratingPlaybackNotifications];
}


- (UIView *)hudView
{
  if (!_toolbar) {
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    _toolbar.barStyle = UIBarStyleBlack;
  }
  
  [_toolbar setItems:[self _toolbarItems]];
  
  return _toolbar;
}

- (NSArray<UIBarButtonItem *> *)_toolbarItems
{
  UIBarButtonItem *prev = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(_playPrev)];
  UIBarButtonItem *space1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  space1.width = 24;
  UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  space2.width = 24;
  UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(_play)];
  UIBarButtonItem *pause = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(_pause)];
  
  UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(_playNext)];
  
  BOOL isPlaying = [self _player].playbackState == MPMusicPlaybackStatePlaying;
  
  return @[prev, space1, isPlaying ? pause : play, space2, next];
}

- (void)_playbackStateDidChange
{
  [_toolbar setItems:[self _toolbarItems]];
}

- (NSArray<UIKeyCommand *> *)keyCommands
{
  if (!_keyCommands) {
    UIKeyModifierFlags modifierFlags = [BKUserConfigurationManager shortCutModifierFlags];
    
    _keyCommands =
    @[
      [UIKeyCommand keyCommandWithInput:@"n"
                          modifierFlags:modifierFlags
                                 action:@selector(musicCommand:)
                   discoverabilityTitle:@"Next track"],

      [UIKeyCommand keyCommandWithInput:@"s"
                          modifierFlags:modifierFlags
                                 action:@selector(musicCommand:)
                   discoverabilityTitle:@"Pause"],

      [UIKeyCommand keyCommandWithInput:@"p"
                          modifierFlags:modifierFlags
                                 action:@selector(musicCommand:)
                   discoverabilityTitle:@"Play"],

      [UIKeyCommand keyCommandWithInput:@"r"
                          modifierFlags:modifierFlags
                                 action:@selector(musicCommand:)
                   discoverabilityTitle:@"Previous track"],
      
      [UIKeyCommand keyCommandWithInput:@"b"
                          modifierFlags:modifierFlags
                                 action:@selector(musicCommand:)
                   discoverabilityTitle:@"Play from beggining"],

      [UIKeyCommand keyCommandWithInput:@"m"
                          modifierFlags:modifierFlags
                                 action:@selector(_toggleMusicHUD)],
      ];
  }
  
  return _keyCommands;
}

- (void)_toggleMusicHUD
{
  // See this method in SpaceController
}

- (void)musicCommand:(UIKeyCommand *)cmd
{
}

- (void)handleCommand:(UIKeyCommand *)cmd
{
  [self runWithInput:cmd.input];
}

- (NSArray<NSString *> *)commands
{
  return @[@"info", @"back", @"prev", @"pause", @"play", @"resume", @"next"];
}

-(NSString *)runWithInput:(NSString *)input
{
  if ([input isEqualToString:@""] || [input isEqualToString:@"info"]) {
    NSString *info = [self _trackInfo];
    if (info) {
      return [NSString stringWithFormat:@"Current track: %@", info];
    }
  } else if ([input isEqualToString:@"next"] || [input isEqualToString:@"n"]) {
    [self _playNext];
  } else if ([input isEqualToString:@"prev"] || [input isEqualToString:@"r"]) {
    [self _playPrev];
  } else if ([input isEqualToString:@"pause"] || [input isEqualToString:@"s"]) {
    [self _pause];
  } else if ([input isEqualToString:@"play"] || [input isEqualToString:@"p"] || [input isEqualToString:@"resume"]) {
    [self _play];
  } else if ([input isEqualToString:@"back"] || [input isEqualToString:@"b"]) {
    [self _playBack];
  } else {
    return @"Unknown parameter";
  }
  
  return nil;
}

- (MPMusicPlayerController *)_player
{
  return [MPMusicPlayerController systemMusicPlayer];
}

- (void)_playNext
{
  [[self _player] skipToNextItem];
}

- (void)_playPrev
{
  [[self _player] skipToPreviousItem];
}

- (void)_playBack
{
  [[self _player] skipToBeginning];
}

- (void)_pause
{
  [[self _player] pause];
}

- (void)_play
{
  [[self _player] play];
}

- (NSString *)_trackInfo
{
  MPMediaItem *item = [[self _player] nowPlayingItem];
  if (!item) {
    return @"Unknown";
  }
  NSMutableArray *components = [[NSMutableArray alloc] init];
  if (item.title) {
    [components addObject:item.title];
  }
  if (item.artist) {
    [components addObject:item.artist];
  }
  if (item.albumTitle) {
    [components addObject:item.albumTitle];
  }
  
  return [components componentsJoinedByString:@". "];
}

@end
