import type { GuestLookupResult } from "$lib/supabase";

// Simplified view of the current guest used to decide which content to show.
export interface GuestProfile {
  name: string;
  weddingParty: boolean;
}

export function toGuestProfile(guest: GuestLookupResult | null): GuestProfile | null {
  if (!guest) return null;
  return { name: guest.first_name, weddingParty: guest.guest_type === "wedding_party" };
}