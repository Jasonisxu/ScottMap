//
//  ViewController.m
//  GenerationOfDriving
//
//  Created by ZKR on 15/12/31.
//  Copyright © 2015年 ZKR. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <CoreGraphics/CoreGraphics.h>

#define API_KEY  @"5c0bd595963f61124d8ec2d6146b56ab"
@interface ViewController ()<MAMapViewDelegate,UIGestureRecognizerDelegate,AMapSearchDelegate>
{
    MAMapView *_mapView;
    AMapSearchAPI *_searchAPI;
    
    NSMutableArray *mutOverlaysArray;//要移除的绘画
    CLLocationCoordinate2D selectCoordinate; //点击到大头针的经纬度
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"高德地图";
    [self navLeftRightBtn];
    /*--------------------------------MAMapKit：------------------------------------------*/

    
    [MAMapServices sharedServices].apiKey=API_KEY;
    _mapView=[[MAMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate=self;
    [self.view addSubview:_mapView];
    
    //设置地图类型
    _mapView.mapType = MAMapTypeStandard;
    
//    //设置logo位置
//    _mapView.logoCenter = CGPointMake(50, 50);

    //显示罗盘
    _mapView.showsCompass = YES;
    _mapView.compassOrigin=CGPointMake(self.view.bounds.size.width-42, 70);
    
    
    
    
    // 是否显示用户位置
    _mapView.showsUserLocation=YES;
    // 追踪用户的location更新
    _mapView.userTrackingMode=MAUserTrackingModeFollow;
    //给当前位置进行标注
    [_mapView.userLocation setTitle:@"Jason"];
    [_mapView.userLocation setSubtitle:@"北京欢迎你"];
    
    
    
    //创建大头针对象
    MAPointAnnotation *pointAnnotation=[[MAPointAnnotation alloc] init];
    //插入大头针位置
    CLLocationCoordinate2D coordinate=CLLocationCoordinate2DMake(39.91684626, 116.39671326);
    pointAnnotation.coordinate=coordinate; //设置标注的坐标
    pointAnnotation.title=@"北京故宫博物院";//设置标题
    pointAnnotation.subtitle=@"Jason";//设置副标题
    [_mapView selectAnnotation:pointAnnotation animated:YES];
    [_mapView addAnnotation:pointAnnotation];//将标注添加在地图上
    

    
    /*!
     @brief 设置当前地图的缩放级别zoom level
     @param zoomLevel 要设置的zoom level
     @param animated 是否采用动画效果
     从“10”开始测试，逐渐递增
     */
    [_mapView setZoomLevel:11 animated:YES];
    
    
    //添加长按手势－－－－》（暂时响应不了）－－》解决
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.delegate=self;
    _mapView.userInteractionEnabled=YES;
    [_mapView addGestureRecognizer:longPress];
    
    
    /*--------------------------------AMapSearchKit：------------------------------------------*/
    
    //  创建AMapSearchAPI对象，配置APPKEY，同时设置代理对象为self
    /**
     *  AMapSearch的初始化函数。
     *
     *  初始化之前请设置 AMapSearchServices 中的APIKey，否则将无法正常使用搜索服务.
     *  @return AMapSearch类对象实例
     */
    
    [AMapSearchServices sharedServices].apiKey=API_KEY;
    _searchAPI = [[AMapSearchAPI alloc] init];
    _searchAPI.delegate=self;
    
    
    mutOverlaysArray=[NSMutableArray array];
}


-(void)navLeftRightBtn{
    UIButton* locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBtn.frame = CGRectMake(0, 0, 50, 50);
    [locationBtn setTitle:@"选择" forState:UIControlStateNormal];
    [locationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    locationBtn.titleLabel.font =[UIFont systemFontOfSize:13];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:locationBtn];
    [locationBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)selectAction:(UIButton *)sender{
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"选择展现" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    
    UIAlertAction * cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];

    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:@"显示交通" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        /*!
         @brief 是否显示交通，默认为NO
         */
        _mapView.showTraffic=YES;
    }];
    [alertController addAction:archiveAction];
    
