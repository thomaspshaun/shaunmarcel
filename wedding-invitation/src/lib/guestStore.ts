import { writable } from "svelte/store";
import type { GuestLookupResult } from "$lib/supabase";

/**
 * Guest session store: Manages the current logged-in guest's data.
 * Guest session is persisted in localStorage under key 'wedding_guest_session'.
 * Expires after 7 days or when explicitly cleared.
 */

interface GuestSession {
  guest: GuestLookupResult;
  code: string;
  loadedAt: number; // Timestamp for expiry check
}

const STORAGE_KEY = "wedding_guest_session";
const SESSION_EXPIRY_MS = 7 * 24 * 60 * 60 * 1000; // 7 days

function createGuestStore() {
  // Initialize from localStorage if valid
  let initialGuest: GuestLookupResult | null = null;
  let initialCode: string | null = null;

  if (typeof window !== "undefined") {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored) {
      try {
        const session: GuestSession = JSON.parse(stored);
        const age = Date.now() - session.loadedAt;
        if (age < SESSION_EXPIRY_MS) {
          initialGuest = session.guest;
          initialCode = session.code;
        } else {
          localStorage.removeItem(STORAGE_KEY);
        }
      } catch (e) {
        localStorage.removeItem(STORAGE_KEY);
      }
    }
  }

  const { subscribe, set, update } = writable<{
    guest: GuestLookupResult | null;
    code: string | null;
    loading: boolean;
    error: string | null;
  }>({
    guest: initialGuest,
    code: initialCode,
    loading: false,
    error: null,
  });

  return {
    subscribe,

    setGuest(guest: GuestLookupResult, code: string) {
      const session: GuestSession = {
        guest,
        code,
        loadedAt: Date.now(),
      };
      if (typeof window !== "undefined") {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(session));
      }
      set({
        guest,
        code,
        loading: false,
        error: null,
      });
    },

    clearGuest() {
      if (typeof window !== "undefined") {
        localStorage.removeItem(STORAGE_KEY);
      }
      set({
        guest: null,
        code: null,
        loading: false,
        error: null,
      });
    },

    setLoading(loading: boolean) {
      update((state) => ({ ...state, loading }));
    },

    setError(error: string | null) {
      update((state) => ({ ...state, error }));
    },
  };
}

export const guestStore = createGuestStore();
