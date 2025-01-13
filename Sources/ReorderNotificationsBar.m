#import "ReorderNotificationsBar.h"
#import "uYouPlus.h"
#import <YouTubeHeader/YTIGuideResponse.h>
#import <YouTubeHeader/YTIGuideResponseSupportedRenderers.h>
#import <YouTubeHeader/YTIPivotBarRenderer.h>
#import <YouTubeHeader/YTIPivotBarSupportedRenderers.h>
#import <YouTubeHeader/YTIPivotBarItemRenderer.h>

@interface ReorderNotificationsBar ()

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *pivotBarItems;
@property (strong, nonatomic) UIButton *indexButton;
@property (strong, nonatomic) NSMutableArray *indexOptions;

@end

@implementation ReorderNotificationsBar

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Reorder Notifications Bar";
    self.view.backgroundColor = [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.0];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(closeController)];
    self.navigationItem.rightBarButtonItem = closeButton;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(80, 80);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.0];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.view addSubview:self.collectionView];
    
    [self loadActivePivotTabs];
    
    self.indexButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.indexButton.frame = CGRectMake(10, 80, 300, 40);
    [self.indexButton setTitle:@"Select Index" forState:UIControlStateNormal];
    [self.indexButton addTarget:self action:@selector(showIndexOptions) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.indexButton];
}

- (void)closeController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadActivePivotTabs {
    YTIGuideResponse *guideResponse = [self getGuideResponse];
    NSMutableArray *activeTabs = [NSMutableArray array];
    
    for (YTIGuideResponseSupportedRenderers *guideRenderers in [guideResponse itemsArray]) {
        YTIPivotBarRenderer *pivotBarRenderer = [guideRenderers pivotBarRenderer];
        for (YTIPivotBarSupportedRenderers *renderer in [pivotBarRenderer itemsArray]) {
            YTIPivotBarItemRenderer *itemRenderer = [renderer pivotBarItemRenderer];
            if (itemRenderer && !itemRenderer.isDisabled) {
                [activeTabs addObject:itemRenderer];
            }
        }
    }
    
    self.pivotBarItems = activeTabs;
    self.indexOptions = [NSMutableArray array];
    for (int i = 1; i <= self.pivotBarItems.count; i++) {
        [self.indexOptions addObject:[NSString stringWithFormat:@"%d", i]];
    }
    [self.collectionView reloadData];
}

- (void)showIndexOptions {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Index"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString *indexOption in self.indexOptions) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:indexOption
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
            [self.indexButton setTitle:[NSString stringWithFormat:@"Selected Index: %@", indexOption] forState:UIControlStateNormal];
            [self reorderPivotTabToIndex:[indexOption intValue] - 1];
        }];
        [alert addAction:action];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)reorderPivotTabToIndex:(NSUInteger)index {
    if (index >= self.pivotBarItems.count) return;

    YTIPivotBarItemRenderer *selectedItem = self.pivotBarItems[0];
    [self.pivotBarItems removeObjectAtIndex:0];
    [self.pivotBarItems insertObject:selectedItem atIndex:index];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pivotBarItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    YTIPivotBarItemRenderer *itemRenderer = self.pivotBarItems[indexPath.row];
    
    UILabel *indexLabel = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    indexLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:indexLabel];
    
    return cell;
}

- (YTIGuideResponse *)getGuideResponse {
    return nil;
}

@end
