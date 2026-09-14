<script lang="ts">
  import { onMount } from 'svelte';
  import { findGuestByCode, submitRsvp, type GuestLookupResult } from '$lib/supabase';

  type Step = 'lookup' | 'form' | 'success';

  let step: Step = $state('lookup');
  let code = $state('');
  let lookupLoading = $state(false);
  let lookupError = $state('');

  let guest: GuestLookupResult | null = $state(null);

  let attending = $state(true);
  let guestCount = $state(1);
  let plusOneName = $state('');
  let dietaryRequirements = $state('');
  let songRequest = $state('');
  let notes = $state('');
  let submitLoading = $state(false);
  let submitError = $state('');

  // Pre-fill and auto-lookup the guest code from a personalized invite link
  // like https://shaunmarcel.co.za/?code=AB12CD (sent via WhatsApp/email).
  onMount(() => {
    const params = new URLSearchParams(window.location.search);
    const prefilled = params.get('code');
    if (prefilled) {
      code = prefilled.toUpperCase();
      handleLookup(new Event('submit'));
    }
  });

  async function handleLookup(e: Event) {
    e.preventDefault();
    if (!code.trim()) return;

    lookupLoading = true;
    lookupError = '';

    try {
      const result = await findGuestByCode(code);
      if (!result) {
        lookupError = "We couldn't find an invitation with that code. Please double-check and try again.";
        return;
      }

      guest = result;
      dietaryRequirements = result.dietary_notes ?? '';
      step = 'form';
    } catch (err) {
      lookupError = err instanceof Error ? err.message : 'Something went wrong. Please try again.';
    } finally {
      lookupLoading = false;
    }
  }

  async function handleSubmit(e: Event) {
    e.preventDefault();
    if (!guest) return;

    submitLoading = true;
    submitError = '';

    try {
      await submitRsvp({
        guestCode: code,
        attending,
        guestCount: attending ? guestCount : 0,
        plusOneName: attending ? plusOneName : '',
        dietaryRequirements: attending ? dietaryRequirements : '',
        songRequest: attending ? songRequest : '',
        notes
      });
      step = 'success';
    } catch (err) {
      submitError = err instanceof Error ? err.message : 'Something went wrong. Please try again.';
    } finally {
      submitLoading = false;
    }
  }

  function startOver() {
    step = 'lookup';
    code = '';
    guest = null;
    attending = true;
    guestCount = 1;
    plusOneName = '';
    dietaryRequirements = '';
    songRequest = '';
    notes = '';
    lookupError = '';
    submitError = '';
  }
</script>

