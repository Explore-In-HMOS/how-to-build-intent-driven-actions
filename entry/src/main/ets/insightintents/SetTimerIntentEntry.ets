import { InsightIntentEntry, InsightIntentEntryExecutor, insightIntent } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  ACTION_SET_TIMER,
  DEFAULT_TIMER_MINUTES,
  MESSAGE_TIMER_STARTED,
  WatchIntentResult
} from './IntentActionTypes';
import { openActionPage } from './IntentActionRouter';
import { failureResult, successResult } from './IntentResultFactory';

const DOMAIN = 0x0000;
const TAG = 'IntentActions';

@InsightIntentEntry({
  intentName: 'SetTimer',
  domain: 'watch.actions',
  intentVersion: '1.0.0',
  displayName: 'Set timer',
  displayDescription: 'Start a short watch timer from an intent duration.',
  llmDescription: 'Starts a compact timer page using the provided duration in minutes.',
  keywords: ['timer', 'countdown', 'minutes', 'alarm'],
  abilityName: 'EntryAbility',
  executeMode: [insightIntent.ExecuteMode.UI_ABILITY_FOREGROUND],
  parameters: {
    type: 'object',
    properties: {
      durationMinutes: {
        type: 'number',
        description: 'Required timer duration in minutes.'
      }
    },
    required: ['durationMinutes'],
    additionalProperties: false
  },
  result: {
    type: 'object',
    properties: {
      action: { type: 'string' },
      message: { type: 'string' },
      durationMinutes: { type: 'number' }
    }
  }
})
export default class SetTimerIntentEntry extends InsightIntentEntryExecutor<WatchIntentResult> {
  durationMinutes: number = DEFAULT_TIMER_MINUTES;

  async onExecute(): Promise<insightIntent.IntentResult<WatchIntentResult>> {
    const minutes: number = this.durationMinutes > 0 ? this.durationMinutes : DEFAULT_TIMER_MINUTES;
    hilog.info(DOMAIN, TAG, 'SetTimer onExecute input durationMinutes=%{public}d executeMode=%{public}d',
      minutes, this.executeMode);
    try {
      const result = await openActionPage(this.context, {
        action: ACTION_SET_TIMER,
        message: MESSAGE_TIMER_STARTED,
        durationMinutes: minutes,
        startedAt: Date.now()
      });
      const intentResult = successResult(result);
      hilog.info(DOMAIN, TAG, 'SetTimer onExecute success code=%{public}d action=%{public}s ' +
        'message=%{public}s durationMinutes=%{public}d',
        intentResult.code,
        result.action,
        result.message,
        result.durationMinutes || 0);
      return intentResult;
    } catch (err) {
      const message: string = `Timer could not start: ${JSON.stringify(err)}`;
      hilog.error(DOMAIN, TAG, 'SetTimer onExecute failure %{public}s', message);
      return failureResult(message);
    }
  }
}
