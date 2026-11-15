import type { GuestLookupResult } from "$lib/supabase";

export interface GuestProfile {
  name: string;
}

export function toGuestProfile(guest: GuestLookupResult | null): GuestProfile | null {
  if (!guest) return null;
  return { name: guest.first_name };
}