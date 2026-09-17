// Browser Supabase client, used for guest lookup and RSVP submission.
// Only the public anon key is used here — all sensitive access is enforced
// server-side via RLS + SECURITY DEFINER RPC functions (see supabase/schema.sql).
import { createClient } from "@supabase/supabase-js";
import {
  PUBLIC_SUPABASE_URL,
  PUBLIC_SUPABASE_ANON_KEY,
} from "$env/static/public";

export const supabase = createClient(
  PUBLIC_SUPABASE_URL,
  PUBLIC_SUPABASE_ANON_KEY,
);

export interface GuestRecord {
  id: string;
  first_name: string;
  last_name: string;
  email: string | null;
  phone: string | null;
  whatsapp_number: string | null;
  guest_code: string;
  guest_type: string;
  plus_one_allowed: boolean;
  rsvp_status: string;
  dietary_notes: string | null;
  invite_sent_at: string | null;
}

export interface RsvpRecord {
  id: string;
  guest_id: string;
  attending: boolean;
  guest_count: number;
  plus_one_name: string | null;
  dietary_requirements: string | null;
  song_request: string | null;
  notes: string | null;
  submitted_at: string;
  guests: {
    first_name: string;
    last_name: string;
    guest_type: string;
  } | null;
}

export interface GalleryPhoto {
  id: string;
  storage_path: string;
  caption: string | null;
  sort_order: number;
  created_at: string;
  url: string;
}

export interface GuestPhoto {
  id: string;
  storage_path: string;
  uploader_name: string | null;
  caption: string | null;
  approved: boolean;
  created_at: string;
  url: string;
}

export interface GuestbookComment {
  id: string;
  display_name: string;
  message: string;
  created_at: string;
}

export interface GuestLookupResult {
  id: string;
  first_name: string;
  last_name: string;
  guest_type: string;
  plus_one_allowed: boolean;
  rsvp_status: string;
  dietary_notes: string | null;
}

export async function findGuestByCode(
  code: string,
): Promise<GuestLookupResult | null> {
  const { data, error } = await supabase.rpc("find_guest_by_code", {
    p_code: code,
  });

  if (error) {
    console.error("find_guest_by_code error", error);
    throw new Error(
      "Something went wrong looking up your invitation. Please try again.",
    );
  }

  return data?.[0] ?? null;
}

export interface RsvpSubmission {
  guestCode: string;
  attending: boolean;
  guestCount: number;
  plusOneName: string;
  dietaryRequirements: string;
  songRequest: string;
  notes: string;
}

export async function submitRsvp(submission: RsvpSubmission): Promise<void> {
  const { data, error } = await supabase.rpc("submit_rsvp", {
    p_guest_code: submission.guestCode,
    p_attending: submission.attending,
    p_guest_count: submission.guestCount,
    p_plus_one_name: submission.plusOneName || null,
    p_dietary_requirements: submission.dietaryRequirements || null,
    p_song_request: submission.songRequest || null,
    p_notes: submission.notes || null,
  });

  if (error) {
    console.error("submit_rsvp error", error);
    throw new Error(
      "Something went wrong submitting your RSVP. Please try again.",
    );
  }

  const result = data?.[0];
  if (!result?.success) {
    throw new Error(
      result?.message ?? "We could not find that invitation code.",
    );
  }
}

// ---------------------------------------------------------------------------
// Pre-wedding photo gallery (curated, admin-managed)
// ---------------------------------------------------------------------------

const GALLERY_BUCKET = "gallery";
const GUEST_PHOTOS_BUCKET = "guest-photos";

export async function fetchGalleryPhotos(): Promise<GalleryPhoto[]> {
  const { data, error } = await supabase
    .from("gallery_photos")
    .select("*")
    .order("sort_order", { ascending: true })
    .order("created_at", { ascending: true });

  if (error) {
    console.error("fetchGalleryPhotos error", error);
    throw new Error("Could not load the photo gallery.");
  }

  return (data ?? []).map((row) => ({
    ...row,
    url: supabase.storage.from(GALLERY_BUCKET).getPublicUrl(row.storage_path)
      .data.publicUrl,
  }));
}

// ---------------------------------------------------------------------------
// Digital guestbook / comment wall
// ---------------------------------------------------------------------------

export async function fetchGuestbookComments(): Promise<GuestbookComment[]> {
  const { data, error } = await supabase
    .from("comments")
    .select("id, display_name, message, created_at")
    .order("created_at", { ascending: false });

  if (error) {
    console.error("fetchGuestbookComments error", error);
    throw new Error("Could not load the guestbook.");
  }

  return data ?? [];
}

export async function postGuestbookComment(
  displayName: string,
  message: string,
): Promise<void> {
  const { error } = await supabase
    .from("comments")
    .insert({ display_name: displayName, message });

  if (error) {
    console.error("postGuestbookComment error", error);
    throw new Error("Could not post your message. Please try again.");
  }
}

// ---------------------------------------------------------------------------
// Post-wedding guest photo uploads
// ---------------------------------------------------------------------------

const MAX_UPLOAD_BYTES = 8 * 1024 * 1024; // 8MB per photo
const ALLOWED_UPLOAD_TYPES = ["image/jpeg", "image/png", "image/webp", "image/heic"];

export async function fetchGuestPhotos(): Promise<GuestPhoto[]> {
  const { data, error } = await supabase
    .from("guest_photos")
    .select("*")
    .eq("approved", true)
    .order("created_at", { ascending: false });

  if (error) {
    console.error("fetchGuestPhotos error", error);
    throw new Error("Could not load guest photos.");
  }

  return (data ?? []).map((row) => ({
    ...row,
    url: supabase.storage
      .from(GUEST_PHOTOS_BUCKET)
      .getPublicUrl(row.storage_path).data.publicUrl,
  }));
}

export async function uploadGuestPhoto(
  file: File,
  uploaderName: string,
  caption: string,
): Promise<void> {
  if (file.size > MAX_UPLOAD_BYTES) {
    throw new Error("That photo is larger than 8MB. Please choose a smaller file.");
  }
  if (ALLOWED_UPLOAD_TYPES.length && file.type && !ALLOWED_UPLOAD_TYPES.includes(file.type)) {
    throw new Error("Please upload a JPG, PNG, WEBP, or HEIC photo.");
  }

  const ext = file.name.split(".").pop()?.toLowerCase() || "jpg";
  const path = `${crypto.randomUUID()}.${ext}`;

  const { error: uploadError } = await supabase.storage
    .from(GUEST_PHOTOS_BUCKET)
    .upload(path, file, { contentType: file.type || undefined });

  if (uploadError) {
    console.error("uploadGuestPhoto storage error", uploadError);
    throw new Error("Could not upload your photo. Please try again.");
  }

  const { error: insertError } = await supabase.from("guest_photos").insert({
    storage_path: path,
    uploader_name: uploaderName || null,
    caption: caption || null,
  });

  if (insertError) {
    console.error("uploadGuestPhoto insert error", insertError);
    throw new Error("Your photo uploaded but could not be saved. Please try again.");
  }
}
