#import "YTPivotBarReorder.h"
#import "uYouPlus.h"

@interface YTPivotBarReorder ()

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *pivotBarItems;

@end

@implementation YTPivotBarReorder

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Reorder Pivot Bar Icons";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.dragDelegate = self;
    self.collectionView.dropDelegate = self;
    self.collectionView.dragInteractionEnabled = YES;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.view addSubview:self.collectionView];
    
    self.pivotBarItems = [@[@"Home", @"Shorts", @"Subscriptions", @"Notifications", @"Library"] mutableCopy];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pivotBarItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UILabel *label = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    label.text = self.pivotBarItems[indexPath.row];
    label.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:label];
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

@end
