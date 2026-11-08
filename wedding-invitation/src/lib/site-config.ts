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
    referencePrefix: "Honeymoon Fund",
  },
};

export const navLinks = [
  { href: "#wedding-day", label: "Wedding Day" },
  { href: "#venue", label: "Venue" },
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
