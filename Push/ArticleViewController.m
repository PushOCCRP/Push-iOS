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
#import <AFNetworking/AFImageDownloader.h>

#import <Masonry/Masonry.h>
#import "LanguageManager.h"
#import "YouTubePlayerViewController.h"
#import "SettingsManager.h"

#import "NSMutableAttributedString+HTML.h"
#import "NSString+ReverseString.h"
#import "NSURL+URLWithNonLatinString.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import "ArticleTableViewHeader.h"

#import "Constants.h"

@interface ArticleViewController ()

@property (nonatomic, retain) UIImageView * image;
@property (nonatomic, retain) UIButton * videoPlayerButton;
@property (nonatomic, retain) UILabel * caption;
@property (nonatomic, retain) UILabel * photoByline;
@property (nonatomic, retain) UILabel * date;
@property (nonatomic, retain) UILabel * headline;
@property (nonatomic, retain) UITextView * body;
@property (nonatomic, retain) ArticleTableViewHeader * category;

@property (nonatomic, retain) UIScrollView * scrollView;
@property (nonatomic, retain) UIView * contentView;
@property (nonatomic, retain) UIBarButtonItem * shareBarButtonItem;

@property (nonatomic, retain) NSMutableDictionary * imageLocations;

@end

@implementation ArticleViewController

static NSString * imageGravestoneMarker = @"&&&&";
static int contentWidth = 700;



- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (instancetype)initWithArticle:(Article*)article
{
    self = [super init];
    if(self){
        self.article = article;
        
        NSLog(@"This should hapen once in never");
        
    }
    
    return self;
}

- (void) doEverything {
    self.view.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    
    self.imageLocations = [NSMutableDictionary dictionary];
    
    [self setShareButton];
    [self setupScrollView];
    [self setupContentView];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self doEverything];
    NSLog(@"ArticleViewController viewDidLoad");
    [self.view layoutIfNeeded];
}

- (void) dealloc{
    NSLog(@"ArticleViewController deallocation");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    //Resize the image view's height to make it proportional
//    float viewWidth = self.navigationController.view.window.frame.size.width;
//    float proportion = viewWidth / self.image.image.size.width;
//
//    if(self.image.image){
//        float height = self.image.image.size.height * proportion;
//
//        [self.image mas_updateConstraints:^(MASConstraintMaker * make) {
//            make.height.equalTo([NSNumber numberWithFloat:height]);
//        }];
//    }
    // Set all the data to views for the article
    [self setViewsForArticle];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setContraints];
    
     __weak typeof(self) weakSelf = self;
    
    
    [[AnalyticsManager sharedManager] startTimerForContentViewWithObject:weakSelf name:@"Article Viewed Time" contentType:@"Article View Time"
                                               contentId:weakSelf.article.description customAttributes:weakSelf.article.trackingProperties];
    [[AnalyticsManager sharedManager] startTimerForContentViewWithObject:weakSelf name:weakSelf.article.headline contentType:@"Article Timer" contentId:nil customAttributes:nil];
    
    [[AnalyticsManager sharedManager] logContentViewWithName:@"Article List Appeared" contentType:@"Navigation"
                          contentId:weakSelf.article.description customAttributes:weakSelf.article.trackingProperties];
    [[AnalyticsManager sharedManager] logContentViewWithName:weakSelf.article.headline contentType:@"Article View" contentId:nil customAttributes:nil];
   
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    __weak typeof(self) weakSelf = self;
    
    [[AnalyticsManager sharedManager] endTimerForContentViewWithObject:weakSelf andName:@"Article Viewed Time"];
    [[AnalyticsManager sharedManager] endTimerForContentViewWithObject:weakSelf andName:self.article.headline];
    
    @try {
        [self.article removeObserver:self forKeyPath:NSStringFromSelector(@selector(bodyHTML))];
    }
    @catch (NSException * __unused exception) {}
    
   
}

- (void)setShareButton {
    self.shareBarButtonItem = [[UIBarButtonItem alloc]
                                            initWithTitle:@"Share"
                                            style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(shareButtonTapped)];
    
    self.navigationItem.rightBarButtonItem = self.shareBarButtonItem;
}

- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker * make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupContentView {
    
    if(self.contentView){
        return;
    }
    
    //Create the content views
    self.contentView = [[UIView alloc] init];
    
    if (self.article.category){
        self.category = [[ArticleTableViewHeader alloc] initWithTop:YES];
        self.category.categoryName = self.article.category;
    }
    
    self.image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, self.contentView.frame.size.height)];
    self.image.clipsToBounds = YES;
    self.image.contentMode = UIViewContentModeScaleAspectFill;
    self.image.userInteractionEnabled = YES;
    
    self.videoPlayerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.videoPlayerButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.videoPlayerButton addTarget:self action:@selector(videoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.photoByline = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    self.photoByline.numberOfLines = 1;
    self.caption.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.caption = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    self.caption.numberOfLines = 0;
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
    if(self.category){
        [self.contentView addSubview:self.category];
    }
    [self.contentView addSubview:self.image];
    [self.contentView addSubview:self.videoPlayerButton];
    [self.contentView addSubview:self.photoByline];
    [self.contentView addSubview:self.caption];
    [self.contentView addSubview:self.date];
    [self.contentView addSubview:self.headline];
    [self.contentView addSubview:self.body];
    
    // Make it scroll
    [self.scrollView addSubview:self.contentView];
}

- (void)setContraints {
    
    // Set the stack up. This is pretty basic stuff
    UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
    
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker * make) {
        float topOffset = 0.0;
        if(self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular){
            make.width.equalTo([NSNumber numberWithInteger:contentWidth]);
            topOffset = 20.0f;
        } else {
            make.width.equalTo(self.scrollView);
        }

        make.top.equalTo(self.scrollView).offset(topOffset);
        make.left.equalTo(self.scrollView);
        make.right.equalTo(self.scrollView);
        
        make.bottom.equalTo(self.scrollView);
    }];
    
    if(self.category){
        [self.category mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top);
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.height.equalTo(@42);
        }];
    }
    [self.image mas_makeConstraints:^(MASConstraintMaker * make) {
        if(self.category){
            make.top.equalTo(self.category.mas_bottom);
        } else {
            make.top.equalTo(self.contentView.mas_top);
        }
        
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        //make.height.equalTo(@400);
        make.height.lessThanOrEqualTo(self.scrollView).multipliedBy(0.5f);
    }];
    
    [self.videoPlayerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.image.mas_centerX);
        make.centerY.equalTo(self.image.mas_centerY);
    }];

    [self.photoByline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.image.mas_bottom).with.offset(padding.top);
        make.left.equalTo(self.photoByline.superview.mas_left).with.offset(padding.left);
        make.right.equalTo(self.photoByline.superview.mas_right).with.offset(-padding.right);
    }];
    
    [self.caption mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.photoByline.mas_bottom).with.offset(padding.top);
        make.left.equalTo(self.caption.superview.mas_left).with.offset(padding.left);
        make.right.equalTo(self.caption.superview.mas_right).with.offset(-padding.right);
    }];
    
    [self.date mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.caption.mas_bottom).with.offset(padding.top);
        make.left.equalTo(self.date.superview.mas_left).with.offset(padding.left);
        make.right.equalTo(self.date.superview.mas_right).with.offset(padding.right);
        //TODO: Should set height here base on the length of the byline and the width of the screen
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
        make.width.equalTo(self.contentView).with.sizeOffset(CGSizeMake(-20.0f, 0.0f));
    }];
}

- (void)viewDidLayoutSubviews {
    if(self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular){
        int margin = (self.scrollView.frame.size.width - contentWidth) / 2;
        UIEdgeInsets scrollViewInsets = self.scrollView.contentInset;
        scrollViewInsets.left = margin;
        scrollViewInsets.right = margin;

        [self.scrollView setContentInset:scrollViewInsets];
    }
    
    //Resize the image view's height to make it proportional
    float viewWidth = self.navigationController.view.window.frame.size.width;
    float proportion = viewWidth / self.image.image.size.width;
    
    if(self.image.image){
        float height = self.image.image.size.height * proportion;
        
        [self.image mas_updateConstraints:^(MASConstraintMaker * make) {
            make.height.equalTo([NSNumber numberWithFloat:height]);
        }];
    }

}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [self setContraints];
}

