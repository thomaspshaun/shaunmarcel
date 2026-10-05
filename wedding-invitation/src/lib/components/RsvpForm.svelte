<script lang="ts">
  import { onMount } from 'svelte';
  import Sprig from '$lib/components/Sprig.svelte';
  import { site } from '$lib/site-config';
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
      // A partner added by the admin is the plus-one by default.
      if (result.partner_first_name) {
        guestCount = 2;
        plusOneName = [result.partner_first_name, result.partner_last_name].filter(Boolean).join(' ');
      }
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
    <p class="eyebrow">RSVP</p>
    <h2 class="heading mt-4">
      Let us know you're coming
    </h2>
  </div>

  <div class="mt-10 border border-line bg-surface p-6 sm:p-10">
    {#if step === 'lookup'}
      <form onsubmit={handleLookup} class="space-y-4">
        <label class="block text-sm font-medium text-ink" for="guest-code">
          Enter your invitation code
        </label>
        <input
          id="guest-code"
          type="text"
          bind:value={code}
          placeholder="e.g. ABC1234"
          class="w-full rounded-none border border-line px-4 py-3 text-base uppercase tracking-widest text-ink focus:border-sage focus:outline-none"
          autocomplete="off"
        />
        <p class="text-xs text-muted">
          Your code is on your invitation. Contact us if you can't find it.
        </p>

        {#if lookupError}
          <p class="text-sm text-ink">{lookupError}</p>
        {/if}

        <button
          type="submit"
          disabled={lookupLoading}
          class="w-full btn disabled:cursor-not-allowed disabled:opacity-60"
        >
          {lookupLoading ? 'Looking up...' : 'Find My Invitation'}
        </button>
      </form>
    {:else if step === 'form' && guest}
      <form onsubmit={handleSubmit} class="space-y-6">
        <p class="text-lg font-medium text-ink">
          Hi {guest.first_name}! We're so glad to hear from you.
        </p>

        <fieldset class="space-y-2">
          <legend class="text-sm font-medium text-ink">Will you be attending?</legend>
          <div class="flex gap-3">
            <button
              type="button"
              onclick={() => (attending = true)}
              class="flex-1 rounded-none border px-4 py-3 text-sm font-medium transition {attending
                ? 'border-sage bg-sage text-surface'
                : 'border-line text-ink hover:border-sage'}"
            >
              Joyfully Attending
            </button>
            <button
              type="button"
              onclick={() => (attending = false)}
              class="flex-1 rounded-none border px-4 py-3 text-sm font-medium transition {!attending
                ? 'border-sage bg-sage text-surface'
                : 'border-line text-ink hover:border-sage'}"
            >
              Regretfully Declining
            </button>
          </div>
        </fieldset>

        {#if attending}
          <div>
            <label class="block text-sm font-medium text-ink" for="guest-count">
              Number attending{guest.plus_one_allowed ? ' (including plus one)' : ''}
            </label>
            <input
              id="guest-count"
              type="number"
              min="1"
              max={guest.plus_one_allowed ? 2 : 1}
              bind:value={guestCount}
              class="mt-2 w-full rounded-none border border-line px-4 py-3 text-base text-ink focus:border-sage focus:outline-none"
            />
          </div>

          {#if guest.plus_one_allowed && guestCount > 1}
            <div>
              <label class="block text-sm font-medium text-ink" for="plus-one-name">
                Plus one's name
              </label>
              <input
                id="plus-one-name"
                type="text"
                bind:value={plusOneName}
                class="mt-2 w-full rounded-none border border-line px-4 py-3 text-base text-ink focus:border-sage focus:outline-none"
              />
            </div>
          {/if}

          <div>
            <label class="block text-sm font-medium text-ink" for="dietary">
              Dietary requirements
            </label>
            <textarea
              id="dietary"
              bind:value={dietaryRequirements}
              rows="2"
              placeholder="Allergies, vegetarian, vegan, etc."
              class="mt-2 w-full rounded-none border border-line px-4 py-3 text-base text-ink focus:border-sage focus:outline-none"
            ></textarea>
          </div>

          <div>
            <label class="block text-sm font-medium text-ink" for="song">
              Song request
            </label>
            <input
              id="song"
              type="text"
              bind:value={songRequest}
              placeholder="What will get you on the dance floor?"
              class="mt-2 w-full rounded-none border border-line px-4 py-3 text-base text-ink focus:border-sage focus:outline-none"
            />
          </div>
        {/if}

        <div>
          <label class="block text-sm font-medium text-ink" for="notes">
            Anything else you'd like us to know?
          </label>
          <textarea
            id="notes"
            bind:value={notes}
            rows="2"
            class="mt-2 w-full rounded-none border border-line px-4 py-3 text-base text-ink focus:border-sage focus:outline-none"
          ></textarea>
        </div>

        {#if submitError}
          <p class="text-sm text-ink">{submitError}</p>
        {/if}

        <div class="flex gap-3">
          <button
            type="button"
            onclick={startOver}
            class="btn-ghost"
          >
            Back
          </button>
          <button
            type="submit"
            disabled={submitLoading}
            class="flex-1 btn disabled:cursor-not-allowed disabled:opacity-60"
          >
            {submitLoading ? 'Submitting...' : 'Submit RSVP'}
          </button>
        </div>
      </form>
    {:else if step === 'success'}
      <div class="py-6 text-center">
        <Sprig class="mx-auto h-5 w-32 text-champagne" />
        <h3 class="mt-4 text-xl font-medium text-ink">Thank you!</h3>
        <p class="mt-2 text-ink">
          {attending
            ? "Your RSVP is confirmed. We can't wait to celebrate with you!"
            : "We're sorry you can't make it, but thank you for letting us know."}
        </p>
        <button
          type="button"
          onclick={startOver}
          class="mt-6 btn-ghost"
        >
          Submit another RSVP
        </button>
      </div>
    {/if}
  </div>
</section>
