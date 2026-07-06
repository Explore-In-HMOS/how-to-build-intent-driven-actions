import { insightIntent } from '@kit.AbilityKit';
import { RESULT_ACTION_UNKNOWN, WatchIntentResult } from './IntentActionTypes';

export const RESULT_SUCCESS: number = 0;
export const RESULT_FAILURE: number = 1;

export function successResult(result: WatchIntentResult): insightIntent.IntentResult<WatchIntentResult> {
  return {
    code: RESULT_SUCCESS,
    result: result
  };
}

export function failureResult(message: string): insightIntent.IntentResult<WatchIntentResult> {
  return {
    code: RESULT_FAILURE,
    result: {
      action: RESULT_ACTION_UNKNOWN,
      message: message
    }
  };
}
