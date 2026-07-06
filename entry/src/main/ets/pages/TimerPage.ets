import { hilog } from '@kit.PerformanceAnalysisKit';
import { DEFAULT_TIMER_MINUTES, MESSAGE_TIMER_STARTED } from '../insightintents/IntentActionTypes';

const DOMAIN = 0x0000;
const TAG = 'IntentActions';

@Entry
@Component
export struct TimerPage {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @StorageProp('intentMessage') message: string = MESSAGE_TIMER_STARTED;
  @StorageProp('intentDurationMinutes') durationMinutes: number = DEFAULT_TIMER_MINUTES;
  @State remainingSeconds: number = 300;
  private timerId: number = -1;

  aboutToAppear(): void {
    this.stopTimer();
    this.remainingSeconds = Math.max(1, Math.floor(this.durationMinutes * 60));
    hilog.info(DOMAIN, TAG,
      'TimerPage aboutToAppear message=%{public}s durationMinutes=%{public}d remainingSeconds=%{public}d',
      this.message,
      this.durationMinutes,
      this.remainingSeconds);
    this.timerId = setInterval(() => {
      if (this.remainingSeconds > 0) {
        this.remainingSeconds -= 1;
      }
      if (this.remainingSeconds === 0) {
        this.stopTimer();
      }
    }, 1000);
  }

  aboutToDisappear(): void {
    hilog.info(DOMAIN, TAG, 'TimerPage aboutToDisappear remainingSeconds=%{public}d', this.remainingSeconds);
    this.stopTimer();
  }

  build() {
    NavDestination() {
      Column({ space: 8 }) {
      Text($r('app.string.timer_title'))
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.timer_accent'))

      Row({ space: 4 }) {
        Text(`${this.durationMinutes}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.watch_text_primary'))
        Text($r('app.string.timer_minutes_suffix'))
          .fontSize(13)
          .fontColor($r('app.color.watch_text_secondary'))
      }
      .justifyContent(FlexAlign.Center)

      Text(this.timeLabel())
        .fontSize(42)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.watch_text_primary'))
        .fontFamily('HarmonyOS Sans Mono')

      Button($r('app.string.button_cancel'))
        .width('54%')
        .height(36)
        .fontSize(14)
        .fontColor($r('app.color.button_text'))
        .backgroundColor($r('app.color.timer_accent'))
        .onClick(() => {
          hilog.info(DOMAIN, TAG, 'TimerPage cancel clicked remainingSeconds=%{public}d', this.remainingSeconds);
          this.pageStack.pop();
        })
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ left: 28, right: 28, top: 24, bottom: 24 })
    .backgroundColor($r('app.color.timer_surface'))
    }
    .hideTitleBar(true)
  }

  private timeLabel(): string {
    const minutes: number = Math.floor(this.remainingSeconds / 60);
    const seconds: number = this.remainingSeconds % 60;
    return `${this.twoDigits(minutes)}:${this.twoDigits(seconds)}`;
  }

  private twoDigits(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  private stopTimer(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }
}
