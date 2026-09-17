// Central site configuration for copy that appears across multiple components/pages.
// Update this file as event details are confirmed.

export const site = {
  coupleNames: "Shaun & Marcel",
  tagline: "We are getting married",
  weddingDateLabel: "April 2026 (date to be confirmed)",
  // Placeholder target used only to drive the countdown timer until the exact date is confirmed.
  countdownTargetIso: "2026-04-01T15:00:00+02:00",
  venueName: "Cape Town, South Africa",
  contactPhoneDisplay: "083 633 8108",
  contactPhoneHref: "tel:+27836338108",
  siteUrl: "https://dev.shaunmarcel.co.za",
};

export const navLinks = [
  { href: "#hero", label: "Home" },
  { href: "#details", label: "Details" },
  { href: "#rsvp", label: "RSVP" },
  { href: "#gallery", label: "Gallery" },
  { href: "#guestbook", label: "Guestbook" },
];

// TODO: replace placeholder times/venue/accommodation details once confirmed.
// Schedule items double as the source data for "Add to Calendar" entries.
export const scheduleEvents = [
  {
    id: "ceremony",
    time: "3:00 PM",
    title: "Ceremony",
    description: 'Join us as we say "I do" among the vines.',
    startIso: "2026-04-01T15:00:00+02:00",
    endIso: "2026-04-01T16:00:00+02:00",
  },
  {
    id: "cocktails",
    time: "4:00 PM",
    title: "Cocktail Hour",
    description: "Drinks, canapés, and photos on the terrace.",
    startIso: "2026-04-01T16:00:00+02:00",
    endIso: "2026-04-01T17:30:00+02:00",
  },
  {
    id: "reception",
    time: "6:00 PM",
    title: "Reception & Dinner",
    description: "Speeches, dinner, and celebrating together.",
    startIso: "2026-04-01T18:00:00+02:00",
    endIso: "2026-04-01T21:00:00+02:00",
  },
  {
    id: "party",
    time: "9:00 PM",
    title: "Party",
    description: "Dancing under the stars until late.",
    startIso: "2026-04-01T21:00:00+02:00",
    endIso: "2026-04-01T23:59:00+02:00",
  },
];

export const venue = {
  name: "Winelands Venue (TBC)",
  address: "Stellenbosch Winelands, Cape Town, South Africa",
  // Generic winelands search query used until the exact venue is confirmed.
  mapEmbedQuery: "Stellenbosch Winelands, South Africa",
  mapsUrl:
    "https://www.google.com/maps/search/?api=1&query=Stellenbosch+Winelands+South+Africa",
};

export const accommodations = [
  {
    id: "venue-guesthouse",
    name: "On-site Guesthouse (TBC)",
    distance: "On the estate",
    notes: "Limited rooms — book early. Booking code to follow.",
    bookingCode: "TBC",
    url: "https://www.google.com/maps/search/?api=1&query=Stellenbosch+guesthouse",
  },
  {
    id: "nearby-boutique-hotel",
    name: "Nearby Boutique Hotel (TBC)",
    distance: "~5 min drive",
    notes: "Ask for the wedding block rate when booking.",
    bookingCode: "TBC",
    url: "https://www.google.com/maps/search/?api=1&query=Stellenbosch+boutique+hotel",
  },
  {
    id: "budget-friendly-stay",
    name: "Budget-Friendly Stay (TBC)",
    distance: "~10 min drive",
    notes: "A more affordable option a short drive from the venue.",
    bookingCode: "TBC",
    url: "https://www.google.com/maps/search/?api=1&query=Stellenbosch+accommodation",
  },
];
