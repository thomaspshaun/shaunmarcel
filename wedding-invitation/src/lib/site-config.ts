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
  yuppiechefUrl: "https://yuppiechef.com/yc9904838",
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
    id: "vine-guesthouse",
    name: "Vine Guesthouse",
    distance: "~5–7 min drive",
    notes: "12 boutique rooms in Koelenhof. Perfect for couples and small groups.",
    bookingCode: "$",
    url: "https://www.vineguesthouse.co.za",
  },
  {
    id: "groenvlei-guest-farm",
    name: "Groenvlei Guest Farm",
    distance: "~7–9 min drive",
    notes: "5 guesthouse rooms + self-catering units. Farm atmosphere, ideal for families.",
    bookingCode: "$",
    url: "https://groenvlei.com",
  },
  {
    id: "hazendal-hotel-spa",
    name: "Hazendal Hotel & Spa",
    distance: "~8–10 min drive",
    notes: "34 luxury rooms/suites. Premium option for guests seeking a full hotel experience.",
    bookingCode: "$$",
    url: "https://www.hazendal.co.za/stay",
  },
  {
    id: "devonvale-golf-wine",
    name: "Devonvale Golf & Wine Estate",
    distance: "~10–12 min drive",
    notes: "40+ rooms and holiday homes. Excellent for families and larger groups.",
    bookingCode: "$$",
    url: "https://devonvale.co.za/accommodation",
  },
];

// Additional accommodation options for guests who prefer further-out venues
export const additionalAccommodations = [
  { name: "Rouana Guest Farm", distance: "~12–15 min", price: "$", url: "https://rouanaguestfarm.com" },
  { name: "Kunjani Wines", distance: "~13–16 min", price: "$$", url: "https://www.kunjaniwines.co.za" },
  { name: "Zevenwacht Wine Estate", distance: "~15–18 min", price: "$$", url: "https://zevenwacht.co.za" },
  { name: "The Log Collective", distance: "~18–20 min", price: "$$", url: "https://thelogcollective.co.za" },
  { name: "Devon Valley Hotel", distance: "~20–22 min", price: "$$", url: "https://devonvalleyhotel.com" },
  { name: "Spier Hotel", distance: "~22–25 min", price: "$$", url: "https://www.spier.co.za" },
];




