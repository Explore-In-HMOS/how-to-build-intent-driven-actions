import { hilog } from '@kit.PerformanceAnalysisKit';
import { DEFAULT_CONTACT_LABEL, MESSAGE_HOME_CONTACT_READY } from '../insightintents/IntentActionTypes';

const DOMAIN = 0x0000;
const TAG = 'IntentActions';

@Entry
@Component
export struct CallHomePage {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @StorageProp('intentMessage') message: string = MESSAGE_HOME_CONTACT_READY;
  @StorageProp('intentContactLabel') contactLabel: string = DEFAULT_CONTACT_LABEL;

  aboutToAppear(): void {
    hilog.info(DOMAIN, TAG, 'CallHomePage aboutToAppear message=%{public}s contactLabel=%{public}s',
      this.message,
      this.contactLabel);
  }

  build() {
    NavDestination() {
      Column({ space: 8 }) {
      Text($r('app.string.call_title'))
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.call_accent'))

      Text(this.contactLabel.toUpperCase())
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.watch_text_primary'))
        .maxLines(1)

      Text($r('app.string.state_ready'))
        .fontSize(17)
        .fontColor($r('app.color.watch_text_secondary'))

      Button($r('app.string.button_dismiss'))
        .width('58%')
        .height(36)
        .fontSize(14)
        .fontColor($r('app.color.button_text'))
        .backgroundColor($r('app.color.call_accent'))
        .onClick(() => {
          hilog.info(DOMAIN, TAG, 'CallHomePage dismiss clicked contactLabel=%{public}s', this.contactLabel);
          this.pageStack.pop();
        })
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ left: 28, right: 28, top: 24, bottom: 24 })
    .backgroundColor($r('app.color.call_surface'))
    }
    .hideTitleBar(true)
  }
}
