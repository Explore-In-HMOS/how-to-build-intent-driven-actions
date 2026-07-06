import { InsightIntentContext, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  APP_BUNDLE_NAME,
  ENTRY_ABILITY_NAME,
  IntentLaunchParams,
  WatchIntentResult
} from './IntentActionTypes';

const DOMAIN = 0x0000;
const TAG = 'IntentActions';

export async function openActionPage(
  context: InsightIntentContext,
  params: IntentLaunchParams
): Promise<WatchIntentResult> {
  hilog.info(DOMAIN, TAG,
    'Router openActionPage input action=%{public}s message=%{public}s workoutType=%{public}s ' +
    'contactLabel=%{public}s durationMinutes=%{public}d startedAt=%{public}d',
    params.action,
    params.message,
    params.workoutType || '',
    params.contactLabel || '',
    params.durationMinutes || 0,
    params.startedAt);

  const want: Want = {
    bundleName: APP_BUNDLE_NAME,
    abilityName: ENTRY_ABILITY_NAME,
    uri: buildActionUri(params)
  };

  hilog.info(DOMAIN, TAG, 'Router startAbility bundle=%{public}s ability=%{public}s uri=%{public}s',
    APP_BUNDLE_NAME,
    ENTRY_ABILITY_NAME,
    want.uri || '');

  try {
    await context.startAbility(want);
  } catch (err) {
    const cause: string = JSON.stringify(err);
    hilog.error(DOMAIN, TAG, 'Router startAbility failed %{public}s', cause);
    throw new Error(cause);
  }

  const result: WatchIntentResult = {
    action: params.action,
    message: params.message,
    workoutType: params.workoutType,
    contactLabel: params.contactLabel,
    durationMinutes: params.durationMinutes
  };
  hilog.info(DOMAIN, TAG,
    'Router result action=%{public}s message=%{public}s workoutType=%{public}s ' +
    'contactLabel=%{public}s durationMinutes=%{public}d',
    result.action,
    result.message,
    result.workoutType || '',
    result.contactLabel || '',
    result.durationMinutes || 0);
  return result;
}

function buildActionUri(params: IntentLaunchParams): string {
  let uri: string = `intentaction://${params.action}?startedAt=${params.startedAt}`;
  if (params.workoutType) {
    uri += `&workoutType=${encodeURIComponent(params.workoutType)}`;
  }
  if (params.contactLabel) {
    uri += `&contactLabel=${encodeURIComponent(params.contactLabel)}`;
  }
  if (params.durationMinutes) {
    uri += `&durationMinutes=${params.durationMinutes}`;
  }
  return uri;
}
