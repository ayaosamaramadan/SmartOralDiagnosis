import { configureStore } from '@reduxjs/toolkit';
import uiReducer from './slices/uiSlice';
import profileReducer from './slices/profileSlice';


export const store = configureStore({
  reducer: {
    ui: uiReducer,
    profile: profileReducer,
    // camera: cameraReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
