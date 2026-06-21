import React, { useState } from "react";
import emailjs from "@emailjs/browser";

import { z } from "zod";
import { toast } from "react-hot-toast";

const formSchema = z.object({
  name: z.string().min(1, "Name is required").max(50, "Name is too long"),
  email: z.string().email("Invalid email address"),
  message: z
    .string()
    .min(1, "Message is required")
    .max(500, "Message is too long"),
});

const Form = () => {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    message: "",
  });

  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isLoading, setIsLoading] = useState(false);

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    setFormData({ ...formData, [e.target.id]: e.target.value });
    setErrors({ ...errors, [e.target.id]: "" });
  };

  // Review form state
  const [review, setReview] = useState({
    name: "",
    email: "",
    subject: "",
    message: "",
  });
  const [rating, setRating] = useState(5);
  const [reviewErrors, setReviewErrors] = useState<Record<string, string>>({});
  const [reviewLoading, setReviewLoading] = useState(false);

  const handleReviewChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setReview({ ...review, [e.target.id]: e.target.value });
    setReviewErrors({ ...reviewErrors, [e.target.id]: "" });
  };

  const validateReview = () => {
    const errs: Record<string, string> = {};
    if (!review.name.trim()) errs.name = "Name is required";
    if (!review.email || !/\S+@\S+\.\S+/.test(review.email)) errs.email = "Valid email is required";
    if (!review.subject.trim()) errs.subject = "Subject is required";
    if (!review.message.trim()) errs.message = "Message is required";
    setReviewErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleReviewSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateReview()) return;
    setReviewLoading(true);

    const payload = {
      reviewer_name: review.name,
      reviewer_email: review.email,
      subject: review.subject,
      message: review.message,
      rating: String(rating),
    };

    const serviceId = process.env.NEXT_PUBLIC_EMAILJS_SERVICE_ID;
    const templateId = process.env.NEXT_PUBLIC_EMAILJS_TEMPLATE_ID;
    const publicKey = process.env.NEXT_PUBLIC_EMAILJS_PUBLIC_KEY;

    if (!serviceId || !templateId || !publicKey) {
      toast.error("Email service is not configured.");
      setReviewLoading(false);
      return;
    }

    emailjs.send(serviceId, templateId, payload, publicKey).then(
      () => {
        toast.success("Review submitted — thank you!");
        setReview({ name: "", email: "", subject: "", message: "" });
        setRating(5);
        setReviewErrors({});
        setReviewLoading(false);
      },
      (err: any) => {
        console.error("Review submit failed", err);
        toast.error("Failed to submit review. Please try again later.");
        setReviewLoading(false);
      }
    );
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const validationResult = formSchema.safeParse(formData);

    setIsLoading(true);
    if (!validationResult.success) {
      const fieldErrors: Record<string, string> = {};
      validationResult.error.issues.forEach((error: z.ZodIssue) => {
        if (error.path[0]) {
          fieldErrors[error.path[0] as string] = error.message;
        }
      });
      setErrors(fieldErrors);
      setIsLoading(false);

      return;
    }

    const emailData = {
      name: formData.name,
      email: formData.email,
      message: formData.message,
    };

    const serviceId = process.env.NEXT_PUBLIC_EMAILJS_SERVICE_ID;
    const templateId = process.env.NEXT_PUBLIC_EMAILJS_TEMPLATE_ID;
    const publicKey = process.env.NEXT_PUBLIC_EMAILJS_PUBLIC_KEY;

    if (!serviceId || !templateId || !publicKey) {
      toast.error("Email service is not configured.");
      setIsLoading(false);
      return;
    }

    emailjs
      .send(serviceId, templateId, emailData, publicKey)
      .then(
        () => {
          toast.success("Message sent successfully!");

          setIsLoading(false);
          setFormData({ name: "", email: "", message: "" });
          setErrors({});
        },
        (error: any) => {
          console.error("Failed to send message:", error);
          toast.error("Failed to send message. Please try again later.");
          setIsLoading(false);
        }
      );
  };

 

  return (
    <>
      <section className="px-6 md:px-10 py-10 md:py-16">
        <h2 className="text-2xl md:text-3xl font-bold text-center mb-8 text-gray-300 dark:text-gray-100">
          Write a Review
        </h2>

        <form className="max-w-2xl mx-auto space-y-4" onSubmit={handleSubmit}>
          <div>
            <label htmlFor="name" className="sr-only">
              Name
            </label>
            <input
            
              id="name"
              type="text"
              placeholder="Name"
              value={formData.name}
              onChange={handleChange}
              aria-invalid={!!errors.name}
              className={`w-full p-3 rounded border transition-colors duration-150 bg-slate-50 dark:bg-gray-800 text-gray-300 placeholder-gray-500 ${
                errors.name ? "border-red-500" : "border-gray-300 dark:border-gray-700"
              }`}
            />
            {errors.name && (
              <p className="text-red-500 text-sm mt-2" role="alert">
                {errors.name}
              </p>
            )}
          </div>

          <div>
            <label htmlFor="email" className="sr-only">
              Email
            </label>
            <input
            
              id="email"
              type="email"
              placeholder="Email"
              value={formData.email}
              onChange={handleChange}
              aria-invalid={!!errors.email}
              className={`w-full p-3 rounded border transition-colors duration-150 bg-slate-50 dark:bg-gray-800 text-gray-300 placeholder-gray-500 ${
                errors.email ? "border-red-500" : "border-gray-300 dark:border-gray-700"
              }`}
            />
            {errors.email && (
              <p className="text-red-500 text-sm mt-2" role="alert">
                {errors.email}
              </p>
            )}
          </div>

          <div>
            <label htmlFor="message" className="sr-only">
              Message
            </label>
            <textarea
              id="message"
              rows={4}
              placeholder="Tell us something..."
              value={formData.message}
              onChange={handleChange}
              aria-invalid={!!errors.message}
              className={`w-full p-3 rounded border transition-colors duration-150 bg-slate-50 dark:bg-gray-800 text-gray-300 placeholder-gray-500 ${
                errors.message ? "border-red-500" : "border-gray-300 dark:border-gray-700"
              }`}
            />
            {errors.message && (
              <p className="text-red-500 text-sm mt-2" role="alert">
                {errors.message}
              </p>
            )}
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className={`px-6 py-3 bg-indigo-600 hover:bg-indigo-700 dark:bg-blue-600 dark:hover:bg-blue-700 rounded-lg w-full text-white font-bold transition-colors duration-150 flex items-center justify-center gap-2 ${
              isLoading ? "opacity-70 cursor-not-allowed" : ""
            }`}
          >
            {isLoading ? (
              <>
                <svg
                  aria-hidden="true"
                  role="status"
                  className="inline w-4 h-4 mr-2 text-white animate-spin"
                  viewBox="0 0 100 101"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
                    fill="#E5E7EB"
                  />
                  <path
                    d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
                    fill="currentColor"
                  />
                </svg>
                Sending...
              </>
            ) : (
              "Send"
            )}
          </button>
        </form>
      </section>

     

    </>
  );
};

export default Form;