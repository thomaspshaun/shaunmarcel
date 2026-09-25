<script lang="ts">
  import { onMount } from 'svelte';
  import {
    fetchVendors,
    addVendor,
    updateVendor,
    deleteVendor,
    fetchVendorPayments,
    addVendorPayment,
    updateVendorPayment,
    deleteVendorPayment,
    type PlannerVendor,
    type VendorPayment
  } from '$lib/planner';
  import { vendorRoles } from '$lib/planner-templates';

  let vendors: PlannerVendor[] = $state([]);
  let paymentsByVendor: Record<string, VendorPayment[]> = $state({});
  let loading = $state(true);
  let loadError = $state('');

  let newRole = $state(vendorRoles[0]);
  let newName = $state('');

  onMount(load);

  async function load() {
    loading = true;
    loadError = '';
    try {
      vendors = await fetchVendors();
      const entries = await Promise.all(
        vendors.map(async (v) => [v.id, await fetchVendorPayments(v.id)] as const)
      );
      paymentsByVendor = Object.fromEntries(entries);
    } catch (err) {
      loadError = err instanceof Error ? err.message : 'Could not load vendors.';
    } finally {
      loading = false;
    }
  }

  async function handleAddVendor(e: Event) {
    e.preventDefault();
    if (!newName.trim()) return;
    const vendor = await addVendor(newRole, newName.trim());
    vendors = [...vendors, vendor];
    paymentsByVendor = { ...paymentsByVendor, [vendor.id]: [] };
    newName = '';
  }

  async function handleDeleteVendor(vendor: PlannerVendor) {
    if (!confirm(`Remove ${vendor.name || vendor.role}?`)) return;
    vendors = vendors.filter((v) => v.id !== vendor.id);
    await deleteVendor(vendor.id);
  }

  async function handleFieldChange(vendor: PlannerVendor, patch: Partial<PlannerVendor>) {
    Object.assign(vendor, patch);
    vendors = [...vendors];
    await updateVendor(vendor.id, patch);
  }

  async function handleAddPayment(vendor: PlannerVendor) {
    const payment = await addVendorPayment(vendor.id, null, null);
    paymentsByVendor = {
      ...paymentsByVendor,
      [vendor.id]: [...(paymentsByVendor[vendor.id] ?? []), payment]
    };
  }

  async function handlePaymentChange(vendor: PlannerVendor, payment: VendorPayment, patch: Partial<VendorPayment>) {
    Object.assign(payment, patch);
    paymentsByVendor = { ...paymentsByVendor };
    await updateVendorPayment(payment.id, patch);
  }

  async function handleDeletePayment(vendor: PlannerVendor, payment: VendorPayment) {
    paymentsByVendor = {
      ...paymentsByVendor,
      [vendor.id]: (paymentsByVendor[vendor.id] ?? []).filter((p) => p.id !== payment.id)
    };
    await deleteVendorPayment(payment.id);
  }

  function totalPaid(vendorId: string): number {
    return (paymentsByVendor[vendorId] ?? []).filter((p) => p.paid).reduce((sum, p) => sum + (p.amount ?? 0), 0);
  }
</script>

