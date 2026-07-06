import { InsightIntentEntry, InsightIntentEntryExecutor, insightIntent } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  ACTION_CALL_HOME,
  DEFAULT_CONTACT_LABEL,
  MESSAGE_HOME_CONTACT_READY,
  WatchIntentResult
} from './IntentActionTypes';
import { openActionPage } from './IntentActionRouter';
import { failureResult, successResult } from './IntentResultFactory';

const DOMAIN = 0x0000;
const TAG = 'IntentActions';

@InsightIntentEntry({
  intentName: 'CallHome',
  domain: 'watch.actions',
  intentVersion: '1.0.0',
  displayName: 'Call home',
  displayDescription: 'Open the saved home contact action on the watch.',
  llmDescription: 'Shows a watch confirmation view for the saved home contact without placing a real call.',
  keywords: ['call', 'home', 'family', 'contact'],
  abilityName: 'EntryAbility',
  executeMode: [insightIntent.ExecuteMode.UI_ABILITY_FOREGROUND],
  parameters: {
    type: 'object',
    properties: {
      contactLabel: {
        type: 'string',
        description: 'Optional saved contact label. Defaults to home.'
      }
    },
    additionalProperties: false
  },
  result: {
    type: 'object',
    properties: {
      action: { type: 'string' },
      message: { type: 'string' },
      contactLabel: { type: 'string' }
    }
  }
})
export default class CallHomeIntentEntry extends InsightIntentEntryExecutor<WatchIntentResult> {
  contactLabel: string = DEFAULT_CONTACT_LABEL;

  async onExecute(): Promise<insightIntent.IntentResult<WatchIntentResult>> {
    const label: string = this.contactLabel.length > 0 ? this.contactLabel : DEFAULT_CONTACT_LABEL;
    hilog.info(DOMAIN, TAG, 'CallHome onExecute input contactLabel=%{public}s executeMode=%{public}d',
      label, this.executeMode);
    try {
      const result = await openActionPage(this.context, {
        action: ACTION_CALL_HOME,
        message: MESSAGE_HOME_CONTACT_READY,
        contactLabel: label,
        startedAt: Date.now()
      });
      const intentResult = successResult(result);
      hilog.info(DOMAIN, TAG, 'CallHome onExecute success code=%{public}d action=%{public}s ' +
        'message=%{public}s contactLabel=%{public}s',
        intentResult.code,
        result.action,
        result.message,
        result.contactLabel || '');
      return intentResult;
    } catch (err) {
      const message: string = `Home contact could not open: ${JSON.stringify(err)}`;
      hilog.error(DOMAIN, TAG, 'CallHome onExecute failure %{public}s', message);
      return failureResult(message);
    }
  }
}
