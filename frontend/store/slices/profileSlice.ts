import { createSlice, PayloadAction } from "@reduxjs/toolkit";

interface ProfileForm {
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber: string;
  photo: string;
  location?: string;
}

interface ProfileState {
  form: ProfileForm;
  isSubmitting: boolean;
  error: string | null;
  success: string | null;
}

const initialState: ProfileState = {
  form: {
    firstName: "",
    lastName: "",
    email: "",
    phoneNumber: "",
    photo: "",
    location: "",
  },
  isSubmitting: false,
  error: null,
  success: null,
};

const profileSlice = createSlice({
  name: "profile",
  initialState,
  reducers: {
    setForm(state, action: PayloadAction<Partial<ProfileForm>>) {
      state.form = { ...state.form, ...action.payload };
    },
    updateField(state, action: PayloadAction<{ name: keyof ProfileForm; value: string }>) {
      const { name, value } = action.payload;
      state.form[name] = value;
    },
    setIsSubmitting(state, action: PayloadAction<boolean>) {
      state.isSubmitting = action.payload;
    },
    setError(state, action: PayloadAction<string | null>) {
      state.error = action.payload;
    },
    setSuccess(state, action: PayloadAction<string | null>) {
      state.success = action.payload;
    },
    reset(state) {
      state.form = initialState.form;
      state.isSubmitting = false;
      state.error = null;
      state.success = null;
    },
  },
});

export const { setForm, updateField, setIsSubmitting, setError, setSuccess, reset } = profileSlice.actions;

export default profileSlice.reducer;