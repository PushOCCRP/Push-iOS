//
//  ArticleViewController.m
//  Push
//
//  Created by Christopher Guess on 11/11/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import "AnalyticsManager.h"

#import "ArticleViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <Masonry/Masonry.h>
#import "LanguageManager.h"
#import "YouTubePlayerViewController.h"
#import "SettingsManager.h"

#import "NSMutableAttributedString+HTML.h"
#import "NSString+ReverseString.h"

@interface ArticleViewController ()

@property (nonatomic, retain) UIImageView * image;
@property (nonatomic, retain) UIButton * videoPlayerButton;
@property (nonatomic, retain) UILabel * caption;
@property (nonatomic, retain) UILabel * date;
@property (nonatomic, retain) UILabel * headline;
@property (nonatomic, retain) UITextView * body;

@property (nonatomic, retain) UIScrollView * scrollView;
@property (nonatomic, retain) UIView * contentView;

@end

@implementation ArticleViewController

- (instancetype)initWithArticle:(Article*)article
{
    self = [super init];
    if(self){
        self.article = article;
    }
    
    return self;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setShareButton];
    [self setupScrollView];
    [self setupContentView];
    [self setContraints];
}

- (void)viewDidAppear:(BOOL)animated
{
    [AnalyticsManager startTimerForContentViewWithObject:self name:@"Article Viewed Time" contentType:@"Article View Time"
                                               contentId:self.article.description customAttributes:self.article.trackingProperties];
    [AnalyticsManager startTimerForContentViewWithObject:self name:self.article.headline contentType:@"Article Timer" contentId:nil customAttributes:nil];
    
    [AnalyticsManager logContentViewWithName:@"Article List Appeared" contentType:@"Navigation"
                          contentId:self.article.description customAttributes:self.article.trackingProperties];
    [AnalyticsManager logContentViewWithName:self.article.headline contentType:@"Article View" contentId:nil customAttributes:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [AnalyticsManager endTimerForContentViewWithObject:self andName:@"Article Viewed Time"];
    [AnalyticsManager endTimerForContentViewWithObject:self andName:self.article.headline];
}

- (void)setShareButton {
    UIBarButtonItem * shareBarButtonItem = [[UIBarButtonItem alloc]
                                            initWithTitle:@"Share"
                                            style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(shareButtonTapped)];
    
    self.navigationItem.rightBarButtonItem = shareBarButtonItem;
}

- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] init];
    
    [self.view addSubview:self.scrollView];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker * make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupContentView {
    
    //Create the content views
    self.contentView = [[UIView alloc] init];
    
    self.image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, self.contentView.frame.size.height)];
    self.image.clipsToBounds = YES;
    self.image.contentMode = UIViewContentModeScaleAspectFill;
    self.image.userInteractionEnabled = YES;
    
    self.videoPlayerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.videoPlayerButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.videoPlayerButton addTarget:self action:@selector(videoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
    self.caption = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    self.caption.numberOfLines = 3;
    self.caption.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.date = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    
    self.headline = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    self.headline.numberOfLines = 3;
    self.headline.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.body = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    self.body.delegate = self;
    self.body.editable = NO;
    self.body.scrollEnabled = NO;
    self.body.dataDetectorTypes = UIDataDetectorTypeLink;
    
    // Add the content views to the main view
    [self.contentView addSubview:self.image];
    [self.contentView addSubview:self.videoPlayerButton];
    [self.contentView addSubview:self.caption];
    [self.contentView addSubview:self.date];
    [self.contentView addSubview:self.headline];
    [self.contentView addSubview:self.body];
    
    // Set all the data to views for the article
    [self setViewsForArticle];
    
    // Make it scroll
    [self.scrollView addSubview:self.contentView];
}

- (void)setContraints {
    
    // Set the stack up. This is pretty basic stuff
    UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);

    [self.contentView mas_makeConstraints:^(MASConstraintMaker * make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
        make.bottom.equalTo(self.body.mas_bottom).with.offset(80.0f);
    }];
    
    [self.image mas_makeConstraints:^(MASConstraintMaker * make) {
        make.top.equalTo(self.contentView.mas_top);
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        //make.height.equalTo(@400);
        make.height.lessThanOrEqualTo(self.scrollView).multipliedBy(0.5f);
    }];
    
    [self.videoPlayerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.image.mas_centerX);
        make.centerY.equalTo(self.image.mas_centerY);
    }];
    
    [self.caption mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.image.mas_bottom).with.offset(padding.top);
        make.left.equalTo(self.caption.superview.mas_left).with.offset(padding.left);
        make.right.equalTo(self.caption.superview.mas_right).with.offset(-padding.right);
    }];
    
    [self.date mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.caption.mas_bottom).with.offset(padding.top);
        make.left.equalTo(self.date.superview.mas_left).with.offset(padding.left);
        make.right.equalTo(self.date.superview.mas_right).with.offset(padding.right);
    }];
    
    [self.headline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.date.mas_bottom).with.offset(padding.top);
        make.left.equalTo(self.headline.superview.mas_left).with.offset(padding.left);
        make.right.equalTo(self.headline.superview.mas_right).with.offset(-padding.right);
    }];
    
    [self.body mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headline.mas_bottom).with.offset(padding.top);
        make.left.equalTo(self.body.superview.mas_left).with.offset(padding.left);
        make.right.equalTo(self.body.superview.mas_right).with.offset(-padding.right);
        make.bottom.equalTo(self.body.superview.mas_bottom);
        make.width.equalTo(self.scrollView).with.sizeOffset(CGSizeMake(-20.0f, 0.0f));
    }];
}

