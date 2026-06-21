import { configureStore } from '@reduxjs/toolkit';
import uiReducer from './slices/uiSlice';
import profileReducer from './slices/profileSlice';
import scanReducer from './slices/scanSlice';

export const store = configureStore({
  reducer: {
    ui: uiReducer,
    profile: profileReducer,
    scan : scanReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
