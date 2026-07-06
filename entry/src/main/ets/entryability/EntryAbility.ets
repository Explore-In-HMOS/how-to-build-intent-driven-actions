import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import {
  ACTION_CALL_HOME,
  ACTION_SET_TIMER,
  ACTION_START_WORKOUT,
  DEFAULT_CONTACT_LABEL,
  DEFAULT_TIMER_MINUTES,
  DEFAULT_WORKOUT_TYPE,
  MESSAGE_ACTION_READY,
  MESSAGE_CHOOSE_ACTION,
  MESSAGE_HOME_CONTACT_READY,
  MESSAGE_TIMER_STARTED,
  MESSAGE_WORKOUT_STARTED,
  PAGE_INDEX,
  STORAGE_ACTION,
  STORAGE_CONTACT_LABEL,
  STORAGE_DURATION_MINUTES,
  STORAGE_MESSAGE,
  STORAGE_STARTED_AT,
  STORAGE_WORKOUT_TYPE
} from '../insightintents/IntentActionTypes';
import '../insightintents/CallHomeIntentEntry';
import '../insightintents/SetTimerIntentEntry';
import '../insightintents/StartWorkoutIntentEntry';

const DOMAIN = 0x0000;
const TAG = 'IntentActions';

export default class EntryAbility extends UIAbility {
  private latestWant?: Want;
  private windowStage?: window.WindowStage;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.latestWant = want;
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, TAG, 'Ability onCreate uri=%{public}s parameters=%{public}s',
      want.uri || '',
      JSON.stringify(want.parameters || {}));
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onDestroy');
    this.latestWant = undefined;
    this.windowStage = undefined;
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'Ability onNewWant uri=%{public}s parameters=%{public}s',
      want.uri || '',
      JSON.stringify(want.parameters || {}));
    this.latestWant = want;
    this.saveIntentState(want);
    if (this.windowStage) {
      this.loadActionContent(this.windowStage, PAGE_INDEX);
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageCreate');
    this.windowStage = windowStage;
    if (this.latestWant) {
      this.saveIntentState(this.latestWant);
    } else {
      this.saveDefaults();
    }

    this.loadActionContent(windowStage, PAGE_INDEX);
  }

  private loadActionContent(windowStage: window.WindowStage, pagePath: string): void {
    hilog.info(DOMAIN, TAG, 'Ability loadActionContent page=%{public}s action=%{public}s',
      pagePath,
      AppStorage.get<string>(STORAGE_ACTION) || '');
    windowStage.loadContent(pagePath, (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in loading %{public}s.', pagePath);
    });
  }

  private saveIntentState(want: Want): void {
    const params: Record<string, Object> | undefined = want.parameters;
    const uri: string = want.uri || '';
    const action: string = this.stringParam(params, 'action', this.actionFromUri(uri));
    hilog.info(DOMAIN, TAG, 'Ability saveIntentState raw uri=%{public}s resolvedAction=%{public}s',
      uri,
      action);
    if (action.length === 0) {
      this.saveDefaults();
      return;
    }

    const message: string = this.messageForAction(action);
    const workoutType: string =
      this.stringParam(params, 'workoutType', this.queryParam(uri, 'workoutType', DEFAULT_WORKOUT_TYPE));
    const contactLabel: string =
      this.stringParam(params, 'contactLabel', this.queryParam(uri, 'contactLabel', DEFAULT_CONTACT_LABEL));
    const durationMinutes: number =
      this.numberParam(params, 'durationMinutes', this.numberQueryParam(uri, 'durationMinutes', DEFAULT_TIMER_MINUTES));
    const startedAt: number =
      this.numberParam(params, 'startedAt', this.numberQueryParam(uri, 'startedAt', Date.now()));

    AppStorage.setOrCreate<string>(STORAGE_ACTION, action);
    AppStorage.setOrCreate<string>(STORAGE_MESSAGE, message);
    AppStorage.setOrCreate<string>(STORAGE_WORKOUT_TYPE, workoutType);
    AppStorage.setOrCreate<string>(STORAGE_CONTACT_LABEL, contactLabel);
    AppStorage.setOrCreate<number>(STORAGE_DURATION_MINUTES, durationMinutes);
    AppStorage.setOrCreate<number>(STORAGE_STARTED_AT, startedAt);

    hilog.info(DOMAIN, TAG,
      'Ability stored action=%{public}s message=%{public}s workoutType=%{public}s ' +
      'contactLabel=%{public}s durationMinutes=%{public}d startedAt=%{public}d',
      action,
      message,
      workoutType,
      contactLabel,
      durationMinutes,
      startedAt);
  }

  private saveDefaults(): void {
    AppStorage.setOrCreate<string>(STORAGE_ACTION, '');
    AppStorage.setOrCreate<string>(STORAGE_MESSAGE, MESSAGE_CHOOSE_ACTION);
    AppStorage.setOrCreate<string>(STORAGE_WORKOUT_TYPE, DEFAULT_WORKOUT_TYPE);
    AppStorage.setOrCreate<string>(STORAGE_CONTACT_LABEL, DEFAULT_CONTACT_LABEL);
    AppStorage.setOrCreate<number>(STORAGE_DURATION_MINUTES, DEFAULT_TIMER_MINUTES);
    AppStorage.setOrCreate<number>(STORAGE_STARTED_AT, Date.now());
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability stored defaults');
  }

  private messageForAction(action: string): string {
    if (action === ACTION_START_WORKOUT) {
      return MESSAGE_WORKOUT_STARTED;
    }
    if (action === ACTION_CALL_HOME) {
      return MESSAGE_HOME_CONTACT_READY;
    }
    if (action === ACTION_SET_TIMER) {
      return MESSAGE_TIMER_STARTED;
    }
    return MESSAGE_ACTION_READY;
  }

  private stringParam(params: Record<string, Object> | undefined, key: string, fallback: string): string {
    const value = params ? params[key] : undefined;
    return typeof value === 'string' && value.length > 0 ? value : fallback;
  }

  private numberParam(params: Record<string, Object> | undefined, key: string, fallback: number): number {
    const value = params ? params[key] : undefined;
    return typeof value === 'number' && value > 0 ? value : fallback;
  }

  private actionFromUri(uri: string): string {
    const prefix: string = 'intentaction://';
    if (!uri.startsWith(prefix)) {
      return '';
    }
    const tail: string = uri.substring(prefix.length);
    const queryIndex: number = tail.indexOf('?');
    return queryIndex >= 0 ? tail.substring(0, queryIndex) : tail;
  }

  private queryParam(uri: string, key: string, fallback: string): string {
    const marker: string = `${key}=`;
    const startIndex: number = uri.indexOf(marker);
    if (startIndex < 0) {
      return fallback;
    }
    const valueStart: number = startIndex + marker.length;
    const endIndex: number = uri.indexOf('&', valueStart);
    const value: string = endIndex >= 0 ? uri.substring(valueStart, endIndex) : uri.substring(valueStart);
    return value.length > 0 ? decodeURIComponent(value) : fallback;
  }

  private numberQueryParam(uri: string, key: string, fallback: number): number {
    const value: number = Number(this.queryParam(uri, key, `${fallback}`));
    return value > 0 ? value : fallback;
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageDestroy');
    this.windowStage = undefined;
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onBackground');
  }
}
