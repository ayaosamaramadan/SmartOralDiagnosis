"use client";
import React, { useEffect, useState } from "react";
import { useAuth } from "@/contexts/AuthContext";
import { patientService, doctorService } from "@/services/api";
import { useRouter } from "next/navigation";

const Edit = () => {
  const { user, loading } = useAuth();
  const router = useRouter();

  const [form, setForm] = useState({
    firstName: "",
    lastName: "",
    email: "",
    phoneNumber: "",
    photo: "",
  });

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  useEffect(() => {
    if (user) {
      setForm({
        firstName: user.firstName ?? "",
        lastName: user.lastName ?? "",
        email: (user as any).email ?? "",
        phoneNumber: (user as any).phoneNumber ?? "",
        photo: (user as any).photo ?? "",
      });
    }
  }, [user]);

  if (loading) return <div className="p-4">Loading...</div>;
  if (!user) return <div className="p-4">Please sign in to edit your profile.</div>;

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setForm((s) => ({ ...s, [name]: value }));
  };

  const validate = () => {
    if (!form.firstName.trim() || !form.lastName.trim()) {
      setError("First name and last name are required.");
      return false;
    }
    const emailRe = /\S+@\S+\.\S+/;
    if (!emailRe.test(form.email)) {
      setError("Please enter a valid email address.");
      return false;
    }
    return true;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);
    if (!validate()) return;
    setIsSubmitting(true);

    try {
      const payload: any = {
        firstName: form.firstName.trim(),
        lastName: form.lastName.trim(),
        phoneNumber: form.phoneNumber?.trim() || null,
        photo: form.photo?.trim() || null,
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
        setSuccess("Profile updated successfully.");
        router.refresh();
      } else {
        setSuccess("Profile updated.");
      }
    } catch (err: any) {
      setError(err?.message ?? "Failed to update profile.");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="w-full max-h-full mt-4 p-6 bg-gradient-to-br from-primary-50 to-white dark:from-gray-900 dark:to-black">
      <div className="flex items-center justify-between mb-6">
      <div>
        <h1 className="text-2xl font-semibold bg-clip-text text-transparent bg-gradient-to-t from-primary-700 to-primary-500">Edit Profile</h1>
        <p className="text-sm text-gray-500">Update your personal information and profile photo</p>
      </div>
      </div>

      <div className="flex flex-col md:flex-row gap-6 min-h-[60vh] md:min-h-[66vh] overflow-auto">
      <aside className="md:w-1/3 card hover-glow md:h-auto">
        <div className="flex flex-col items-center text-center">
        <div className="relative">
          {form.photo || (user as any).photo ? (
          <img
            src={form.photo || (user as any).photo}
            alt="User avatar"
            className="h-32 w-32 rounded-full object-cover ring-6 ring-primary-100"
          />
          ) : (
          <div className="h-32 w-32 rounded-full bg-gradient-to-tr from-primary-700 to-primary-500 text-white flex items-center justify-center text-3xl font-semibold">
            {user.firstName?.[0]?.toUpperCase() ?? "U"}
          </div>
          )}
        </div>

        <div className="mt-4">
          <div className="font-medium text-lg">{user.firstName} {user.lastName}</div>
          <div className="text-sm text-gray-600">{(user as any).email}</div>
        </div>

        <div className="mt-5 flex flex-col gap-2 w-full">
          <button
          onClick={() => router.push('/profile')}
          className="btn-primary w-full"
          >
          Upload new photo
          </button>

          <button
          onClick={() => router.push('/')}
          className="btn-secondary w-full"
          >
          Back to dashboard
          </button>
        </div>

        <div className="w-full mt-6 bg-white dark:bg-gray-800 rounded-md p-4 text-left shadow-sm">
          <div className="flex items-center justify-between mb-3">
          <div>
            <h3 className="text-sm font-semibold">Complete your profile</h3>
            <p className="text-xs text-gray-500">Fill the sections below to complete your profile</p>
          </div>
          <div className="w-32">
            <div className="w-full h-2 bg-gray-200 rounded overflow-hidden">
            <div
              className="h-2 bg-primary-600 rounded"
              style={{
              width: `${Math.round(
                (([!!(form.firstName.trim() && form.lastName.trim()), !!(form.email.trim() && (form.phoneNumber?.trim() ?? "")), !!(form.photo || (user as any).photo)]
                .filter(Boolean).length) / 3) * 100
              )}%`,
              }}
            />
            </div>
          </div>
          </div>

          <ul className="flex flex-col gap-3">
          <li className="flex items-center justify-between">
            <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-primary-100 text-primary-700 flex items-center justify-center font-semibold">1</div>
            <div>
              <div className="text-sm font-medium">Personal info</div>
              <div className="text-xs text-gray-500">First & last name</div>
            </div>
            </div>
            { !!(form.firstName.trim() && form.lastName.trim()) ? (
            <span className="text-xs px-2 py-1 rounded bg-green-100 text-green-700">Complete</span>
            ) : (
            <span className="text-xs px-2 py-1 rounded bg-gray-100 text-gray-600">Incomplete</span>
            )}
          </li>

          <li className="flex items-center justify-between">
            <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-primary-100 text-primary-700 flex items-center justify-center font-semibold">2</div>
            <div>
              <div className="text-sm font-medium">Contact</div>
              <div className="text-xs text-gray-500">Email & phone</div>
            </div>
            </div>
            { !!(form.email.trim() && (form.phoneNumber?.trim() ?? "")) ? (
            <span className="text-xs px-2 py-1 rounded bg-green-100 text-green-700">Complete</span>
            ) : (
            <span className="text-xs px-2 py-1 rounded bg-gray-100 text-gray-600">Incomplete</span>
            )}
          </li>

          <li className="flex items-center justify-between">
            <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-primary-100 text-primary-700 flex items-center justify-center font-semibold">3</div>
            <div>
              <div className="text-sm font-medium">Profile photo</div>
              <div className="text-xs text-gray-500">Add a profile picture</div>
            </div>
            </div>
            { !!(form.photo || (user as any).photo) ? (
            <span className="text-xs px-2 py-1 rounded bg-green-100 text-green-700">Complete</span>
            ) : (
            <span className="text-xs px-2 py-1 rounded bg-gray-100 text-gray-600">Incomplete</span>
            )}
          </li>
          </ul>
        </div>
        </div>
      </aside>

      <section className="md:flex-1 card md:h-auto overflow-auto">
        <form onSubmit={handleSubmit} className="space-y-5">
        {error && (
          <div className="text-red-700 bg-red-100 p-2 rounded">{error}</div>
        )}
        {success && (
          <div className="text-green-700 bg-green-100 p-2 rounded">{success}</div>
        )}

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
          <label className="block text-sm font-medium mb-1">First name</label>
          <input
            name="firstName"
            value={form.firstName}
            onChange={handleChange}
            className="w-full border rounded p-2"
          />
          </div>

          <div>
          <label className="block text-sm font-medium mb-1">Last name</label>
          <input
            name="lastName"
            value={form.lastName}
            onChange={handleChange}
            className="w-full border rounded p-2"
          />
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">Email</label>
          <input
          name="email"
          value={form.email}
          onChange={handleChange}
          className="w-full border rounded p-2 "
          type="email"
          disabled
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">Phone number</label>
          <input
          name="phoneNumber"
          value={form.phoneNumber}
          onChange={handleChange}
          className="w-full border rounded p-2"
          />
        </div>


        <div className="flex items-center gap-3">
          <button
          type="submit"
          disabled={isSubmitting}
          className="btn-primary"
          >
          {isSubmitting ? "Saving..." : "Save changes"}
          </button>

          <button
          type="button"
          onClick={() => router.back()}
          className="btn-secondary"
          >
          Cancel
          </button>
        </div>
        </form>
      </section>
      </div>
    </div>
  );
};

export default Edit;