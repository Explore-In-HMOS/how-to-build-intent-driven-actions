import { hilog } from '@kit.PerformanceAnalysisKit';
import { DEFAULT_WORKOUT_TYPE, MESSAGE_WORKOUT_STARTED } from '../insightintents/IntentActionTypes';

const DOMAIN = 0x0000;
const TAG = 'IntentActions';

@Entry
@Component
export struct WorkoutPage {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @StorageProp('intentMessage') message: string = MESSAGE_WORKOUT_STARTED;
  @StorageProp('intentWorkoutType') workoutType: string = DEFAULT_WORKOUT_TYPE;
  @State elapsedSeconds: number = 0;
  private timerId: number = -1;

  aboutToAppear(): void {
    this.stopTimer();
    this.elapsedSeconds = 0;
    hilog.info(DOMAIN, TAG, 'WorkoutPage aboutToAppear message=%{public}s workoutType=%{public}s',
      this.message,
      this.workoutType);
    this.timerId = setInterval(() => {
      this.elapsedSeconds += 1;
    }, 1000);
  }

  aboutToDisappear(): void {
    hilog.info(DOMAIN, TAG, 'WorkoutPage aboutToDisappear elapsedSeconds=%{public}d', this.elapsedSeconds);
    this.stopTimer();
  }

  build() {
    NavDestination() {
      Column({ space: 8 }) {
      Text($r('app.string.workout_title'))
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.workout_accent'))

      Text(this.workoutType.toUpperCase())
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.watch_text_primary'))
        .maxLines(1)

      Text(this.timeLabel())
        .fontSize(42)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.watch_text_primary'))
        .fontFamily('HarmonyOS Sans Mono')

      Button($r('app.string.button_stop'))
        .width('54%')
        .height(36)
        .fontSize(14)
        .fontColor($r('app.color.button_text'))
        .backgroundColor($r('app.color.danger_accent'))
        .onClick(() => {
          hilog.info(DOMAIN, TAG, 'WorkoutPage stop clicked elapsedSeconds=%{public}d', this.elapsedSeconds);
          this.pageStack.pop();
        })
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ left: 28, right: 28, top: 24, bottom: 24 })
    .backgroundColor($r('app.color.workout_surface'))
    }
    .hideTitleBar(true)
  }

  private timeLabel(): string {
    const minutes: number = Math.floor(this.elapsedSeconds / 60);
    const seconds: number = this.elapsedSeconds % 60;
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