- (void)setViewsForArticle {
    
    if(self.category){
        self.category.categoryName = self.article.category;
    }
    
    //Load image from web if the cache doesn't exist (this is handled in UIImageView+AFNetworking
    
    if(self.article.headerImage || self.article.images.count > 0){
        NSString * headerImageURL;
        if(self.article.headerImage){
            headerImageURL = self.article.headerImage[@"url"];
        } else {
            headerImageURL = self.article.images.firstObject[@"url"];
        }

        NSURL * imageURL = [NSURL URLWithNonLatinString:headerImageURL];
        [self.image setImageWithURL:imageURL];
        
        __weak typeof(self) weakSelf = self;
        [self.image setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
            weakSelf.image.image = image;
        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            NSLog(@"Error loading image: %@", error.localizedDescription);
        }];
        
        //Set image caption, hide if there is none.
        NSString * headerImageCaption;
        NSString * headerImageByline;
        if(self.article.headerImage && self.article.headerImage.caption){
            headerImageCaption = self.article.headerImage.caption;
            if(self.article.images.firstObject.caption){
                headerImageByline = self.article.images.firstObject[@"byline"];
            }
        } else if(self.article.images.count > 0 && self.article.images[0].caption){
            headerImageCaption = self.article.images.firstObject.caption;
            if(self.article.images.firstObject.caption){
                headerImageByline = self.article.images.firstObject.byline;
            }
        }
        
        if(headerImageCaption){
            self.caption.text = headerImageCaption;
            self.caption.font = [UIFont fontWithName:@"Palatino-Roman" size:15.0f];
        } else {
            self.caption.hidden = YES;
        }
        
        if(headerImageByline){
            self.photoByline.text = headerImageByline;
            self.photoByline.font = [UIFont fontWithName:@"Palatino-Roman" size:15.0f];
            self.photoByline.textAlignment = NSTextAlignmentRight;
        } else {
            self.photoByline.hidden = YES;
        }

    }
    
    //Hide the video button if there is no video
    if(self.article.videos.count < 1){
        self.videoPlayerButton.hidden = YES;
    } else {
        self.videoPlayerButton.hidden = NO;
        
        // This sets some filler space while an image loads so the play button doesn't go off the top of the screen
        // When the image loads everything resizes correctly
        if(self.image.frame.size.height == 0){
            [self.image mas_remakeConstraints:^(MASConstraintMaker * make) {
                if(self.category){
                    make.top.equalTo(self.category.mas_bottom);
                } else {
                    make.top.equalTo(self.contentView.mas_top);
                }

                make.left.equalTo(self.contentView.mas_left);
                make.right.equalTo(self.contentView.mas_right);
                make.height.equalTo(self.videoPlayerButton.mas_height).valueOffset(@50);
            }];
        }
    }
    
    //Set date
    self.date.text = self.article.dateByline;
    self.date.font = [UIFont fontWithName:@"TrebuchetMS" size:13.0f];
    self.date.numberOfLines = 0;
    
    //Set the headline
    self.headline.text = self.article.headline;
    self.headline.font = [UIFont fontWithName:@"TrebuchetMS" size:25.0f];
    
    // This is a fun little trick.
    // In case the article text isn't fully parsed, we add this class as an observer on the article
    // The article's bodyHTML isn't set until it's finished parsing, when it is, we keep going.
    if(self.article.bodyHTML == nil){
        [self.article addObserver:self forKeyPath:NSStringFromSelector(@selector(bodyHTML)) options:0 context:nil];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.tag = 1000;
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"Loading";
    } else {
        [self processBodyText];
    }
    //self.body.textColor = [UIColor blackColor];
}

- (void)processBodyText
{
    //Set the body using html for the formatting
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 7.0f;
    
    NSMutableAttributedString * bodyAttributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.article.bodyHTML];
    
    [bodyAttributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, bodyAttributedText.string.length)];
    
    //bodyAttributedText = [[NSMutableAttributedString alloc] initWithAttributedString:[self addImagePlaceholderToAttributedString:bodyAttributedText]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.body.attributedText = bodyAttributedText;
    });
}

- (void)reloadImagesInBody:(NSString*)imageURL
{
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shareButtonTapped
{
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.article.headline, self.article.linkURL] applicationActivities:nil];
    activityVC.title = @"Share";
    // For some reason the barbuttonitem will not work, instead it crashes.
    // So let's fake it for iPads.
    activityVC.popoverPresentationController.sourceView = self.view;
    activityVC.popoverPresentationController.sourceRect = CGRectMake(self.view.frame.size.width, 0, self.navigationController.navigationBar.frame.size.height+10, 20);
    [activityVC.popoverPresentationController setPermittedArrowDirections:UIPopoverArrowDirectionUp];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)videoButtonTapped
{
    [[AnalyticsManager sharedManager] logContentViewWithName:@"Video Button Tapped" contentType:@"Navigation"
                                   contentId:self.article.description customAttributes:self.article.trackingProperties];

    YouTubePlayerViewController * youTubePlayerViewController = [[YouTubePlayerViewController alloc] initWithVideoId:self.article.videos.firstObject.youtubeId];
    youTubePlayerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    youTubePlayerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:youTubePlayerViewController animated:YES completion:^{
        [youTubePlayerViewController setupPlayer];
    }];
}



// Observer to watch until the body text is fully formatted into HTML
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if(object == self.article && [keyPath isEqualToString:NSStringFromSelector(@selector(bodyHTML))]){
        [self processBodyText];
        dispatch_async(dispatch_get_main_queue(), ^{
            [(MBProgressHUD*)[self.view viewWithTag:1000] hideAnimated:YES];
        });
    }
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
