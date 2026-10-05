// Central site configuration for copy that appears across multiple components/pages.
// Update this file as event details are confirmed.

export const site = {
  coupleNames: "Shaun & Marcel",
  tagline: "A relaxed wedding weekend",
  weddingDateLabel: "Saturday, 26 April 2025",
  countdownTargetIso: "2025-04-26T13:30:00+02:00",
  venueName: "Eikenhof Estate, Cape Winelands",
  contactPhoneDisplay: "083 633 8108",
  contactPhoneHref: "tel:+27836338108",
  siteUrl: "https://dev.shaunmarcel.co.za",
  socialImagePath: "/favicon.svg",
};

export const registry = {
  title: "Honeymoon Fund",
  description:
    "Your presence is the greatest gift. If you would like to contribute, you can help us create memories on our honeymoon.",
  bankDetails: {
    accountName: "ACCOUNT NAME TO BE CONFIRMED",
    bankName: "BANK NAME TO BE CONFIRMED",
    accountNumber: "ACCOUNT NUMBER TO BE CONFIRMED",
    branchCode: "BRANCH CODE TO BE CONFIRMED",
    reference: "Shaun & Marcel",
  },
};

export const navLinks = [
  { href: "#hero", label: "Home" },
  { href: "#details", label: "Details" },
  { href: "#rsvp", label: "RSVP" },
  { href: "#gallery", label: "Gallery" },
  { href: "#guestbook", label: "Guestbook" },
];

// Wedding weekend schedule: Friday arrival, Saturday celebration, Sunday farewell
export const scheduleEvents = [
  {
    id: "friday-arrival",
    time: "From 15:00",
    title: "Friday — Arrive & Settle In",
    description: "Guests arrive and settle in for a relaxed evening. Meet, unwind, and enjoy the surroundings.",
    startIso: "2025-04-25T15:00:00+02:00",
    endIso: "2025-04-25T22:00:00+02:00",
  },
  {
    id: "welcome-drink",
    time: "13:30 – 14:00",
    title: "Saturday — Guest Arrival & Welcome Drink",
    description: "Guests arrive and receive a welcome drink.",
    startIso: "2025-04-26T13:30:00+02:00",
    endIso: "2025-04-26T14:00:00+02:00",
  },
  {
    id: "ceremony",
    time: "14:00 – 14:45",
    title: "Wedding Ceremony",
    description: "Join us as we say our vows at Eikenhof Estate.",
    startIso: "2025-04-26T14:00:00+02:00",
    endIso: "2025-04-26T14:45:00+02:00",
  },
  {
    id: "cocktails",
    time: "14:45 – 16:30",
    title: "Cocktails & Canapés",
    description: "Celebrate with drinks and canapés.",
    startIso: "2025-04-26T14:45:00+02:00",
    endIso: "2025-04-26T16:30:00+02:00",
  },
  {
    id: "photos",
    time: "16:30 – 17:15",
    title: "Photos & Mingling",
    description: "Wedding photos and time to mingle with guests.",
    startIso: "2025-04-26T16:30:00+02:00",
    endIso: "2025-04-26T17:15:00+02:00",
  },
  {
    id: "dinner",
    time: "17:30",
    title: "Dinner & Reception",
    description: "Dinner and celebration reception.",
    startIso: "2025-04-26T17:30:00+02:00",
    endIso: "2025-04-26T20:15:00+02:00",
  },
  {
    id: "dancing",
    time: "20:15",
    title: "Dancing & Celebration",
    description: "Dance and celebrate the night away.",
    startIso: "2025-04-26T20:15:00+02:00",
    endIso: "2025-04-27T00:00:00+02:00",
  },
  {
    id: "sunday-farewell",
    time: "From 09:00",
    title: "Sunday — Breakfast & Farewell",
    description: "Enjoy a relaxed morning breakfast before heading home.",
    startIso: "2025-04-27T09:00:00+02:00",
    endIso: "2025-04-27T12:00:00+02:00",
  },
];

export const venue = {
  name: "Eikenhof Estate",
  address: "Eikenhof Estate, Stellenbosch, Cape Winelands, South Africa",
  mapEmbedQuery: "Eikenhof Estate Stellenbosch",
  mapsUrl:
    "https://www.google.com/maps/search/?api=1&query=Eikenhof+Estate+Stellenbosch",
};

export const accommodations = [
  {
    id: "nearby-boutique-hotel",
    name: "Boutique Hotel Option",
    distance: "~5–10 min drive",
    notes: "Comfortable accommodation within easy reach of the venue.",
    bookingCode: "Coming soon",
    url: "https://www.google.com/maps/search/?api=1&query=Stellenbosch+accommodation",
  },
  {
    id: "guest-houses",
    name: "Local Guest Houses",
    distance: "~8–15 min drive",
    notes: "Charming guest houses in the nearby Winelands.",
    bookingCode: "Coming soon",
    url: "https://www.google.com/maps/search/?api=1&query=Stellenbosch+guest+house",
  },
  {
    id: "self-catering",
    name: "Self-Catering Units",
    distance: "~10–20 min drive",
    notes: "More affordable self-catering options for flexibility.",
    bookingCode: "Coming soon",
    url: "https://www.google.com/maps/search/?api=1&query=Stellenbosch+self+catering",
  },
];
