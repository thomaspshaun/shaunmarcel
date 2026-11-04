// Central site configuration for copy that appears across multiple components/pages.
// Update this file as event details are confirmed.

export const site = {
  coupleNames: "Shaun & Marcel",
  names: ["Shaun", "Marcel"] as const,
  tagline: "Together with their families",
  weddingDateLabel: "1 April 2027",
  // Counts down to the start of the ceremony.
  countdownTargetIso: "2027-04-01T14:00:00+02:00",
  venueName: "Eikenhof Estate",
  region: "Cape Winelands · South Africa",
  // Shown in the RSVP section when set, e.g. "1 February 2027".
  rsvpDeadlineLabel: "",
  // Optional editorial photograph for the hero, e.g. "/hero.jpg" (place the file in /static).
  heroImage: "",
  contactPhoneDisplay: "083 633 8108",
  contactPhoneHref: "tel:+27836338108",
  siteUrl: "https://shaunmarcel.co.za",
  socialImagePath: "/social-preview.jpg",
};

export const rsvpDeadlines = {
  vip: "30 November",
  standard: "31 December",
  extra: "31 January",
} as const;

export const registry = {
  yuppiechefUrl: "https://yuppiechef.com/yc9904838",
  title: "Honeymoon Fund",
  description:
    "Your presence is the greatest gift. If you would like to contribute, you can help us create memories on our honeymoon.",
  bankDetails: {
    accountName: "Shaun Padachi",
    bankName: "Discovery Bank",
    accountNumber: "18536742051",
    branchCode: "679000",
    reference: "Honeymoon Fund <your name>",
  },
};

export const navLinks = [
  { href: "#weekend", label: "Our Weekend" },
  { href: "#wedding", label: "The Wedding" },
  { href: "#venue", label: "Venue" },
  { href: "#accommodation", label: "Accommodation" },
  { href: "#rsvp", label: "RSVP" },
];

// Wedding-day programme. Also the source data for the "Add to Calendar" entry.
export const scheduleEvents = [
  {
    id: "welcome",
    time: "13:30",
    title: "Guest arrival & welcome drink",
    description: "Guests arrive and are welcomed with a drink.",
    startIso: "2027-04-01T13:30:00+02:00",
    endIso: "2027-04-01T14:00:00+02:00",
  },
  {
    id: "ceremony",
    time: "14:00",
    title: "Wedding ceremony",
    description: "The wedding ceremony at Eikenhof Estate.",
    startIso: "2027-04-01T14:00:00+02:00",
    endIso: "2027-04-01T14:45:00+02:00",
  },
  {
    id: "cocktails",
    time: "14:45",
    title: "Cocktails & canapés",
    description: "Cocktails and canapés.",
    startIso: "2027-04-01T14:45:00+02:00",
    endIso: "2027-04-01T16:30:00+02:00",
  },
  {
    id: "photos",
    time: "16:30",
    title: "Wedding photos & mingling",
    description: "Wedding photos and time to mingle.",
    startIso: "2027-04-01T16:30:00+02:00",
    endIso: "2027-04-01T17:15:00+02:00",
  },
  {
    id: "dinner",
    time: "17:30",
    title: "Dinner & reception",
    description: "Dinner and reception.",
    startIso: "2027-04-01T17:30:00+02:00",
    endIso: "2027-04-01T20:15:00+02:00",
  },
  {
    id: "dancing",
    time: "20:15",
    title: "Dancing & celebration",
    description: "Dancing and celebration.",
    startIso: "2027-04-01T20:15:00+02:00",
    endIso: "2027-04-02T00:00:00+02:00",
  },
  {
    id: "close",
    time: "00:00",
    title: "Reception ends",
    description: "The reception ends.",
    startIso: "2027-04-02T00:00:00+02:00",
    endIso: "2027-04-02T00:00:00+02:00",
  },
];

export const weekend = [
  {
    id: "arrival",
    day: "Wednesday",
    date: "31 March",
    title: "Arrive & Settle In",
    description:
      "A relaxed, informal evening for guests arriving at Eikenhof Estate: a chance to meet, unwind and enjoy the surroundings.",
    note: "Evening plans to be confirmed",
  },
  {
    id: "wedding",
    day: "Thursday",
    date: "1 April",
    title: "Our Wedding Day",
    description: "The main celebration takes place on Thursday.",
    note: "",
  },
];

export const venue = {
  name: "Eikenhof Estate",
  region: "Cape Winelands · South Africa",
  address: "Eikenhof Estate, Cape Winelands, South Africa",
  mapEmbedQuery: "Eikenhof Estate, Cape Winelands, South Africa",
  mapsUrl:
    "https://www.google.com/maps/search/?api=1&query=Eikenhof+Estate+Cape+Winelands+South+Africa",
  // Optional editorial photograph, e.g. "/venue.jpg" (place the file in /static).
  image: "",
};

export interface Accommodation {
  id: string;
  name: string;
  distance: string;
  description: string;
  email: string;
  phone?: string;
  url: string;
  group: "recommended" | "nearby";
  promotion?: string;
}

export const accommodations: Accommodation[] = [
  {
    id: "kunjani-villas",
    name: "Kunjani Villas",
    distance: "Approx. 10–12 km drive",
    description: "A selection of unique villas in the heart of the Winelands.",
    email: "info@kunjani-villas.co.za",
    url: "https://www.kunjani-villas.co.za",
    group: "recommended",
    promotion: "20% discount",
  },
  {
    id: "devonvale-golf-wine-estate",
    name: "Devonvale Golf & Wine Estate",
    distance: "Approx. 8–10 km drive",
    description:
      "A scenic estate on Bottelary Road, Stellenbosch. Limited availability for our wedding dates (31 March – 2 April 2027). Contact reservations for availability.",
    email: "reservations@devonvale.co.za",
    phone: "+27 21 888 4700",
    url: "https://www.devonvale.co.za",
    group: "recommended",
  },
  {
    id: "fort-simon-estate",
    name: "Fort Simon Estate",
    distance: "Approx. 1–2 km drive",
    description:
      "Within walking distance of Eikenhof Estate. Their four-bedroom Homestead accommodates up to 8 guests and is available for exclusive self-catering stays (minimum two nights).",
    email: "IHS@fortsimonevents.co.za",
    phone: "076 228 7954",
    url: "https://www.fortsimon.com",
    group: "recommended",
  },
  {
    id: "belcharto-barn-cottages",
    name: "Belcharto Barn & Cottages",
    distance: "Approx. 3–5 km drive",
    description: "",
    email: "info@belcharto.co.za",
    phone: "064 514 0086",
    url: "https://www.belcharto.co.za",
    group: "nearby",
  },
  {
    id: "groenvlei-guest-farm",
    name: "Groenvlei Guest Farm",
    distance: "Approx. 5–7 km drive",
    description: "",
    email: "accommodation@groenvleiguestfarm.co.za",
    phone: "021 903 6277",
    url: "https://groenvlei.com",
    group: "nearby",
  },
  {
    id: "mooiplaas-wine-estate",
    name: "Mooiplaas Wine Estate",
    distance: "Approx. 7–9 km drive",
    description: "",
    email: "info@mooiplaas.co.za",
    phone: "021 200 7493",
    url: "https://mooiplaas.co.za",
    group: "nearby",
  },
  {
    id: "vine-guest-house",
    name: "Vine Guest House",
    distance: "Approx. 4–6 km drive",
    description: "",
    email: "info@vineguesthouse.co.za",
    phone: "021 865 2233",
    url: "https://vineguesthouse.co.za",
    group: "nearby",
  },
];