- (void)setViewsForArticle {
    
    //Load image from web if the cache doesn't exist (this is handled in UIImageView+AFNetworking
    NSURL * imageURL = [NSURL URLWithString:self.article.images.firstObject[@"url"]];
    [self.image setImageWithURL:imageURL];
    
    __weak typeof(self) weakSelf = self;
    [self.image setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        weakSelf.image.image = image;
        
        //Resize the image view's height to make it proportional
        float viewWidth = weakSelf.view.frame.size.width;
        float proportion = viewWidth / image.size.width;
        float height = image.size.height * proportion;
        
        [weakSelf.image mas_remakeConstraints:^(MASConstraintMaker * make) {
            make.top.equalTo(weakSelf.contentView.mas_top);
            make.left.equalTo(weakSelf.contentView.mas_left);
            make.right.equalTo(weakSelf.contentView.mas_right);
            make.height.equalTo([NSNumber numberWithFloat:height]);
        }];
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        NSLog(@"Error loading image: %@", error.localizedDescription);
    }];
    
    //Hide the video button if there is no video
    if(self.article.videos.count < 1){
        self.videoPlayerButton.hidden = YES;
    } else {
        self.videoPlayerButton.hidden = NO;
        
        // This sets some filler space while an image loads so the play button doesn't go off the top of the screen
        // When the image loads everything resizes correctly
        if(self.image.frame.size.height == 0){
            [self.image mas_remakeConstraints:^(MASConstraintMaker * make) {
                make.top.equalTo(self.contentView.mas_top);
                make.left.equalTo(self.contentView.mas_left);
                make.right.equalTo(self.contentView.mas_right);
                make.height.equalTo(self.videoPlayerButton.mas_height).valueOffset(@50);
            }];
        }
    }
    
    //Set image caption, hide if there is none.
    if(self.article.images.count > 0 && [[self.article.images[0] allKeys] containsObject:@"caption"]){
        self.caption.text = [self.article.images[0] valueForKey:@"caption"];
        self.caption.font = [UIFont fontWithName:@"Palatino-Roman" size:15.0f];
    } else {
        self.caption.hidden = YES;
    }
    
    //Set date
    self.date.text = self.article.dateByline;
    self.date.font = [UIFont fontWithName:@"TrebuchetMS" size:13.0f];
    
    //Set the headline
    self.headline.text = self.article.headline;
    self.headline.font = [UIFont fontWithName:@"TrebuchetMS" size:25.0f];
    
    //Set the body using html for the formatting
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 7.0f;
    
    NSString * html = [self.article.body stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>", @"Palatino-Roman", 17.0f]];
    
    NSMutableAttributedString * bodyAttributedText = [[NSMutableAttributedString alloc]
                                                      initWithHTML:[html dataUsingEncoding:NSUTF8StringEncoding]
                                                      baseURL:[SettingsManager sharedManager].cmsBaseUrl
                                                       documentAttributes:nil];
    
    self.body.attributedText = bodyAttributedText;

    [bodyAttributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, bodyAttributedText.string.length)];

    self.body.attributedText = bodyAttributedText;    
}

// Wrote this without test from memory. There's a 10% chance it works
- (NSArray*)imageLocationsInText:(NSString*)text
{
    // Find all strings ^&^&
    // Find the nearest new line before the location
    // Unless it's at the start of the string, in which case do the one afterwards
    // return an array of the new line location
    
    NSMutableArray * ranges = [NSMutableArray array];
    
    NSString * compareRange = @"^&^&";
    NSRange range = [text rangeOfString:compareRange];
    NSUInteger indexOfLastImageString = 0;
    
    while (range.length != 0){
        
        // Before we add the range we actually want to find the blank space before it
        // I'm not sure, so this assumes that all distances and locations are relative to the substrings
        if(ranges.count > 1){
            // Get a reversed string so we can use some helpers
            // We want it to be from the previous range
            NSRange previousRange = [[ranges lastObject] rangeValue];
            NSString * reversedString = [[text substringWithRange:NSMakeRange(previousRange.location + previousRange.length, range.location - previousRange.length)] reverse];
        
            // This might work... depends on how line breaks are handled
            // Here we get the range of the previous newlines
            // It's reversed, so the string we're checking for is too
            NSRange reversedRangeOfNewLine = [reversedString rangeOfString:@"n\\"];
        
            // Subtract it here
            range.location -= reversedRangeOfNewLine.location;
        } else {
            range.location += [[text substringWithRange:NSMakeRange(range.location, text.length - range.location)] rangeOfString:@"\n"].location;
        }
        
        [ranges addObject:[NSValue valueWithRange:range]];
        
        NSUInteger newStart = range.location + range.length;
        range = [text rangeOfString:compareRange options:0 range:NSMakeRange(newStart, text.length - newStart)];
        indexOfLastImageString = newStart;
    }
    
    return [NSArray arrayWithArray:ranges];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shareButtonTapped
{
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.article.headline, self.article.linkURL] applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)videoButtonTapped
{
    [AnalyticsManager logContentViewWithName:@"Video Button Tapped" contentType:@"Navigation"
                                   contentId:self.article.description customAttributes:self.article.trackingProperties];

    YouTubePlayerViewController * youTubePlayerViewController = [[YouTubePlayerViewController alloc] initWithVideoId:self.article.videos.firstObject[@"youtube_id"]];
    youTubePlayerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    youTubePlayerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:youTubePlayerViewController animated:YES completion:^{
        [youTubePlayerViewController setupPlayer];
    }];
}




#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