<div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
  <h2 class="text-lg font-medium text-slate-900">Add a Vendor</h2>
  <form onsubmit={handleAddVendor} class="mt-4 flex flex-wrap gap-3">
    <select bind:value={newRole} class="rounded-xl border border-slate-300 px-4 py-2.5 text-sm focus:border-rose-400 focus:outline-none">
      {#each vendorRoles as role (role)}
        <option value={role}>{role}</option>
      {/each}
    </select>
    <input
      type="text"
      placeholder="Vendor / business name"
      bind:value={newName}
      class="min-w-[12rem] flex-1 rounded-xl border border-slate-300 px-4 py-2.5 text-sm focus:border-rose-400 focus:outline-none"
    />
    <button type="submit" class="rounded-full bg-rose-500 px-6 py-2.5 text-sm font-medium text-white hover:bg-rose-600">
      Add Vendor
    </button>
  </form>
</div>

{#if loading}
  <p class="mt-6 text-slate-500">Loading vendors...</p>
{:else if loadError}
  <p class="mt-6 text-red-600">{loadError}</p>
{:else if vendors.length === 0}
  <p class="mt-6 text-slate-500">No vendors yet — add your photographer, DJ, florist, etc. above.</p>
{:else}
  <div class="mt-6 grid gap-5 lg:grid-cols-2">
    {#each vendors as vendor (vendor.id)}
      <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
        <div class="flex items-start justify-between gap-2">
          <div>
            <p class="text-xs font-semibold tracking-wide text-rose-500 uppercase">{vendor.role}</p>
            <input
              type="text"
              value={vendor.name ?? ''}
              onblur={(e) => handleFieldChange(vendor, { name: e.currentTarget.value || null })}
              class="mt-1 w-full rounded-lg border-0 p-0 text-base font-medium text-slate-900 focus:ring-0"
            />
          </div>
          <button type="button" onclick={() => handleDeleteVendor(vendor)} class="text-xs text-slate-300 hover:text-red-500">
            Remove
          </button>
        </div>

        <div class="mt-3 grid grid-cols-2 gap-3 text-sm">
          <label class="block">
            <span class="text-xs text-slate-500">Contact</span>
            <input
              type="text"
              value={vendor.contact_name ?? ''}
              onblur={(e) => handleFieldChange(vendor, { contact_name: e.currentTarget.value || null })}
              class="mt-0.5 w-full rounded-lg border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
            />
          </label>
          <label class="block">
            <span class="text-xs text-slate-500">Phone</span>
            <input
              type="text"
              value={vendor.phone ?? ''}
              onblur={(e) => handleFieldChange(vendor, { phone: e.currentTarget.value || null })}
              class="mt-0.5 w-full rounded-lg border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
            />
          </label>
          <label class="block">
            <span class="text-xs text-slate-500">Email</span>
            <input
              type="email"
              value={vendor.email ?? ''}
              onblur={(e) => handleFieldChange(vendor, { email: e.currentTarget.value || null })}
              class="mt-0.5 w-full rounded-lg border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
            />
          </label>
          <label class="block">
            <span class="text-xs text-slate-500">Cost</span>
            <input
              type="text"
              value={vendor.cost ?? ''}
              onblur={(e) => handleFieldChange(vendor, { cost: e.currentTarget.value || null })}
              class="mt-0.5 w-full rounded-lg border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
            />
          </label>
        </div>

        <label class="mt-3 block text-sm">
          <span class="text-xs text-slate-500">Notes</span>
          <textarea
            value={vendor.notes ?? ''}
            onblur={(e) => handleFieldChange(vendor, { notes: e.currentTarget.value || null })}
            rows="2"
            class="mt-0.5 w-full rounded-lg border border-slate-300 px-2 py-1 text-sm focus:border-rose-400 focus:outline-none"
          ></textarea>
        </label>

        <div class="mt-3 flex flex-wrap gap-x-4 gap-y-2 text-sm">
          <label class="flex items-center gap-1.5">
            <input
              type="checkbox"
              checked={vendor.contract_signed}
              onchange={(e) => handleFieldChange(vendor, { contract_signed: e.currentTarget.checked })}
              class="h-4 w-4 rounded border-slate-300"
            />
            Contract signed
          </label>
          <label class="flex items-center gap-1.5">
            <input
              type="checkbox"
              checked={vendor.deposit_paid}
              onchange={(e) => handleFieldChange(vendor, { deposit_paid: e.currentTarget.checked })}
              class="h-4 w-4 rounded border-slate-300"
            />
            Deposit paid
          </label>
          <label class="flex items-center gap-1.5">
            <input
              type="checkbox"
              checked={vendor.final_payment_scheduled}
              onchange={(e) => handleFieldChange(vendor, { final_payment_scheduled: e.currentTarget.checked })}
              class="h-4 w-4 rounded border-slate-300"
            />
            Final payment scheduled
          </label>
          <label class="flex items-center gap-1.5">
            <input
              type="checkbox"
              checked={vendor.arrival_confirmed}
              onchange={(e) => handleFieldChange(vendor, { arrival_confirmed: e.currentTarget.checked })}
              class="h-4 w-4 rounded border-slate-300"
            />
            Arrival time confirmed
          </label>
        </div>

        <div class="mt-4 border-t border-slate-100 pt-3">
          <div class="flex items-center justify-between">
            <p class="text-xs font-semibold tracking-wide text-slate-500 uppercase">Payments</p>
            <p class="text-xs text-slate-500">Paid: R{totalPaid(vendor.id).toFixed(2)}</p>
          </div>
          <ul class="mt-2 space-y-1.5">
            {#each paymentsByVendor[vendor.id] ?? [] as payment (payment.id)}
              <li class="flex items-center gap-2 text-xs">
                <input
                  type="date"
                  value={payment.payment_date ?? ''}
                  onchange={(e) => handlePaymentChange(vendor, payment, { payment_date: e.currentTarget.value || null })}
                  class="rounded-lg border border-slate-300 px-2 py-1 focus:border-rose-400 focus:outline-none"
                />
                <input
                  type="number"
                  step="0.01"
                  placeholder="Amount"
                  value={payment.amount ?? ''}
                  onblur={(e) =>
                    handlePaymentChange(vendor, payment, {
                      amount: e.currentTarget.value ? Number(e.currentTarget.value) : null
                    })}
                  class="w-24 rounded-lg border border-slate-300 px-2 py-1 focus:border-rose-400 focus:outline-none"
                />
                <label class="flex items-center gap-1">
                  <input
                    type="checkbox"
                    checked={payment.paid}
                    onchange={(e) => handlePaymentChange(vendor, payment, { paid: e.currentTarget.checked })}
                    class="h-3.5 w-3.5 rounded border-slate-300"
                  />
                  Paid
                </label>
                <button
                  type="button"
                  onclick={() => handleDeletePayment(vendor, payment)}
                  class="ml-auto text-slate-300 hover:text-red-500"
                >
                  &times;
                </button>
              </li>
            {/each}
          </ul>
          <button
            type="button"
            onclick={() => handleAddPayment(vendor)}
            class="mt-2 text-xs font-medium text-rose-600 hover:underline"
          >
            + Add Payment
          </button>
        </div>
      </div>
    {/each}
  </div>
{/if}
