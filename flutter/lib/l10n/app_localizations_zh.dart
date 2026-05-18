// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get navHome => '首页';

  @override
  String get navMap => '地图';

  @override
  String get navIdentify => '识别';

  @override
  String get navMission => '任务';

  @override
  String get navSaved => '已保存';

  @override
  String get menuTitle => '菜单';

  @override
  String get menuLanguage => '语言';

  @override
  String get menuMoreInfo => '更多信息';

  @override
  String get menuNatureFirst => '自然优先原则';

  @override
  String get menuShowTutorial => '显示教程';

  @override
  String get menuAboutUs => '关于我们';

  @override
  String get homeTitle => '马来西亚野生动物探索';

  @override
  String get homeSearchHint => '搜索物种名称';

  @override
  String get homeFilter => '筛选';

  @override
  String get homeSort => '排序';

  @override
  String get homeClear => '清除';

  @override
  String get homeResetFilters => '重置筛选';

  @override
  String get homeConfirm => '确认';

  @override
  String get homeReset => '重置';

  @override
  String get homeNoResults => '未找到物种';

  @override
  String get homeNoFilterResults => '没有符合筛选条件的结果';

  @override
  String get homeClearSearch => '清除搜索';

  @override
  String get homeCity => '城市';

  @override
  String get homeSite => '地点';

  @override
  String get homeAll => '全部';

  @override
  String get homeCategory => '类别';

  @override
  String get homeConservationStatus => '保护状态';

  @override
  String get homeDifficultyLevel => '拍摄难度等级';

  @override
  String get homeSortBy => '排序方式';

  @override
  String get homeSortNone => '无';

  @override
  String get homeSortConservation => '保护状态';

  @override
  String get homeSortDifficulty => '难度等级';

  @override
  String get homeOrderAsc => '升序';

  @override
  String get homeOrderDesc => '降序';

  @override
  String get homeAreaPrediction => '显示所选区域的预测排序物种。';

  @override
  String get homeAllRegions => '所有区域';

  @override
  String get homeDifficulty => '难度：';

  @override
  String get homeLocationTab => '位置';

  @override
  String get homeSpeciesTab => '物种';

  @override
  String get homeShowMore => '显示更多';

  @override
  String get homeShowLess => '显示更少';

  @override
  String get identifyTitle => '图像识别';

  @override
  String get identifySpeciesTab => '物种';

  @override
  String get identifyQualityTab => '图像质量';

  @override
  String get identifySpeciesSubtitle => '用AI识别野生动物照片。';

  @override
  String get identifyQualitySubtitle => '分析照片的清晰度、曝光和构图。';

  @override
  String get identifyScanNow => '立即识别';

  @override
  String get identifyScoreNow => '立即评分';

  @override
  String get identifyPickerHint => '点击拍照或从相册上传';

  @override
  String get identifyTakePhoto => '拍照';

  @override
  String get identifyUploadGallery => '从相册上传';

  @override
  String get identifyCancel => '取消';

  @override
  String get identifyTipsTitle => '物种扫描小贴士';

  @override
  String get identifyTipLighting => '使用良好光线';

  @override
  String get identifyTipLightingBody => '自然光能提供更好的识别效果。';

  @override
  String get identifyTipCentered => '保持动物居中';

  @override
  String get identifyTipCenteredBody => '避免将动物截出画面。';

  @override
  String get identifyTipClear => '清晰的背景';

  @override
  String get identifyTipClearBody => '减少主体后方的干扰元素。';

  @override
  String get identifyAnalyzing => '正在分析您的照片...';

  @override
  String get identifyFailed => '图像分析失败，请重试。';

  @override
  String get savedEmptyTitle => '还没有收藏物种';

  @override
  String get savedEmptyBody => '开始探索并保存你想拍摄的物种。';

  @override
  String get savedExploreButton => '探索物种';

  @override
  String get savedTitle => '已保存';

  @override
  String savedSpeciesCount(int count) {
    return '$count 个物种';
  }

  @override
  String get speciesDetailAbout => '关于';

  @override
  String get speciesDetailBehavior => '行为与笔记';

  @override
  String get speciesDetailPhotography => '拍摄条件';

  @override
  String get speciesDetailGear => '推荐装备';

  @override
  String get speciesDetailBestSeasons => '最佳季节';

  @override
  String get speciesDetailPrediction => '当前预测';

  @override
  String get speciesDetailSavedToFav => '已收藏';

  @override
  String get speciesDetailSaveToFav => '收藏';

  @override
  String get commonOk => '确定';

  @override
  String get commonCancel => '取消';

  @override
  String get commonRetry => '重试';

  @override
  String get commonError => '错误';

  @override
  String get commonPrevious => '上一页';

  @override
  String get commonNext => '下一页';

  @override
  String get categoryMammals => '哺乳动物';

  @override
  String get categoryBirds => '鸟类';

  @override
  String get categoryReptiles => '爬行动物';

  @override
  String get categoryAmphibians => '两栖动物';

  @override
  String get categoryInsects => '昆虫';

  @override
  String get statusLeastConcern => '无危';

  @override
  String get statusNearThreatened => '近危';

  @override
  String get statusVulnerable => '易危';

  @override
  String get statusEndangered => '濒危';

  @override
  String get statusCriticallyEndangered => '极危';

  @override
  String get shootingDifficulty => '拍摄难度';

  @override
  String get speciesDetailHabitat => '栖息地';

  @override
  String get speciesDetailHabitatLocations => '栖息地与位置';

  @override
  String get speciesDetailDiet => '饮食';

  @override
  String get speciesDetailSeeMorePrediction => '查看更多预测详情';

  @override
  String get speciesDetailBestTime => '最佳时间';

  @override
  String get speciesDetailWeather => '天气';

  @override
  String get speciesDetailTemp => '温度';

  @override
  String get speciesDetailHumidity => '湿度';

  @override
  String get speciesDetailActivityPattern => '活动模式';

  @override
  String get predictionTitle => '7天出现预测';

  @override
  String get predictionKeyFactors => '关键因素';

  @override
  String get predictionAlertOff => '提醒关闭';

  @override
  String get predictionAlertOn => '提醒开启';

  @override
  String get predictionToday => '今天';

  @override
  String get predictionTomorrow => '明天';

  @override
  String get predictionBestTime => '最佳时间';

  @override
  String get predictionWeather => '天气';

  @override
  String get predictionTemperature => '温度';

  @override
  String get predictionHumidity => '湿度';

  @override
  String get predictionUnknown => '未知';

  @override
  String get predictionViewFullSpecies => '查看完整物种详情';

  @override
  String get predictionCalculating => '正在计算预测...';

  @override
  String get predictionBack => '返回';

  @override
  String predictionBestSite(String site) {
    return '最佳地点：$site';
  }

  @override
  String get mapSearchHint => '搜索物种';

  @override
  String get mapMyLocation => '我的位置';

  @override
  String get mapWeather => '天气';

  @override
  String get mapSpeciesSites => '物种地点';

  @override
  String get identifyTotalScore => '总分';

  @override
  String get identifySharpness => '清晰度';

  @override
  String get identifyExposure => '曝光';

  @override
  String get identifyContrast => '对比度';

  @override
  String get identifySubjectFraming => '主体构图';

  @override
  String get identifyHowToImprove => '如何改善这张照片';

  @override
  String get identifyTryAnother => '尝试另一张照片';

  @override
  String get identifySpeciesResult => '已识别物种';

  @override
  String get identifyConfidence => '置信度';

  @override
  String get identifyNotRecognized => '未识别物种';

  @override
  String get identifyLow => '低';

  @override
  String get identifyMedium => '中';

  @override
  String get identifyHigh => '高';

  @override
  String get identifyScanningSpecies => '正在扫描物种...';

  @override
  String get identifyScoringQuality => '正在评分照片质量...';

  @override
  String get missionTitle => '摄影任务';

  @override
  String get missionSubtitle => '马来西亚野生动物探索';

  @override
  String get missionPersonalise => '个性化定制属于你的完美挑战！';

  @override
  String get missionChoosePrefs => '选择你的偏好，我们将为你创建专属任务。';

  @override
  String get missionLetsBegin => '开始吧！';

  @override
  String get missionIdeasTitle => '任务灵感';

  @override
  String get missionIdeasSubtitle => '快速获取灵感';

  @override
  String get missionGearQuestion => '你有什么器材？';

  @override
  String get missionGearSubtitle => '选择你的相机设置';

  @override
  String get missionDifficultyQuestion => '选择挑战等级';

  @override
  String get missionDifficultySubtitle => '这个任务应该多难？';

  @override
  String get missionSubjectQuestion => '你喜欢什么主题？';

  @override
  String get missionSubjectSubtitle => '选择野生动物类别';

  @override
  String get missionTimeQuestion => '首选拍摄时间？';

  @override
  String get missionTimeSubtitle => '选择你的理想拍摄时段';

  @override
  String get missionYourMission => '你的摄影任务';

  @override
  String missionLocationHint(String hint) {
    return '位置提示：$hint';
  }

  @override
  String get missionMoveOn => '继续到任务列表';

  @override
  String get missionResetChoices => '重置选择';

  @override
  String get missionWeeklyTask => '每周任务';

  @override
  String get missionStartOver => '重新开始';

  @override
  String get missionSubmitProof => '上传证明照片';

  @override
  String get missionCasual => '休闲';

  @override
  String get missionStandard => '标准';

  @override
  String get missionChallenging => '挑战';

  @override
  String get missionMorning => '早晨';

  @override
  String get missionAfternoon => '下午';

  @override
  String get missionEvening => '傍晚';

  @override
  String get missionNight => '夜晚';

  @override
  String get missionMidnight => '午夜';

  @override
  String get onboardingWelcomeTitle => '欢迎来到 KACHAK';

  @override
  String get onboardingWelcomeBody => '一个明亮、新手友好的马来西亚野生动物摄影伴侣。';

  @override
  String get onboardingFiveTools => '五个工具，一段旅程';

  @override
  String get onboardingFiveToolsBody => '发现物种、保存收藏、用AI识别照片、执行引导任务、探索地图。';

  @override
  String get onboardingTapTab => '点击标签开始';

  @override
  String get onboardingTapTabBody => '我们会在你首次打开每个板块时展示快速导览。随时从菜单中重新打开。';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingGetStarted => '开始使用';

  @override
  String get tourHomeTitle => '发现物种';

  @override
  String get tourHomeSubtitle => '像翻阅野外指南一样浏览马来西亚野生动物。';

  @override
  String get tourSearchTitle => '按名称搜索';

  @override
  String get tourSearchBody => '输入常用名或学名直接跳转到物种卡片。';

  @override
  String get tourFilterTitle => '筛选和排序';

  @override
  String get tourFilterBody => '使用标签按位置、类别、保护状态和难度进行筛选。';

  @override
  String get tourLayoutTitle => '切换布局';

  @override
  String get tourLayoutBody => '点击右侧布局按钮在列表和网格之间切换。';

  @override
  String get tourSaveTitle => '保存收藏';

  @override
  String get tourSaveBody => '收藏任何卡片，稍后从侧边菜单重新访问。';

  @override
  String get tourAreaTitle => '首页区域预测';

  @override
  String get tourAreaBody => '在筛选中选择位置，将首页切换为预测排序结果。';

  @override
  String get tourIdentifyTitle => 'AI物种识别';

  @override
  String get tourIdentifySubtitle => '拍照或从相册选择照片即刻识别马来西亚野生动物。';

  @override
  String get tourTakePhotoTitle => '拍照';

  @override
  String get tourTakePhotoBody => '使用相机获取最新最清晰的结果。';

  @override
  String get tourUploadTitle => '从相册上传';

  @override
  String get tourUploadBody => '从设备中选择现有照片。';

  @override
  String get tourTipsTitle => '获取最佳结果的提示';

  @override
  String get tourTipsBody => '光线充足、清晰的单一主体照片能提供最佳匹配。';

  @override
  String get tourMapTitle => '在地图上探索';

  @override
  String get tourMapSubtitle => '查找野生动物地点、天气和你周围的最近目击记录。';

  @override
  String get tourMapSearchTitle => '搜索位置';

  @override
  String get tourMapSearchBody => '使用顶部搜索栏跳转到城市、公园或坐标。';

  @override
  String get tourMapMarkersTitle => '点击标记';

  @override
  String get tourMapMarkersBody => '标记显示已知栖息地。点击查看物种详情和天气。';

  @override
  String get tourMapRadiusTitle => '使用半径工具';

  @override
  String get tourMapRadiusBody => '调整搜索半径以聚焦你周围的区域。';

  @override
  String get tourMissionTitle => '个性化摄影任务';

  @override
  String get tourMissionSubtitle => '回答简短测验，我们将为你的器材和技能水平设计任务。';

  @override
  String get tourQuizTitle => '快速测验';

  @override
  String get tourQuizBody => '告诉我们你的器材、时间、主题和难度偏好。';

  @override
  String get tourGetMissionTitle => '获取你的任务';

  @override
  String get tourGetMissionBody => '接收量身定制的野外计划和分步任务。';

  @override
  String get tourSubmitTitle => '提交证明';

  @override
  String get tourSubmitBody => '上传照片标记任务完成并解锁下一步。';

  @override
  String get tourSavedTitle => '已保存物种';

  @override
  String get tourSavedSubtitle => '重新访问已收藏的物种并快速打开详情。';

  @override
  String get tourFavTitle => '你的收藏';

  @override
  String get tourFavBody => '你从首页和详情页收藏的物种会自动出现在这里。';

  @override
  String get tourOpenTitle => '打开物种详情';

  @override
  String get tourOpenBody => '点击任何已保存卡片跳转到完整物种详情和预测快捷方式。';

  @override
  String get tourCleanTitle => '清理列表';

  @override
  String get tourCleanBody => '当你的候选名单改变时移除已保存的条目。';

  @override
  String get identifyTipBlur => '避免模糊';

  @override
  String get identifyTipBlurBody => '保持稳定或点击对焦后再拍摄。';

  @override
  String get identifyPrediction => '预测';

  @override
  String get identifyOpenDetails => '打开完整详情';

  @override
  String get identifyUseMissionProof => '用作任务证明';

  @override
  String get mapLocationDenied => '位置访问被拒绝';

  @override
  String get mapLocationError => '无法获取位置';

  @override
  String get mapWeatherLoadError => '无法加载天气数据';

  @override
  String get mapClearSearch => '清除搜索';

  @override
  String get mapRefreshWeather => '刷新天气';

  @override
  String get mapHideCityWeather => '隐藏城市天气';

  @override
  String get mapShowCityWeather => '显示城市天气';

  @override
  String get mapShowSpeciesPhotoSpots => '显示物种拍摄点';

  @override
  String get mapZoomIn => '放大';

  @override
  String get mapZoomOut => '缩小';

  @override
  String get mapRestricted => '受限';

  @override
  String get mapClose => '关闭';

  @override
  String get mapLastSeen => '最近目击';

  @override
  String get mapDangerZone => '危险区域';

  @override
  String get mapOutsideProtected => '保护区外';

  @override
  String get mapViewMoreDetails => '查看更多详情';

  @override
  String get mapHumidity => '湿度';

  @override
  String get mapWind => '风力';

  @override
  String get mapPredictionRegion => '预测区域';

  @override
  String get mapNextForecast => '下次预报';

  @override
  String get mapForecastUnavailable => '预报不可用';

  @override
  String get mapHumidityShort => '湿度';

  @override
  String get mapWindShort => '风力';

  @override
  String get missionResetConfirm => '重置所有选择并重新开始？';

  @override
  String get missionReset => '重置';

  @override
  String get missionBirds => '鸟类';

  @override
  String get missionMammals => '哺乳动物';

  @override
  String get missionInsects => '昆虫';

  @override
  String get missionReptiles => '爬行动物';

  @override
  String get missionAmphibians => '两栖动物';

  @override
  String get detailRecordedObservation => '记录的观察';

  @override
  String get detailLastSeen => '最近目击';

  @override
  String get detailTapRowHint => '点击行以在该标记处打开地图。';

  @override
  String get detailShowMore => '显示更多';

  @override
  String get detailShowLess => '显示更少';

  @override
  String get detailNationalPark => '国家公园';

  @override
  String get detailDifficult => '困难';

  @override
  String get spotlightFilterTitle => '筛选野生动物列表';

  @override
  String get spotlightFilterBody => '使用筛选按位置和物种属性缩小范围。';

  @override
  String get spotlightFilterTabsTitle => '位置和物种筛选器';

  @override
  String get spotlightFilterTabsBody => '使用位置标签按城市或地点筛选。切换到物种以设置类别、保护状态和难度。';

  @override
  String get spotlightLayoutTitle => '切换布局';

  @override
  String get spotlightLayoutBody => '点击在卡片网格和紧凑列表之间切换。';

  @override
  String get spotlightAiChatTitle => 'AI 助手';

  @override
  String get spotlightAiChatBody => '询问野生动物摄影规划、准备和实地技巧。';

  @override
  String get spotlightMapPageTitle => '地图页面';

  @override
  String get spotlightMapPageBody => '地图帮助您查看野生动物位置并按地点探索区域。';

  @override
  String get spotlightIdentifyPageTitle => '识别页面';

  @override
  String get spotlightIdentifyPageBody => '识别功能让您从拍摄的照片中识别野生动物。';

  @override
  String get spotlightMissionPageTitle => '任务页面';

  @override
  String get spotlightMissionPageBody => '任务在探索过程中提供引导任务和学习挑战。';

  @override
  String get spotlightSavedPageTitle => '收藏页面';

  @override
  String get spotlightSavedPageBody => '收藏保存您标记的物种以便快速访问。';

  @override
  String get spotlightMapRefreshTitle => '刷新地图天气';

  @override
  String get spotlightMapRefreshBody => '从所有城市标记站重新加载天气信息。';

  @override
  String get spotlightMapWeatherTitle => '切换天气图层';

  @override
  String get spotlightMapWeatherBody => '显示或隐藏天气标记以专注于目击或预报背景。';

  @override
  String get spotlightMapFocusTitle => '聚焦野生动物热点';

  @override
  String get spotlightMapFocusBody => '跳转相机以覆盖已知野生动物和摄影热点。';

  @override
  String get spotlightMapMyLocTitle => '转到我的位置';

  @override
  String get spotlightMapMyLocBody => '快速将地图中心移回您的当前位置。';

  @override
  String get spotlightMapZoomInTitle => '放大';

  @override
  String get spotlightMapZoomInBody => '增加地图缩放以查看标记和区域细节。';

  @override
  String get spotlightMapZoomOutTitle => '缩小';

  @override
  String get spotlightMapZoomOutBody => '减少地图缩放以查看更广区域背景。';

  @override
  String get spotlightMapWeatherMarkerTitle => '天气标记';

  @override
  String get spotlightMapWeatherMarkerBody => '城市天气显示当前条件和短期预报以便规划拍摄。';

  @override
  String get spotlightMapAnimalMarkerTitle => '动物标记';

  @override
  String get spotlightMapAnimalMarkerBody => '点击动物标记查看物种信息、照片和附近天气。';

  @override
  String get spotlightDetailAlertTitle => '启用提醒';

  @override
  String get spotlightDetailAlertBody => '保存后，点击此图标启用物种通知以获取高概率目击提醒。';

  @override
  String get spotlightDetailPredictionTitle => '当前预测';

  @override
  String get spotlightDetailPredictionBody => '此卡片显示最佳地点和基于天气的当前目击概率。';

  @override
  String get spotlightDetailObservationTitle => '记录的观察';

  @override
  String get spotlightDetailObservationBody => '第一个记录观察行包含最近的目击和坐标。';

  @override
  String get spotlightDetailMapTitle => '在地图上打开';

  @override
  String get spotlightDetailMapBody => '点击此地图按钮直接在地图上查看动物最后出现的位置。';

  @override
  String get chatTitle => '摄影助手';

  @override
  String get chatSubtitle => '相机设置与技巧';

  @override
  String get chatWelcome => '有什么可以帮您？';

  @override
  String get chatHint => '询问任何关于野生动物摄影的问题...';

  @override
  String get chatDisclaimer => '摄影AI聊天可能会出错。请仔细核实回复。';

  @override
  String get chatCopied => '消息已复制';

  @override
  String get chatIrrelevant => '这与野生动物摄影无关。请尝试其他问题。';

  @override
  String get chatSuggestion1 => '拍摄飞行中的鸟类应该用什么相机设置？';

  @override
  String get chatSuggestion2 => '推荐拍摄夜行动物的器材';

  @override
  String get chatSuggestion3 => '昆虫微距摄影的最佳设置';

  @override
  String get chatSuggestion4 => '热带雨林拍摄应该带什么？';

  @override
  String get chatClarifyGear => '请分享您的相机和镜头，以便我为您调整设置。';

  @override
  String get chatClarifyAnimal => '请先说明您的目标动物，以便我准备合适的清单。';

  @override
  String get notificationHighProbTitle => '检测到最佳条件！';

  @override
  String notificationHighProbBody(int count) {
    return '您收藏的动物中有 $count 只今天有 >=80% 的出现几率！';
  }
}
