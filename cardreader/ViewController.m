//
//  ViewController.m
//  cardreader
//
//  Created by Geoffroy Lesage on 7/12/15.
//  Copyright (c) 2015 Geoffroy Lesage. All rights reserved.
//

#import "ViewController.h"

#import <MBProgressHUD.h>
#import <OHAlertView.h>

@interface ViewController ()

@end

@implementation ViewController
{
    MBProgressHUD *hud;
    G8Tesseract *tess;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTesseract];
}

- (void)setupTesseract
{
    tess = [[G8Tesseract alloc] initWithLanguage:@"eng"];
    tess.engineMode = G8OCREngineModeTesseractCubeCombined;
    tess.delegate = self;
    
    // Optional: Limit the character set Tesseract should try to recognize from
    NSString *alphabet = @"abcdefghijklmnopqrstuvxyz";
    NSString *alphabetCaps = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSString *numbers = @"0123456789";
    NSString *characters = @"@-_.";
    tess.charWhitelist = [NSString stringWithFormat:@"%@%@%@%@", alphabet,alphabetCaps,numbers,characters];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Reading";
    
    [self performSelector:@selector(processCard) withObject:nil afterDelay:0];
    [self displayCardData:[tess recognizedText]];
    
    [hud hide:YES];
}

-(void)processCard
{
    UIImage *card = [UIImage imageNamed:@"good"];
    tess.image = [card g8_grayScale];
    //tess.image = [card g8_blackAndWhite];
    
    // Optional: Limit the area of the image Tesseract should recognize on to a rectangle
    //tess.rect = CGRectMake(20, 20, 100, 100);
    
    // Optional: Limit recognition time with a few seconds
    //tess.maximumRecognitionTime = 1.0;
    
    [tess recognize];
}

- (void)displayCardData:(NSString*)cardText
{
    NSMutableArray *lines = [NSMutableArray array];
    NSMutableString *line = [NSMutableString string];
    
    NSUInteger len = [cardText length];
    unichar buffer[len+1];
    
    [cardText getCharacters:buffer range:NSMakeRange(0, len)];
    
    for(int i = 0; i < len; i++)
    {
        if (buffer[i] == '\n')
        {
            if (line.length < 1) continue;
            [lines addObject:[NSString stringWithString:line]];
            [line setString:@""];
        }
        else [line appendFormat:@"%C", buffer[i]];
    }
    
    NSLog(@"%@", lines);
}

- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    NSLog(@"%lu", (unsigned long)tesseract.progress);
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

@end
