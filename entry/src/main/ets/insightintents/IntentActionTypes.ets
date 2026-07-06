export const APP_BUNDLE_NAME: string = 'com.hmosdemos.wearable.how_to_build_intent_driven_actions';
export const ENTRY_ABILITY_NAME: string = 'EntryAbility';

export const ACTION_START_WORKOUT: string = 'startWorkout';
export const ACTION_CALL_HOME: string = 'callHome';
export const ACTION_SET_TIMER: string = 'setTimer';

export const PAGE_INDEX: string = 'pages/Index';
export const PAGE_WORKOUT: string = 'pages/WorkoutPage';
export const PAGE_CALL_HOME: string = 'pages/CallHomePage';
export const PAGE_TIMER: string = 'pages/TimerPage';

export const DEFAULT_WORKOUT_TYPE: string = 'walk';
export const DEFAULT_CONTACT_LABEL: string = 'home';
export const DEFAULT_TIMER_MINUTES: number = 5;

export const MESSAGE_CHOOSE_ACTION: string = 'Choose an action';
export const MESSAGE_WORKOUT_STARTED: string = 'Workout started';
export const MESSAGE_HOME_CONTACT_READY: string = 'Home contact ready';
export const MESSAGE_TIMER_STARTED: string = 'Timer started';
export const MESSAGE_ACTION_READY: string = 'Action ready';
export const RESULT_ACTION_UNKNOWN: string = 'unknown';

export const STORAGE_ACTION: string = 'intentAction';
export const STORAGE_MESSAGE: string = 'intentMessage';
export const STORAGE_WORKOUT_TYPE: string = 'intentWorkoutType';
export const STORAGE_CONTACT_LABEL: string = 'intentContactLabel';
export const STORAGE_DURATION_MINUTES: string = 'intentDurationMinutes';
export const STORAGE_STARTED_AT: string = 'intentStartedAt';

export interface IntentLaunchParams {
  action: string;
  message: string;
  workoutType?: string;
  contactLabel?: string;
  durationMinutes?: number;
  startedAt: number;
}

export interface WatchIntentResult {
  action: string;
  message: string;
  workoutType?: string;
  contactLabel?: string;
  durationMinutes?: number;
}
