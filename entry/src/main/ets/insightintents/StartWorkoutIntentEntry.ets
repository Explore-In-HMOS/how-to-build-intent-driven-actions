import { InsightIntentEntry, InsightIntentEntryExecutor, insightIntent } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  ACTION_START_WORKOUT,
  DEFAULT_WORKOUT_TYPE,
  MESSAGE_WORKOUT_STARTED,
  WatchIntentResult
} from './IntentActionTypes';
import { openActionPage } from './IntentActionRouter';
import { failureResult, successResult } from './IntentResultFactory';

const DOMAIN = 0x0000;
const TAG = 'IntentActions';

@InsightIntentEntry({
  intentName: 'StartWorkout',
  domain: 'watch.actions',
  intentVersion: '1.0.0',
  displayName: 'Start workout',
  displayDescription: 'Start a lightweight workout session on the watch.',
  llmDescription: 'Starts a simple watch workout timer and opens a compact workout status page.',
  keywords: ['workout', 'exercise', 'run', 'walk', 'cycle'],
  abilityName: 'EntryAbility',
  executeMode: [insightIntent.ExecuteMode.UI_ABILITY_FOREGROUND],
  parameters: {
    type: 'object',
    properties: {
      workoutType: {
        type: 'string',
        description: 'Optional workout type, such as run, walk, or cycle.'
      }
    },
    additionalProperties: false
  },
  result: {
    type: 'object',
    properties: {
      action: { type: 'string' },
      message: { type: 'string' },
      workoutType: { type: 'string' }
    }
  }
})
export default class StartWorkoutIntentEntry extends InsightIntentEntryExecutor<WatchIntentResult> {
  workoutType: string = DEFAULT_WORKOUT_TYPE;

  async onExecute(): Promise<insightIntent.IntentResult<WatchIntentResult>> {
    const type: string = this.workoutType.length > 0 ? this.workoutType : DEFAULT_WORKOUT_TYPE;
    hilog.info(DOMAIN, TAG, 'StartWorkout onExecute input workoutType=%{public}s executeMode=%{public}d',
      type, this.executeMode);
    try {
      const result = await openActionPage(this.context, {
        action: ACTION_START_WORKOUT,
        message: MESSAGE_WORKOUT_STARTED,
        workoutType: type,
        startedAt: Date.now()
      });
      const intentResult = successResult(result);
      hilog.info(DOMAIN, TAG, 'StartWorkout onExecute success code=%{public}d action=%{public}s ' +
        'message=%{public}s workoutType=%{public}s',
        intentResult.code,
        result.action,
        result.message,
        result.workoutType || '');
      return intentResult;
    } catch (err) {
      const message: string = `Workout could not start: ${JSON.stringify(err)}`;
      hilog.error(DOMAIN, TAG, 'StartWorkout onExecute failure %{public}s', message);
      return failureResult(message);
    }
  }
}
