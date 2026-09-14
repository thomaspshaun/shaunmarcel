// Browser Supabase client, used for guest lookup and RSVP submission.
// Only the public anon key is used here — all sensitive access is enforced
// server-side via RLS + SECURITY DEFINER RPC functions (see supabase/schema.sql).
import { createClient } from '@supabase/supabase-js';
import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from '$env/static/public';

export const supabase = createClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY);

export interface GuestLookupResult {
  id: string;
  first_name: string;
  last_name: string;
  guest_type: string;
  plus_one_allowed: boolean;
  rsvp_status: string;
  dietary_notes: string | null;
}

export async function findGuestByCode(code: string): Promise<GuestLookupResult | null> {
  const { data, error } = await supabase.rpc('find_guest_by_code', { p_code: code });

  if (error) {
    console.error('find_guest_by_code error', error);
    throw new Error('Something went wrong looking up your invitation. Please try again.');
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
  const { data, error } = await supabase.rpc('submit_rsvp', {
    p_guest_code: submission.guestCode,
    p_attending: submission.attending,
    p_guest_count: submission.guestCount,
    p_plus_one_name: submission.plusOneName || null,
    p_dietary_requirements: submission.dietaryRequirements || null,
    p_song_request: submission.songRequest || null,
    p_notes: submission.notes || null
  });

  if (error) {
    console.error('submit_rsvp error', error);
    throw new Error('Something went wrong submitting your RSVP. Please try again.');
  }

  const result = data?.[0];
  if (!result?.success) {
    throw new Error(result?.message ?? 'We could not find that invitation code.');
  }
}
