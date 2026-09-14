// Builds a personalized WhatsApp click-to-chat link for a guest invite.
// See: https://faq.whatsapp.com/5913398998672934 (wa.me link format)
import { site } from '$lib/site-config';

/** Normalizes a phone number to digits-only (with country code) for wa.me links. */
export function normalizeWhatsappNumber(raw: string): string {
  const digits = raw.replace(/[^\d]/g, '');
  // Assume South African numbers entered without country code (leading 0).
  if (digits.startsWith('0')) {
    return `27${digits.slice(1)}`;
  }
  return digits;
}

export function buildInviteMessage(firstName: string, guestCode: string): string {
  return (
    `Hi ${firstName}! 🎉\n\n` +
    `You're invited to ${site.coupleNames}'s wedding! Please visit the link below to view details and RSVP:\n\n` +
    `${site.siteUrl}/?code=${guestCode}\n\n` +
    `Your invite code: ${guestCode}\n\n` +
    `We can't wait to celebrate with you!`
  );
}

export function buildWhatsappLink(whatsappNumber: string, firstName: string, guestCode: string): string {
  const number = normalizeWhatsappNumber(whatsappNumber);
  const message = buildInviteMessage(firstName, guestCode);
  return `https://wa.me/${number}?text=${encodeURIComponent(message)}`;
}
