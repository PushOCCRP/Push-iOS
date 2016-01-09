//
//  ArticleViewController.m
//  Push
//
//  Created by Christopher Guess on 11/11/15.
//  Copyright © 2015 OCCRP. All rights reserved.
//

#import "ArticleViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <Masonry/Masonry.h>

@interface ArticleViewController ()

@property (nonatomic, retain) UIImageView * image;
@property (nonatomic, retain) UILabel * caption;
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


- (void)viewDidLoad {
    [super viewDidLoad];

    [self setShareButton];
    [self setupScrollView];
    [self setupContentView];
    [self setContraints];
}

- (void)setShareButton {
    UIBarButtonItem * shareBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonTapped)];
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
    
    self.caption = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    self.caption.numberOfLines = 3;
    self.caption.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.headline = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    self.headline.numberOfLines = 3;
    self.headline.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.body = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    self.body.delegate = self;
    self.body.editable = NO;
    self.body.scrollEnabled = NO;
    
    // Add the content views to the main view
    [self.contentView addSubview:self.image];
    [self.contentView addSubview:self.caption];
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
        make.height.lessThanOrEqualTo(self.scrollView).multipliedBy(0.5f);
    }];
    
    [self.caption mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.image.mas_bottom).with.offset(padding.top);
        make.left.equalTo(self.caption.superview.mas_left).with.offset(padding.left);
        make.right.equalTo(self.caption.superview.mas_right).with.offset(-padding.right);
    }];
    
    [self.headline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.caption.mas_bottom).with.offset(padding.top);
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
    [self.image setImageWithURL:[NSURL URLWithString:self.article.imageUrls.firstObject]];
    
    __weak typeof(self) weakSelf = self;
    [self.image setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.article.imageUrls.firstObject]] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        weakSelf.image.image = image;
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        NSLog(@"Error loading image: %@", error.localizedDescription);
    }];
    
    //Set image caption, hide if there is none.
    if(self.article.captions.count > 0){
        self.caption.text = self.article.captions[0];
        self.caption.font = [UIFont fontWithName:@"Palatino-Roman" size:15.0f];
    } else {
        self.caption.hidden = YES;
    }
    
    //Set the headline
    self.headline.text = self.article.headline;
    self.headline.font = [UIFont fontWithName:@"TrebuchetMS" size:25.0f];
    
    //Set the body using html for the formatting
    self.body.attributedText = [[NSAttributedString alloc] initWithData:[self.article.body dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                          NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                     documentAttributes:nil error:nil];
    self.body.font = [UIFont fontWithName:@"Palatino-Roman" size:17.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shareButtonTapped {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.article.headline, self.article.linkURL] applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
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
