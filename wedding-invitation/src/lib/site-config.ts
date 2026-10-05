// Central site configuration for copy that appears across multiple components/pages.
// Update this file as event details are confirmed.

export const site = {
  coupleNames: "Shaun & Marcel",
  names: ["Shaun", "Marcel"] as const,
  tagline: "Together with their families",
  weddingDateLabel: "3 April 2027",
  // Counts down to the start of the ceremony.
  countdownTargetIso: "2027-04-03T14:00:00+02:00",
  venueName: "Eikenhof Estate",
  region: "Cape Winelands · South Africa",
  // Shown in the RSVP section when set, e.g. "1 February 2027".
  rsvpDeadlineLabel: "",
  // Optional editorial photograph for the hero, e.g. "/hero.jpg" (place the file in /static).
  heroImage: "",
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
  { href: "#weekend", label: "Our Weekend" },
  { href: "#wedding", label: "The Wedding" },
  { href: "#venue", label: "Venue" },
  { href: "#accommodation", label: "Accommodation" },
  { href: "#rsvp", label: "RSVP" },
];

// Saturday programme. Also the source data for the "Add to Calendar" entry.
export const scheduleEvents = [
  {
    id: "welcome",
    time: "13:30",
    title: "Guest arrival & welcome drink",
    description: "Guests arrive and are welcomed with a drink.",
    startIso: "2027-04-03T13:30:00+02:00",
    endIso: "2027-04-03T14:00:00+02:00",
  },
  {
    id: "ceremony",
    time: "14:00",
    title: "Wedding ceremony",
    description: "The wedding ceremony at Eikenhof Estate.",
    startIso: "2027-04-03T14:00:00+02:00",
    endIso: "2027-04-03T14:45:00+02:00",
  },
  {
    id: "cocktails",
    time: "14:45",
    title: "Cocktails & canapés",
    description: "Cocktails and canapés.",
    startIso: "2027-04-03T14:45:00+02:00",
    endIso: "2027-04-03T16:30:00+02:00",
  },
  {
    id: "photos",
    time: "16:30",
    title: "Wedding photos & mingling",
    description: "Wedding photos and time to mingle.",
    startIso: "2027-04-03T16:30:00+02:00",
    endIso: "2027-04-03T17:15:00+02:00",
  },
  {
    id: "dinner",
    time: "17:30",
    title: "Dinner & reception",
    description: "Dinner and reception.",
    startIso: "2027-04-03T17:30:00+02:00",
    endIso: "2027-04-03T20:15:00+02:00",
  },
  {
    id: "dancing",
    time: "20:15",
    title: "Dancing & celebration",
    description: "Dancing and celebration.",
    startIso: "2027-04-03T20:15:00+02:00",
    endIso: "2027-04-04T00:00:00+02:00",
  },
  {
    id: "close",
    time: "00:00",
    title: "Reception ends",
    description: "The reception ends.",
    startIso: "2027-04-04T00:00:00+02:00",
    endIso: "2027-04-04T00:00:00+02:00",
  },
];

export const weekend = [
  {
    id: "friday",
    day: "Friday",
    date: "2 April",
    title: "Arrive & Settle In",
    description:
      "A relaxed, informal evening for guests arriving at Eikenhof Estate: a chance to meet, unwind and enjoy the surroundings.",
    note: "Evening plans to be confirmed",
  },
  {
    id: "saturday",
    day: "Saturday",
    date: "3 April",
    title: "Our Wedding Day",
    description: "The main celebration takes place on Saturday.",
    note: "",
  },
  {
    id: "sunday",
    day: "Sunday",
    date: "4 April",
    title: "Breakfast & Farewell",
    description: "A relaxed morning before check-out and heading home.",
    note: "Breakfast & check-out details to be confirmed",
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
  // Relative guide only: "$" to "$$$$". Exact 2027 rates are not published yet.
  price: string;
  url: string;
  group: "closest" | "further";
}

const search = (q: string) => `https://www.google.com/search?q=${encodeURIComponent(q)}`;

export const accommodations: Accommodation[] = [
  {
    id: "vine-guesthouse",
    name: "Vine Guesthouse",
    distance: "5–7 min",
    description: "A boutique guesthouse in Koelenhof with 12 rooms, and the closest practical option to the venue.",
    price: "$$",
    // TODO: replace with the official website link.
    url: search("Vine Guesthouse Koelenhof Stellenbosch"),
    group: "closest",
  },
  {
    id: "groenvlei-guest-farm",
    name: "Groenvlei Guest Farm",
    distance: "7–9 min",
    description: "A Winelands guest farm with five en-suite guesthouse rooms and self-catering units.",
    price: "$$",
    url: "https://groenvlei.com",
    group: "closest",
  },
  {
    id: "hazendal-hotel-spa",
    name: "Hazendal Hotel & Spa",
    distance: "8–10 min",
    description: "A hotel and spa with 34 rooms and suites: our premium hotel option.",
    price: "$$$$",
    url: "https://www.hazendal.co.za/stay/",
    group: "closest",
  },
  {
    id: "devonvale-golf-wine-estate",
    name: "Devonvale Golf & Wine Estate",
    distance: "10–12 min",
    description: "Hotel rooms, suites and holiday homes, well suited to families and groups.",
    price: "$$$",
    url: "https://devonvale.co.za/accommodation/",
    group: "closest",
  },
  {
    id: "rouana-guest-farm",
    name: "Rouana Guest Farm",
    distance: "12–15 min",
    description: "A quiet guest farm with around ten rooms and units, sleeping about twenty.",
    price: "$$",
    url: "https://rouanaguestfarm.com",
    group: "further",
  },
  {
    id: "kunjani-wines",
    name: "Kunjani Wines",
    distance: "13–16 min",
    description: "Four villas on a wine farm, ideal for groups who would like to stay together.",
    price: "$$$",
    url: "https://www.kunjaniwines.co.za",
    group: "further",
  },
  {
    id: "zevenwacht-wine-estate",
    name: "Zevenwacht Wine Estate",
    distance: "15–18 min",
    description: "Country inn suites, vineyard cottages and a self-catering chalet, good for families and larger groups.",
    price: "$$$",
    // TODO: replace with the official website link.
    url: search("Zevenwacht Wine Estate accommodation"),
    group: "further",
  },
  {
    id: "the-log-collective",
    name: "The Log Collective",
    distance: "18–20 min",
    description: "Vineyard cabins, villas and an apartment: something a little different.",
    price: "$$$",
    url: "https://thelogcollective.co.za",
    group: "further",
  },
  {
    id: "devon-valley-hotel",
    name: "Devon Valley Hotel",
    distance: "20–22 min",
    description: "A 50-room hotel, a good choice for larger numbers.",
    price: "$$$",
    url: "https://devonvalleyhotel.com",
    group: "further",
  },
  {
    id: "spier-hotel",
    name: "Spier Hotel",
    distance: "22–25 min",
    description: "A large Winelands hotel with 80 rooms and two villas, plus restaurants and a spa.",
    price: "$$$",
    url: "https://www.spier.co.za",
    group: "further",
  },
];