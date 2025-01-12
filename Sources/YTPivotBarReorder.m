#import "YTPivotBarReorder.h"
#import "uYouPlus.h"
#import <YouTubeHeader/YTIGuideResponse.h>
#import <YouTubeHeader/YTIGuideResponseSupportedRenderers.h>
#import <YouTubeHeader/YTIPivotBarRenderer.h>
#import <YouTubeHeader/YTIPivotBarSupportedRenderers.h>
#import <YouTubeHeader/YTIPivotBarItemRenderer.h>
#import <YouTubeHeader/YTAssetLoader.h>

@interface YTPivotBarReorder ()

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *pivotBarItems;

@end

@implementation YTPivotBarReorder

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Reorder Pivot Bar Icons";
    self.view.backgroundColor = [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.0];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(closeController)];
    self.navigationItem.rightBarButtonItem = closeButton;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(80, 80);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.dragDelegate = self;
    self.collectionView.dropDelegate = self;
    self.collectionView.dragInteractionEnabled = YES;
    self.collectionView.backgroundColor = [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.0];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.view addSubview:self.collectionView];
    
    [self loadActivePivotTabs];
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
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pivotBarItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
    YTIPivotBarItemRenderer *itemRenderer = self.pivotBarItems[indexPath.row];
    iconView.image = [YTAssetLoader loadImageWithIdentifier:itemRenderer.icon.identifier];
    iconView.tintColor = [UIColor whiteColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.contentView addSubview:iconView];
    return cell;
}

- (NSArray<UIDragItem *> *)collectionView:(UICollectionView *)collectionView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath {
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:self.pivotBarItems[indexPath.row]];
    UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    dragItem.localObject = self.pivotBarItems[indexPath.row];
    return @[dragItem];
}

- (void)collectionView:(UICollectionView *)collectionView performDropWithCoordinator:(id<UICollectionViewDropCoordinator>)coordinator {
    NSIndexPath *destinationIndexPath = coordinator.destinationIndexPath;
    if (!destinationIndexPath) {
        destinationIndexPath = [NSIndexPath indexPathForRow:self.pivotBarItems.count - 1 inSection:0];
    }

    for (id<UICollectionViewDropItem> dropItem in coordinator.items) {
        NSIndexPath *sourceIndexPath = dropItem.sourceIndexPath;
        if (sourceIndexPath) {
            [collectionView performBatchUpdates:^{
                id item = self.pivotBarItems[sourceIndexPath.row];
                [self.pivotBarItems removeObjectAtIndex:sourceIndexPath.row];
                [self.pivotBarItems insertObject:item atIndex:destinationIndexPath.row];
                [collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
            } completion:nil];
        }
    }
}

- (YTIGuideResponse *)getGuideResponse {
    return nil;
}

@end
