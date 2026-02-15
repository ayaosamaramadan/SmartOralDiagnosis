"use client";
import React, { useEffect, useRef, useState } from "react";

import { patientService, doctorService, uploadService } from "@/services/api";
import { useRouter } from "next/navigation";
import { FaRegFilePdf } from "react-icons/fa6";

import DetectLocation from "./DetectLocation";
import { useAppSelector, useAppDispatch } from "../../store/hooks";
import {
  setForm as setProfileForm,
  updateField,
  setIsSubmitting as setProfileIsSubmitting,

} from "../../store/slices/profileSlice";
import toast from "react-hot-toast";
import Loading from "@/auth/loading";

import CompletedOr from "./CompletedOr";
import Langu from "./Langu";

import { useAuth } from "../../contexts/AuthContext";

const Edit = () => {
  const { loading ,user} = useAuth();
  const router = useRouter();

  const dispatch = useAppDispatch();
  const form = useAppSelector((s: any) => s.profile.form);
  const isSubmitting = useAppSelector((s: any) => s.profile.isSubmitting);
  const error = useAppSelector((s: any) => s.profile.error);
  const success = useAppSelector((s: any) => s.profile.success);
  const [isUploadingPhoto, setIsUploadingPhoto] = useState(false);
  const fileInputRef = useRef<HTMLInputElement | null>(null);

 

  useEffect(() => {
    if (user) {
      dispatch(
        setProfileForm({
          firstName: user.firstName ?? "",
          lastName: user.lastName ?? "",
          email: (user as any).email ?? "",
          phoneNumber: (user as any).phoneNumber ?? "",
          photo: (user as any).photo ?? "",
            location: (user as any).location ?? "",
            dateOfBirth: (user as any).dateOfBirth ?? (user as any).DateOfBirth ?? (user as any).birthday ?? "",
        })
      );
    }
  }, [user, dispatch]);

  if (loading) return <Loading />;
  if (!user) return <div className="p-4">Please sign in to edit your profile.</div>;

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    dispatch(updateField({ name: name as any, value }));
  };

  const handleFieldBlur = async (e: React.FocusEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.currentTarget as HTMLInputElement;
    if (!user) return;
    // simple client-side validation for email
    if (name === "email") {
      const emailRe = /\S+@\S+\.\S+/;
      if (value && !emailRe.test(value)) {
        toast.error("Please enter a valid email address.");
        return;
      }
    }
    try {
      // avoid unnecessary requests
      if ((user as any)[name] === value) return;
      dispatch(setProfileIsSubmitting(true));

      const payload: any = { [name]: value?.trim() || null };
      let updated: any = null;
      if (user.role && String(user.role).toLowerCase() === "patient") {
        updated = await patientService.update(user.id, payload);
      } else {
        updated = await doctorService.update(user.id, payload);
      }

      if (updated) {
        const toStore = {
          ...user,
          [name]: updated[name] ?? payload[name],
        };
        localStorage.setItem("user", JSON.stringify(toStore));
        // keep redux form in sync with saved value
        dispatch(updateField({ name: name as any, value: (toStore as any)[name] }));
        toast.success("Saved");
        router.refresh();
      } else {
        toast.success("Saved");
      }
    } catch (err: any) {
      toast.error(err?.message ?? "Failed to save field.");
    } finally {
      dispatch(setProfileIsSubmitting(false));
    }
  };

  const handlePhotoButtonClick = () => {
    fileInputRef.current?.click();
  };

  const persistPhotoUpdate = async (photoUrl: string) => {
    if (!user) return photoUrl;

    const payload: any = { photo: photoUrl };
    dispatch(setProfileIsSubmitting(true));

    try {
      let updated: any = null;
      const role = String(user.role ?? "").toLowerCase();
      if (role === "patient") {
        updated = await patientService.update(user.id, payload);
      } else {
        updated = await doctorService.update(user.id, payload);
      }

      const storedPhoto = updated?.photo ?? photoUrl;
      const toStore = {
        ...user,
        photo: storedPhoto,
      };
      localStorage.setItem("user", JSON.stringify(toStore));
      router.refresh();
      return storedPhoto;
    } finally {
      dispatch(setProfileIsSubmitting(false));
    }
  };

  const handlePhotoSelected = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const toastId = toast.loading("Uploading photo...");
    setIsUploadingPhoto(true);
    const previousPhoto = form.photo;

    try {
      const uploadResult = await uploadService.uploadProfilePhoto(file, user?.id);
      const newPhotoUrl = uploadResult?.photoUrl ?? uploadResult?.filePath;
      if (!newPhotoUrl) {
        throw new Error("Upload did not return a photo URL.");
      }

      dispatch(updateField({ name: "photo", value: newPhotoUrl }));
      const persisted = await persistPhotoUpdate(newPhotoUrl);
      if (persisted) {
        dispatch(updateField({ name: "photo", value: persisted }));
      }
      toast.success("Profile photo updated.", { id: toastId });
    } catch (err: any) {
      dispatch(updateField({ name: "photo", value: previousPhoto ?? "" }));
      toast.error(err?.message ?? "Failed to upload photo.", { id: toastId });
    } finally {
      setIsUploadingPhoto(false);
      e.target.value = "";
    }
  };

  const validate = () => {
    if (!form.firstName.trim() || !form.lastName.trim()) {
      toast.error("First name and last name are required.");

      return false;
    }
    const emailRe = /\S+@\S+\.\S+/;
    if (!emailRe.test(form.email)) {
      toast.error("Please enter a valid email address.");
      return false;
    }
    return true;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    toast.dismiss();
    if (!validate()) return;
    dispatch(setProfileIsSubmitting(true));

    try {
      const payload: any = {
        firstName: form.firstName.trim(),
        lastName: form.lastName.trim(),
        phoneNumber: form.phoneNumber?.trim() || null,
          photo: form.photo?.trim() || null,
          dateOfBirth: form.dateOfBirth?.trim() || null,
      };

      let updated: any = null;
      if (user.role && String(user.role).toLowerCase() === "patient") {
        updated = await patientService.update(user.id, payload);
      } else {
        updated = await doctorService.update(user.id, payload);
      }

      if (updated) {
        const toStore = {
          ...user,
          firstName: updated.firstName ?? payload.firstName,
          lastName: updated.lastName ?? payload.lastName,
          phoneNumber: updated.phoneNumber ?? payload.phoneNumber,
          photo: updated.photo ?? payload.photo ?? form.photo,
          email: updated.email ?? form.email,
        };
        localStorage.setItem("user", JSON.stringify(toStore));
        toast.success("Profile updated successfully.");
        router.refresh();
      } else {
        toast.success("Profile updated.");
      }
    } catch (err: any) {
      toast.error(err?.message ?? "Failed to update profile.");
    } finally {
      dispatch(setProfileIsSubmitting(false));
    }
  };

  return (
    <div className="w-3/3 max-h-full p-6">
      <div className="mx-auto">


        <div className="flex flex-col md:flex-row gap-7 min-h-[60vh] md:min-h-[66vh] overflow-auto">

          <div className="flex flex-col gap-6 md:w-2/3">

            <div className="relative md:dark:bg-gradient-to-l md:dark:from-[rgb(31,31,31)] md:dark:via-[rgb(49,49,49)] md:dark:to-[rgb(31,31,31)] bg-white w-full border border-gray-200 dark:border-gray-700 rounded-lg shadow-sm p-6">

              <div className="absolute top-4 right-4">
                <Langu />
              </div>

              <div className="flex items-center text-left">
                <div className="relative">
                  {form.photo || (user as any).photo ? (
                    <img
                      src={form.photo || (user as any).photo}
                      alt="User avatar"
                      className="h-32 w-32 rounded-full object-cover ring-4 ring-gray-100 shadow-md"
                      loading="lazy"
                    />
                  ) : (
                    <div className=" mr-7 h-32 w-32 rounded-full bg-gradient-to-tr from-blue-700 to-blue-500 text-white flex items-center justify-center text-3xl font-semibold shadow-md">
                      {user.firstName?.[0]?.toUpperCase() ?? "U"}
                    </div>
                  )}
                </div>


                <div>
                  <div className="mt-4 ml-10">
                    <div className="font-medium text-lg text-gray-900 dark:text-gray-100">{user.firstName} {user.lastName}</div>
                    <div className="text-sm text-gray-600 dark:text-gray-400">{(user as any).email}</div>
                  </div>

                  <div className="mt-5 ml-10 flex gap-2 w-full">
                    <input
                      type="file"
                      accept="image/*"
                      ref={fileInputRef}
                      onChange={handlePhotoSelected}
                      className="hidden"
                    />
                    <button
                      type="button"
                      onClick={handlePhotoButtonClick}
                      disabled={isUploadingPhoto}
                      className="inline-flex items-center justify-center gap-2 px-4 py-2 rounded-md bg-blue-600 hover:bg-blue-700 text-white font-medium transition-shadow shadow-sm disabled:opacity-60"
                    >
                      {isUploadingPhoto ? "Uploading..." : "Upload new photo"}
                    </button>    
                 { String(user?.role ?? "").toLowerCase() === "doctor" && (
                    <button
        
                      className="inline-flex items-center justify-center gap-2 px-4 py-2 rounded-md bg-red-800 hover:bg-red-700 text-white font-medium transition-shadow shadow-sm"
                    >
                    <FaRegFilePdf />  Medical License (Required)
                    </button>
                 )}
                  </div>
                </div>
              </div>
            </div>

            <section className="md:dark:bg-gradient-to-l md:dark:from-[rgb(31,31,31)] md:dark:via-[rgb(49,49,49)] md:dark:to-[rgb(31,31,31)] bg-white w-full border border-gray-200 dark:border-gray-700 rounded-lg shadow-sm p-6 overflow-auto">
              <form onSubmit={handleSubmit} className="space-y-5">
                {error && (
                  <div className="text-red-800 bg-red-50 border border-red-200 dark:text-red-200 dark:bg-red-900/20 dark:border-red-700 p-2 rounded">{error}</div>
                )}
                {success && (
                  <div className="text-green-800 bg-green-50 border border-green-200 dark:text-green-200 dark:bg-green-900/15 dark:border-green-700 p-2 rounded">{success}</div>
                )}

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-1 text-gray-900 dark:text-gray-200">First name</label>
                    <input
                      name="firstName"
                      value={form.firstName}
                      onChange={handleChange}
                      onBlur={handleFieldBlur}
                      className="w-full border border-gray-300 dark:border-gray-700 rounded-md p-2 bg-white dark:bg-transparent text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-300 transition"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium mb-1 text-gray-900 dark:text-gray-200">Last name</label>
                    <input
                      name="lastName"
                      value={form.lastName}
                      onChange={handleChange}
                      onBlur={handleFieldBlur}
                      className="w-full border border-gray-300 dark:border-gray-700 rounded-md p-2 bg-white dark:bg-transparent text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-300 transition"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-1 text-gray-900 dark:text-gray-200">Email</label>
                  <input
                      name="email"
                      value={form.email}
                      onChange={handleChange}
                      onBlur={handleFieldBlur}
                      className="w-full border border-gray-300 dark:border-gray-700 rounded-md p-2 bg-white dark:bg-transparent text-gray-700 dark:text-gray-400"
                      type="email"
                    />
                </div>

                <div>
                  <label className="block text-sm font-medium mb-1 text-gray-900 dark:text-gray-200">Phone number</label>
                    <input
                      name="phoneNumber"
                      value={form.phoneNumber}
                      onChange={handleChange}
                      onBlur={handleFieldBlur}
                      className="w-full border border-gray-300 dark:border-gray-700 rounded-md p-2 bg-white dark:bg-transparent text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-300 transition"
                    />
                </div>

                <div>
                  <label className="block text-sm font-medium mb-1 text-gray-900 dark:text-gray-200">Birth date</label>
                  <input
                    name="dateOfBirth"
                    type="date"
                    value={(form as any).dateOfBirth ?? ""}
                    onChange={handleChange}
                    onBlur={handleFieldBlur}
                    max={new Date().toISOString().split("T")[0]}
                    className="w-full border border-gray-300 dark:border-gray-700 rounded-md p-2 bg-white dark:bg-transparent text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-300 transition"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium mb-1 text-gray-900 dark:text-gray-200">Location</label>
                  <div className="flex gap-2 items-center">
                    <input
                      name="location"
                      value={(form as any).location ?? ""}
                      onChange={handleChange}
                      onBlur={handleFieldBlur}
                      placeholder="City, State or coordinates"
                      className="flex-1 border border-gray-300 dark:border-gray-700 rounded-md p-2 bg-white dark:bg-transparent text-gray-900 dark:text-gray-100 placeholder:text-gray-500 dark:placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-gray-300 transition"
                    />
                    <div className="shrink-0">
                      <DetectLocation />
                    </div>
                  </div>

                  {(form as any).location ? (
                    <div className="text-xs text-gray-400 mt-2">Current: {(form as any).location}</div>
                  ) : null}
                </div>

                <div className="flex items-center gap-3">
                  <button
                    type="submit"
                    disabled={isSubmitting || isUploadingPhoto}
                    className="inline-flex items-center px-4 py-2 rounded-md bg-blue-600 hover:bg-blue-700 text-white font-semibold transition disabled:opacity-60"
                  >
                    {isSubmitting ? "Saving..." : "Save changes"}
                  </button>

                  <button
                    type="button"
                    onClick={() => router.back()}
                    className="inline-flex items-center px-4 py-2 rounded-md border border-gray-300 dark:border-gray-700 bg-white dark:bg-transparent text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-800/40 transition"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </section>
          </div>

          <div className="flex-1 md:w-2/3 md:dark:bg-gradient-to-l md:dark:from-[rgb(31,31,31)] md:dark:via-[rgb(32,32,32)] md:dark:to-[rgb(31,31,31)] bg-white">
            <div className="w-full h-full border border-gray-200 dark:border-gray-700 rounded-lg shadow-sm p-6 bg-white md:dark:bg-gradient-to-l md:dark:from-[rgb(31,31,31)] md:dark:via-[rgb(49,49,49)] md:dark:to-[rgb(31,31,31)]">
              <CompletedOr form={form} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Edit;