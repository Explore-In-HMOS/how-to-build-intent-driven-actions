import { ArcList, ArcListAttribute, ArcListItem, ArcListItemAttribute } from '@ohos.arkui.ArcList';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  ACTION_CALL_HOME,
  ACTION_SET_TIMER,
  ACTION_START_WORKOUT,
  DEFAULT_CONTACT_LABEL,
  DEFAULT_TIMER_MINUTES,
  DEFAULT_WORKOUT_TYPE,
  MESSAGE_HOME_CONTACT_READY,
  MESSAGE_TIMER_STARTED,
  MESSAGE_WORKOUT_STARTED,
  PAGE_CALL_HOME,
  PAGE_TIMER,
  PAGE_WORKOUT,
  STORAGE_ACTION,
  STORAGE_CONTACT_LABEL,
  STORAGE_DURATION_MINUTES,
  STORAGE_MESSAGE,
  STORAGE_STARTED_AT,
  STORAGE_WORKOUT_TYPE
} from '../insightintents/IntentActionTypes';
import { WorkoutPage } from './WorkoutPage';
import { CallHomePage } from './CallHomePage';
import { TimerPage } from './TimerPage';

const DOMAIN = 0x0000;
const TAG = 'IntentActions';

@Entry
@Component
struct Index {
  @StorageProp('intentMessage') message: string = '';
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  pagesMap(name: string) {
    if (name === PAGE_WORKOUT) {
      WorkoutPage();
    } else if (name === PAGE_CALL_HOME) {
      CallHomePage();
    } else if (name === PAGE_TIMER) {
      TimerPage();
    }
  }

  aboutToAppear(): void {
    hilog.info(DOMAIN, TAG, 'Index aboutToAppear message=%{public}s', this.message);
    this.navigateForIntent();
  }

  private navigateForIntent(): void {
    const action: string = AppStorage.get<string>(STORAGE_ACTION) || '';
    if (action === ACTION_START_WORKOUT) {
      this.pageStack.pushPathByName(PAGE_WORKOUT, null);
    } else if (action === ACTION_CALL_HOME) {
      this.pageStack.pushPathByName(PAGE_CALL_HOME, null);
    } else if (action === ACTION_SET_TIMER) {
      this.pageStack.pushPathByName(PAGE_TIMER, null);
    }
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        ArcList() {
        ArcListItem() {
          Column({ space: 4 }) {
            Text($r('app.string.home_title'))
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.watch_text_primary'))

            if (this.message.length > 0) {
              Text(this.message)
                .fontSize(12)
                .fontColor($r('app.color.watch_text_secondary'))
                .textAlign(TextAlign.Center)
                .maxLines(2)
                .width('72%')
            } else {
              Text($r('app.string.home_status_default'))
                .fontSize(12)
                .fontColor($r('app.color.watch_text_secondary'))
                .textAlign(TextAlign.Center)
                .maxLines(2)
                .width('72%')
            }
          }
          .height(62)
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }

        ArcListItem() {
          Column({ space: 2 }) {
            Text($r('app.string.action_start_workout_short'))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.workout_accent'))
            Text($r('app.string.action_start_workout_desc'))
              .fontSize(10)
              .fontColor($r('app.color.watch_text_secondary'))
              .maxLines(1)
          }
          .width('72%')
          .height(48)
          .borderRadius(24)
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('app.color.workout_surface'))
          .onClick(() => {
            this.openWorkout();
          })
        }
        .autoScale(true)

        ArcListItem() {
          Column({ space: 2 }) {
            Text($r('app.string.action_call_home_short'))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.call_accent'))
            Text($r('app.string.action_call_home_desc'))
              .fontSize(10)
              .fontColor($r('app.color.watch_text_secondary'))
              .maxLines(1)
          }
          .width('72%')
          .height(48)
          .borderRadius(24)
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('app.color.call_surface'))
          .onClick(() => {
            this.openCallHome();
          })
        }
        .autoScale(true)

        ArcListItem() {
          Column({ space: 2 }) {
            Text($r('app.string.action_set_timer_short'))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.timer_accent'))
            Text($r('app.string.action_set_timer_desc'))
              .fontSize(10)
              .fontColor($r('app.color.watch_text_secondary'))
              .maxLines(1)
          }
          .width('72%')
          .height(48)
          .borderRadius(24)
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('app.color.timer_surface'))
          .onClick(() => {
            this.openTimer();
          })
        }
        .autoScale(true)
      }
      .height('94%')
      .width('100%')
      .fadingEdge(true)
      .chainAnimation(true)
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.watch_bg'))
    }
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
    .hideBackButton(true)
    .navDestination(this.pagesMap)
  }

  private openWorkout(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Index manual action StartWorkout');
    AppStorage.setOrCreate<string>(STORAGE_ACTION, ACTION_START_WORKOUT);
    AppStorage.setOrCreate<string>(STORAGE_MESSAGE, MESSAGE_WORKOUT_STARTED);
    AppStorage.setOrCreate<string>(STORAGE_WORKOUT_TYPE, DEFAULT_WORKOUT_TYPE);
    AppStorage.setOrCreate<number>(STORAGE_STARTED_AT, Date.now());
    this.pushPage(PAGE_WORKOUT);
  }

  private openCallHome(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Index manual action CallHome');
    AppStorage.setOrCreate<string>(STORAGE_ACTION, ACTION_CALL_HOME);
    AppStorage.setOrCreate<string>(STORAGE_MESSAGE, MESSAGE_HOME_CONTACT_READY);
    AppStorage.setOrCreate<string>(STORAGE_CONTACT_LABEL, DEFAULT_CONTACT_LABEL);
    AppStorage.setOrCreate<number>(STORAGE_STARTED_AT, Date.now());
    this.pushPage(PAGE_CALL_HOME);
  }

  private openTimer(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Index manual action SetTimer');
    AppStorage.setOrCreate<string>(STORAGE_ACTION, ACTION_SET_TIMER);
    AppStorage.setOrCreate<string>(STORAGE_MESSAGE, MESSAGE_TIMER_STARTED);
    AppStorage.setOrCreate<number>(STORAGE_DURATION_MINUTES, DEFAULT_TIMER_MINUTES);
    AppStorage.setOrCreate<number>(STORAGE_STARTED_AT, Date.now());
    this.pushPage(PAGE_TIMER);
  }

  private pushPage(pagePath: string): void {
    try {
      this.pageStack.pushPathByName(pagePath, null);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Index navigation failed page=%{public}s cause=%{public}s',
        pagePath,
        JSON.stringify(err));
    }
  }
}