    UIAlertAction *centerAction = [UIAlertAction actionWithTitle:@"家乡坐标" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        /*!
         设置中心点坐标
         纬度和经度
         */
        //创建大头针对象
        MAPointAnnotation *pointAnnotation=[[MAPointAnnotation alloc] init];
        //插入大头针位置
        CLLocationCoordinate2D coordinate=CLLocationCoordinate2DMake(35.16837084, 113.88573647);
        pointAnnotation.coordinate=coordinate; //设置标注的坐标
        pointAnnotation.title=@"东荆楼";//设置标题
        pointAnnotation.subtitle=@"我的家";//设置副标题
        [_mapView addAnnotation:pointAnnotation];//将标注添加在地图上
        
        [_mapView setCenterCoordinate:coordinate animated:YES];
        
        
    }];
    [alertController addAction:centerAction];
    
    
    UIAlertAction *searchPOIAction = [UIAlertAction actionWithTitle:@"银行|医院" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [self searchPOIAction];
    }];
    [alertController addAction:searchPOIAction];
    
    UIAlertAction *drawPolyLineAction = [UIAlertAction actionWithTitle:@"画折线" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self drawPolyLine];
    }];
    [alertController addAction:drawPolyLineAction];
    
    UIAlertAction *drivingAction = [UIAlertAction actionWithTitle:@"路线规划" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self drivingAction];
    }];
    [alertController addAction:drivingAction];
    
    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"清除:除了定位" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //清空原来的标注（大头针）
        [_mapView removeAnnotations:_mapView.annotations];
        
        /*!
         @brief 是否显示交通，默认为NO
         */
        _mapView.showTraffic=NO;
        
        /*!
         @brief 移除一组Overlay
         @param overlays 要移除的overlay数组
         */

        [_mapView removeOverlays:mutOverlaysArray];

        
    }];
    [alertController addAction:removeAction];
    
    UIAlertAction *clearDiskAction = [UIAlertAction actionWithTitle:@"清除缓存" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        /*!
         @brief 清除所有磁盘上缓存的地图数据。
         */
        [_mapView clearDisk];
    }];
    [alertController addAction:clearDiskAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/*!
 @brief 根据anntation生成对应的View
 @param mapView 地图View
 @param annotation 指定的标注
 @return 生成的标注View
 */
- (MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAAnnotationView*annotationView = (MAAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView=[[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
//            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
//        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
//        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
//        annotationView.pinColor = MAPinAnnotationColorPurple;
        annotationView.image=[UIImage imageNamed:@"l.png"];
        
        //添加显示气泡右边的button
        UIButton *rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setFrame:CGRectMake(0, 0, 50, 50)];
        [rightButton setImage:[UIImage imageNamed:@"location.png"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(arriveAction) forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView=rightButton;
        
        
        return annotationView;
    }
    return nil;
}


//气泡右边的到达按钮
-(void)arriveAction{
    /*!
     @brief 移除一组Overlay
     @param overlays 要移除的overlay数组
     */
    
    [_mapView removeOverlays:mutOverlaysArray];

    
    //构造AMapDrivingRouteSearchRequest对象，设置驾车路径规划请求参数
    AMapDrivingRouteSearchRequest *drivingRequest=[[AMapDrivingRouteSearchRequest alloc] init];
    //无论哪种类型路径规划，origin（起点坐标）和destination（终点坐标）为必设参数。
    drivingRequest.origin=[AMapGeoPoint locationWithLatitude:_mapView.userLocation.coordinate.latitude longitude:_mapView.userLocation.coordinate.longitude];
    drivingRequest.destination=[AMapGeoPoint locationWithLatitude:selectCoordinate.latitude longitude:selectCoordinate.longitude];
    drivingRequest.strategy=2;//距离优先
    drivingRequest.requireExtension=YES;
    
    [_searchAPI AMapDrivingRouteSearch:drivingRequest];
}



#pragma  mark -- 大头针的选中或取消

/*!
 @brief 当选中或取消一个annotation views时调用此接口
 @param mapView 地图View
 @param views 选中的annotation views
 */
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    selectCoordinate=view.annotation.coordinate;
    if (selectCoordinate.latitude !=_mapView.userLocation.coordinate.latitude && selectCoordinate.longitude !=_mapView.userLocation.coordinate.longitude) {
        view.image=[UIImage imageNamed:@"location.png"];

    }

}

- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view{
    if (selectCoordinate.latitude !=_mapView.userLocation.coordinate.latitude && selectCoordinate.longitude !=_mapView.userLocation.coordinate.longitude) {

    view.image=[UIImage imageNamed:@"l.png"];
    }
}


#pragma  mark -- 长按手势Action(插入大头针)
//解决手势不响应问题
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
-(void)longPress:(UILongPressGestureRecognizer *)longPress {
    
    if (longPress.state != UIGestureRecognizerStateBegan) {
        
        return;
    }

    //获取点位置
    CGPoint point = [longPress locationInView:_mapView];
    
    //将点位置转换成经纬度坐标
    CLLocationCoordinate2D coordinate = [_mapView convertPoint:point toCoordinateFromView:_mapView];
    
    
    
    //进行逆地编码时，请求参数类为 AMapReGeocodeSearchRequest，location为必设参数。
    //构造AMapReGeocodeSearchRequest对象
    AMapReGeocodeSearchRequest *regeoRequest=[[AMapReGeocodeSearchRequest alloc] init];
    regeoRequest.location=[AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeoRequest.requireExtension=YES;
    
    //发起逆地理编码
    [_searchAPI AMapReGoecodeSearch:regeoRequest];
    
    
//    //在该点添加一个大头针(标注)
//    
//    MAPointAnnotation *pointAnn = [[MAPointAnnotation alloc] init];
//    pointAnn.coordinate = coordinate;
//    pointAnn.title = @"长按的大头针";
//    pointAnn.subtitle = @"副标题";
//    [_mapView addAnnotation:pointAnn];
}


#pragma mark   searchPOIAction
-(void)searchPOIAction{
    
    
    // 创建搜索周边请求类
    /*
     /// POI周边搜索
     @interface AMapPOIAroundSearchRequest : AMapPOISearchBaseRequest
     
     @property (nonatomic, copy)   NSString     *keywords; //<! 查询关键字，多个关键字用“|”分割
     @property (nonatomic, copy)   AMapGeoPoint *location; //<! 中心点坐标
     @property (nonatomic, assign) NSInteger     radius; //<! 查询半径，范围：0-50000，单位：米 [default = 3000]
     */
    AMapPOIAroundSearchRequest *searchRequest=[[AMapPOIAroundSearchRequest alloc] init];
    searchRequest.keywords=@"银行|医院";
    searchRequest.location=[AMapGeoPoint locationWithLatitude:_mapView.userLocation.coordinate.latitude longitude:_mapView.userLocation.coordinate.longitude];
    searchRequest.radius=1000;
    [_searchAPI AMapPOIAroundSearch:searchRequest];
}


#pragma  mark  AMapSearchDelegate
/**
 *  当请求发生错误时，会调用代理的此方法.
 *
 *  @param request 发生错误的请求.
 *  @param error   返回的错误.
 */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
        NSLog(@"searchError:%@",error);
    
}

/**
 *  POI查询回调函数
 *
 *  @param request  发起的请求，具体字段参考 AMapPOISearchBaseRequest 及其子类。
 *  @param response 响应结果，具体字段参考 AMapPOISearchResponse 。
 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    //清空原来的标注（大头针）
    [_mapView removeAnnotations:_mapView.annotations];
    NSLog(@"response:%li",response.count);

    if (response) {
        
        //取出搜索到的POI
        for (AMapPOI *poi in response.pois) {
            
            //poi 的坐标
            CLLocationCoordinate2D coordinate=CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
            //地址
            NSString *address=poi.address;
            
            
            
            [_mapView setCenterCoordinate:coordinate animated:YES];
            //用标注显示
            MAPointAnnotation *pointAnn = [[MAPointAnnotation alloc] init];
            pointAnn.coordinate = coordinate;
            pointAnn.title = poi.name;
            pointAnn.subtitle = address;
            [_mapView addAnnotation:pointAnn];
        }
        
    }else{
        NSLog(@"response:%@",response);
    }
}


#pragma mark 画折线 定制折线视图
-(void)drawPolyLine{
    
    //初始化点
    NSArray *latitudeArray=[NSArray arrayWithObjects:
                             @"39.98264474",
                             
                             @"39.97606774",
                             
                             @"39.97580464",
                             
                             @"39.92342895",
                             
                             @"39.92395554", nil];
    NSArray *longitudeArray = [NSArray arrayWithObjects:
                                
                                @"116.33525848",
                                
                                @"116.340065",
                                
                                @"116.44168854",
                                
                                @"116.46194458",
                                
                                @"116.39705658", nil];
    
    //创建数组
    CLLocationCoordinate2D polyLineCorrds[5];
    
    for (int i=0; i<5; i++) {
        polyLineCorrds[i].latitude=[latitudeArray[i] floatValue];
        polyLineCorrds[i].longitude=[longitudeArray[i] floatValue];
    }
    
    //创建折线对象
    MAPolyline *polyLine=[MAPolyline polylineWithCoordinates:polyLineCorrds count:5];
    //在地图上显示折线
    [_mapView addOverlay:polyLine];
    
    [mutOverlaysArray addObject:polyLine];
}

/*!
 @brief 根据overlay生成对应的Renderer
 @param mapView 地图View
 @param overlay 指定的overlay
 @return 生成的覆盖物Renderer
 */
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay{
    
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        MAPolylineRenderer *polyLineRenderer=[[MAPolylineRenderer alloc] initWithOverlay:overlay];
        //折线宽度
        polyLineRenderer.lineWidth=3;
        //折线颜色
        polyLineRenderer.strokeColor=[UIColor blackColor];
        //折线连接类型
        polyLineRenderer.lineJoin=kCGLineJoinMiter;
        
        return polyLineRenderer;
    }
    return nil;
}

#pragma mark -AMapDrivingRouteSearchRequest

-(void)drivingAction{
    //构造AMapDrivingRouteSearchRequest对象，设置驾车路径规划请求参数
    AMapDrivingRouteSearchRequest *drivingRequest=[[AMapDrivingRouteSearchRequest alloc] init];
    //无论哪种类型路径规划，origin（起点坐标）和destination（终点坐标）为必设参数。
    drivingRequest.origin=[AMapGeoPoint locationWithLatitude:39.98264474 longitude:116.33525848];
    drivingRequest.destination=[AMapGeoPoint locationWithLatitude:39.92395554 longitude:116.39705658];
    drivingRequest.strategy=2;//距离优先
    drivingRequest.requireExtension=YES;
    
    [_searchAPI AMapDrivingRouteSearch:drivingRequest];

}

-(void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response{
    if (response.route==nil) {
        return;
    }
  
    //!< 路径规划信息
    AMapRoute *amapRoute=response.route;
    /*
     @property (nonatomic, copy) AMapGeoPoint *origin; //!< 起点坐标
     @property (nonatomic, copy) AMapGeoPoint *destination; //!< 终点坐标
     
     @property (nonatomic, assign) CGFloat  taxiCost; //!< 出租车费用（单位：元）
     @property (nonatomic, strong) NSArray *paths; //!< 步行、驾车方案列表 AMapPath 数组
     @property (nonatomic, strong) NSArray *transits; //!< 公交换乘方案列表 AMapTransit 数组
     */
    for (int i=0; i<amapRoute.paths.count; i++) {
        AMapPath *amapPath=[amapRoute.paths objectAtIndex:i];
        /*
         @property (nonatomic, assign) NSInteger  distance; //!< 起点和终点的距离
         @property (nonatomic, assign) NSInteger  duration; //!< 预计耗时（单位：秒）
         @property (nonatomic, copy)   NSString  *strategy; //!< 导航策略
         @property (nonatomic, strong) NSArray   *steps; //!< 导航路段 AMapStep数组
         @property (nonatomic, assign) CGFloat    tolls; //!< 此方案费用（单位：元）
         @property (nonatomic, assign) NSInteger  tollDistance; //!< 此方案收费路段长度（单位：米）
         */

        for (int j=0; j<amapPath.steps.count; j++) {
            AMapStep *amapStep=[amapPath.steps objectAtIndex:j];
            /*
             // 基础信息
             @property (nonatomic, copy)   NSString  *instruction; //!< 行走指示
             @property (nonatomic, copy)   NSString  *orientation; //!< 方向
             @property (nonatomic, copy)   NSString  *road; //!< 道路名称
             @property (nonatomic, assign) NSInteger  distance; //!< 此路段长度（单位：米）
             @property (nonatomic, assign) NSInteger  duration; //!< 此路段预计耗时（单位：秒）
             @property (nonatomic, copy)   NSString  *polyline; //!< 此路段坐标点串
             @property (nonatomic, copy)   NSString  *action; //!< 导航主要动作
             @property (nonatomic, copy)   NSString  *assistantAction; //!< 导航辅助动作
             @property (nonatomic, assign) CGFloat    tolls; //!< 此段收费（单位：元）
             @property (nonatomic, assign) NSInteger  tollDistance; //!< 收费路段长度（单位：米）
             @property (nonatomic, copy)   NSString  *tollRoad; //!< 主要收费路段
             
             // 扩展信息
             @property (nonatomic, strong) NSArray *cities; //!< 途径城市 AMapCity 数组
             */
            
            NSMutableString *mutPolyLine=[NSMutableString stringWithString:amapStep.polyline];
            NSArray *pointArray=[mutPolyLine componentsSeparatedByString:@";"];
            
            //创建数组
            CLLocationCoordinate2D polyLineCorrds[pointArray.count];

            for (int k=0; k<pointArray.count; k++) {

                polyLineCorrds[k].latitude=[[pointArray[k] componentsSeparatedByString:@","][1] floatValue];
                polyLineCorrds[k].longitude=[[pointArray[k] componentsSeparatedByString:@","][0]  floatValue];

            }

            //创建折线对象
            MAPolyline *polyLine=[MAPolyline polylineWithCoordinates:polyLineCorrds count:pointArray.count];
            //在地图上显示折线
            [_mapView addOverlay:polyLine];
            
            [mutOverlaysArray addObject:polyLine];
        }
    }
}
#pragma mark --//实现逆地理编码的回调函数

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    
    if (response.regeocode !=nil) {
    /*
     // 基础信息
     @property (nonatomic, copy)   NSString             *formattedAddress; //!< 格式化地址
     @property (nonatomic, strong) AMapAddressComponent *addressComponent; //!< 地址组成要素
     
     // 扩展信息
     @property (nonatomic, strong) NSArray *roads; //!< 道路信息 AMapRoad 数组
     @property (nonatomic, strong) NSArray *roadinters; //!< 道路路口信息 AMapRoadInter 数组
     @property (nonatomic, strong) NSArray *pois; //!< 兴趣点信息 AMapPOI 数组
     */
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
        
        MAPointAnnotation *pointAnn = [[MAPointAnnotation alloc] init];
        pointAnn.coordinate =coordinate;
        pointAnn.title = response.regeocode.formattedAddress;
        pointAnn.subtitle = @"by Jason";
        [_mapView addAnnotation:pointAnn];

    
    }
}


////要实时获得用户的经纬度:则需要添加下面这个代理方法
//-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
//updatingLocation:(BOOL)updatingLocation
//{
//    if (updatingLocation) {
//        NSLog(@"latitude : %f , longitude : %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
//        
////         //定位后，可设置停止定位(如果停止定位，可能不显示标注)
////         _mapView.showsUserLocation = NO;
//    }
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