<section id="rsvp" class="mx-auto max-w-xl px-6 py-20">
  <div class="text-center">
    <p class="text-xs font-semibold uppercase tracking-[0.4em] text-rose-500 sm:text-sm">RSVP</p>
    <h2 class="mt-4 text-3xl font-light tracking-tight text-slate-900 sm:text-4xl">
      Let us know you're coming
    </h2>
  </div>

  <div class="mt-10 rounded-3xl border border-slate-200 bg-white p-6 shadow-sm sm:p-8">
    {#if step === 'lookup'}
      <form onsubmit={handleLookup} class="space-y-4">
        <label class="block text-sm font-medium text-slate-700" for="guest-code">
          Enter your invitation code
        </label>
        <input
          id="guest-code"
          type="text"
          bind:value={code}
          placeholder="e.g. ABC1234"
          class="w-full rounded-xl border border-slate-300 px-4 py-3 text-base uppercase tracking-widest text-slate-900 focus:border-rose-400 focus:ring-2 focus:ring-rose-200 focus:outline-none"
          autocomplete="off"
        />
        <p class="text-xs text-slate-500">
          Your code is on your invitation. Contact us if you can't find it.
        </p>

        {#if lookupError}
          <p class="text-sm text-red-600">{lookupError}</p>
        {/if}

        <button
          type="submit"
          disabled={lookupLoading}
          class="w-full rounded-full bg-rose-500 px-6 py-3 text-sm font-medium text-white shadow-lg shadow-rose-200 transition hover:bg-rose-600 disabled:cursor-not-allowed disabled:opacity-60"
        >
          {lookupLoading ? 'Looking up...' : 'Find My Invitation'}
        </button>
      </form>
    {:else if step === 'form' && guest}
      <form onsubmit={handleSubmit} class="space-y-6">
        <p class="text-lg font-medium text-slate-900">
          Hi {guest.first_name}! We're so glad to hear from you.
        </p>

        <fieldset class="space-y-2">
          <legend class="text-sm font-medium text-slate-700">Will you be attending?</legend>
          <div class="flex gap-3">
            <button
              type="button"
              onclick={() => (attending = true)}
              class="flex-1 rounded-xl border px-4 py-3 text-sm font-medium transition {attending
                ? 'border-rose-400 bg-rose-50 text-rose-600'
                : 'border-slate-300 text-slate-600 hover:border-slate-400'}"
            >
              Joyfully Attending
            </button>
            <button
              type="button"
              onclick={() => (attending = false)}
              class="flex-1 rounded-xl border px-4 py-3 text-sm font-medium transition {!attending
                ? 'border-rose-400 bg-rose-50 text-rose-600'
                : 'border-slate-300 text-slate-600 hover:border-slate-400'}"
            >
              Regretfully Declining
            </button>
          </div>
        </fieldset>

        {#if attending}
          <div>
            <label class="block text-sm font-medium text-slate-700" for="guest-count">
              Number attending{guest.plus_one_allowed ? ' (including plus one)' : ''}
            </label>
            <input
              id="guest-count"
              type="number"
              min="1"
              max={guest.plus_one_allowed ? 2 : 1}
              bind:value={guestCount}
              class="mt-2 w-full rounded-xl border border-slate-300 px-4 py-3 text-base text-slate-900 focus:border-rose-400 focus:ring-2 focus:ring-rose-200 focus:outline-none"
            />
          </div>

          {#if guest.plus_one_allowed && guestCount > 1}
            <div>
              <label class="block text-sm font-medium text-slate-700" for="plus-one-name">
                Plus one's name
              </label>
              <input
                id="plus-one-name"
                type="text"
                bind:value={plusOneName}
                class="mt-2 w-full rounded-xl border border-slate-300 px-4 py-3 text-base text-slate-900 focus:border-rose-400 focus:ring-2 focus:ring-rose-200 focus:outline-none"
              />
            </div>
          {/if}

          <div>
            <label class="block text-sm font-medium text-slate-700" for="dietary">
              Dietary requirements
            </label>
            <textarea
              id="dietary"
              bind:value={dietaryRequirements}
              rows="2"
              placeholder="Allergies, vegetarian, vegan, etc."
              class="mt-2 w-full rounded-xl border border-slate-300 px-4 py-3 text-base text-slate-900 focus:border-rose-400 focus:ring-2 focus:ring-rose-200 focus:outline-none"
            ></textarea>
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700" for="song">
              Song request
            </label>
            <input
              id="song"
              type="text"
              bind:value={songRequest}
              placeholder="What will get you on the dance floor?"
              class="mt-2 w-full rounded-xl border border-slate-300 px-4 py-3 text-base text-slate-900 focus:border-rose-400 focus:ring-2 focus:ring-rose-200 focus:outline-none"
            />
          </div>
        {/if}

        <div>
          <label class="block text-sm font-medium text-slate-700" for="notes">
            Anything else you'd like us to know?
          </label>
          <textarea
            id="notes"
            bind:value={notes}
            rows="2"
            class="mt-2 w-full rounded-xl border border-slate-300 px-4 py-3 text-base text-slate-900 focus:border-rose-400 focus:ring-2 focus:ring-rose-200 focus:outline-none"
          ></textarea>
        </div>

        {#if submitError}
          <p class="text-sm text-red-600">{submitError}</p>
        {/if}

        <div class="flex gap-3">
          <button
            type="button"
            onclick={startOver}
            class="rounded-full border border-slate-300 px-5 py-3 text-sm font-medium text-slate-700 transition hover:border-slate-400 hover:bg-slate-50"
          >
            Back
          </button>
          <button
            type="submit"
            disabled={submitLoading}
            class="flex-1 rounded-full bg-rose-500 px-6 py-3 text-sm font-medium text-white shadow-lg shadow-rose-200 transition hover:bg-rose-600 disabled:cursor-not-allowed disabled:opacity-60"
          >
            {submitLoading ? 'Submitting...' : 'Submit RSVP'}
          </button>
        </div>
      </form>
    {:else if step === 'success'}
      <div class="py-6 text-center">
        <p class="text-3xl">🎉</p>
        <h3 class="mt-4 text-xl font-medium text-slate-900">Thank you!</h3>
        <p class="mt-2 text-slate-600">
          {attending
            ? "Your RSVP is confirmed. We can't wait to celebrate with you!"
            : "We're sorry you can't make it, but thank you for letting us know."}
        </p>
        <button
          type="button"
          onclick={startOver}
          class="mt-6 rounded-full border border-slate-300 px-6 py-3 text-sm font-medium text-slate-700 transition hover:border-slate-400 hover:bg-slate-50"
        >
          Submit another RSVP
        </button>
      </div>
    {/if}
  </div>
</section>
