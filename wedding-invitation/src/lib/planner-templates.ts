// Default checklist content for the wedding weekend planner, based on the
// couple's OneNote plan. Used to auto-seed `planner_checklist_items` the
// first time a section is opened with no rows yet. Editing these arrays
// only changes what gets seeded for *new* sections — existing rows in the
// database are the source of truth once seeded.

export interface ChecklistTemplateItem {
  subsection: string;
  label: string;
}

export const checklistTemplates: Record<string, ChecklistTemplateItem[]> = {
  master_checklist: [
    { subsection: "12 Months Before", label: "Set wedding date" },
    { subsection: "12 Months Before", label: "Confirm venue" },
    { subsection: "12 Months Before", label: "Determine budget" },
    { subsection: "12 Months Before", label: "Draft guest list" },
    { subsection: "12 Months Before", label: "Book celebrant/officiant" },
    { subsection: "9 Months Before", label: "Book photographer" },
    { subsection: "9 Months Before", label: "Book videographer" },
    { subsection: "9 Months Before", label: "Book caterer" },
    { subsection: "9 Months Before", label: "Book florist" },
    { subsection: "9 Months Before", label: "Book entertainment" },
    { subsection: "6 Months Before", label: "Send save-the-dates" },
    { subsection: "6 Months Before", label: "Book accommodation blocks" },
    { subsection: "6 Months Before", label: "Confirm wedding attire" },
    { subsection: "6 Months Before", label: "Plan honeymoon" },
    { subsection: "3 Months Before", label: "Send invitations" },
    { subsection: "3 Months Before", label: "Finalize menu" },
    { subsection: "3 Months Before", label: "Finalize décor" },
    { subsection: "3 Months Before", label: "Prepare ceremony details" },
    { subsection: "1 Month Before", label: "Confirm RSVPs" },
    { subsection: "1 Month Before", label: "Confirm seating plan" },
    { subsection: "1 Month Before", label: "Confirm vendors" },
    { subsection: "1 Month Before", label: "Finalize timeline" },
    { subsection: "1 Week Before", label: "Verify all payments" },
    { subsection: "1 Week Before", label: "Confirm supplier arrivals" },
    { subsection: "1 Week Before", label: "Print schedules" },
    { subsection: "1 Week Before", label: "Pack emergency kit" },
  ],

  guest_communications: [
    { subsection: "Save The Dates", label: "Sent" },
    { subsection: "Save The Dates", label: "Website information shared" },
    { subsection: "Invitations", label: "Sent" },
    { subsection: "Invitations", label: "RSVP deadline included" },
    { subsection: "Travel Information", label: "Estate address provided" },
    {
      subsection: "Travel Information",
      label: "Guesthouse recommendations sent",
    },
    { subsection: "Travel Information", label: "Restaurant details shared" },
    { subsection: "Travel Information", label: "Directions provided" },
  ],

  friday_arrival: [
    { subsection: "Estate Check-In", label: "Welcome signage" },
    { subsection: "Estate Check-In", label: "Room assignments" },
    { subsection: "Estate Check-In", label: "Guest contact list" },
    { subsection: "Estate Check-In", label: "Emergency numbers" },
    { subsection: "Estate Check-In", label: "Welcome bags prepared" },
    {
      subsection: "Guesthouse Coordination",
      label: "Recommendation list sent",
    },
    { subsection: "Guesthouse Coordination", label: "Maps shared" },
    {
      subsection: "Guesthouse Coordination",
      label: "Parking information supplied",
    },
  ],

  friday_supper: [
    { subsection: "Checklist", label: "Reservation confirmed" },
    { subsection: "Checklist", label: "Guest estimate provided" },
    { subsection: "Checklist", label: "Directions shared" },
    { subsection: "Checklist", label: "Parking information sent" },
    { subsection: "Checklist", label: "Reminder message sent" },
  ],

  saturday_morning: [
    { subsection: "08:00 – 11:00 Getting Ready", label: "Hair complete" },
    { subsection: "08:00 – 11:00 Getting Ready", label: "Makeup complete" },
    { subsection: "08:00 – 11:00 Getting Ready", label: "Dress ready" },
    { subsection: "08:00 – 11:00 Getting Ready", label: "Suits ready" },
    { subsection: "08:00 – 11:00 Getting Ready", label: "Rings available" },
    { subsection: "08:00 – 11:00 Getting Ready", label: "Vows available" },
    {
      subsection: "11:00 Wedding Party Breakfast",
      label: "Breakfast setup complete",
    },
    { subsection: "11:00 Wedding Party Breakfast", label: "Water available" },
    { subsection: "11:00 Wedding Party Breakfast", label: "Snacks available" },
  ],

  saturday_afternoon: [
    {
      subsection: "14:00 Welcome Drinks",
      label: "Welcome drink station ready",
    },
    { subsection: "14:00 Welcome Drinks", label: "Music playing" },
    { subsection: "14:00 Welcome Drinks", label: "Guests welcomed" },
    { subsection: "14:00 Welcome Drinks", label: "First speech ready" },
    {
      subsection: "Speech 1 — Welcome (during welcome drinks)",
      label: "Speaker confirmed",
    },
    {
      subsection: "Speech 1 — Welcome (during welcome drinks)",
      label: "Microphone available",
    },
    { subsection: "14:30 Ceremony", label: "Officiant present" },
    { subsection: "14:30 Ceremony", label: "Marriage documents ready" },
    { subsection: "14:30 Ceremony", label: "Rings available" },
    { subsection: "14:30 Ceremony", label: "Bridal party lined up" },
    { subsection: "14:30 Ceremony", label: "Photographer positioned" },
    {
      subsection: "Cocktail Hour (15:00 – 16:30)",
      label: "Drinks service active",
    },
    {
      subsection: "Cocktail Hour (15:00 – 16:30)",
      label: "Canapés circulating",
    },
    {
      subsection: "Cocktail Hour (15:00 – 16:30)",
      label: "Family photos completed",
    },
    {
      subsection: "Cocktail Hour (15:00 – 16:30)",
      label: "Couple portraits completed",
    },
    {
      subsection: "Speech 2 — during cocktail hour",
      label: "Speaker notified",
    },
    {
      subsection: "Speech 2 — during cocktail hour",
      label: "Timing confirmed",
    },
  ],

  saturday_reception: [
    {
      subsection: "Reception Seating (≈16:30)",
      label: "Seating chart displayed",
    },
    { subsection: "Reception Seating (≈16:30)", label: "Place cards set" },
    { subsection: "Reception Seating (≈16:30)", label: "Guests seated" },
    {
      subsection: "Wedding Party Entrance (≈16:45)",
      label: "Entrance music ready",
    },
    { subsection: "Wedding Party Entrance (≈16:45)", label: "MC prepared" },
    {
      subsection: "Wedding Party Entrance (≈16:45)",
      label: "Wedding party lined up",
    },
    {
      subsection: "Speech 3 — after wedding party entrance",
      label: "Speaker prepared",
    },
    {
      subsection: "Speech 3 — after wedding party entrance",
      label: "Champagne available if required",
    },
    { subsection: "Dinner Service", label: "Catering brief confirmed" },
    {
      subsection: "Dinner Service",
      label: "Dietary requirements accommodated",
    },
    { subsection: "Dinner Service", label: "Service schedule followed" },
    {
      subsection: "Speech 4 — between main course and dessert",
      label: "Speaker prepared",
    },
    {
      subsection: "Speech 4 — between main course and dessert",
      label: "Photographer ready",
    },
    { subsection: "Dance Floor Opens", label: "First dance song ready" },
    { subsection: "Dance Floor Opens", label: "Dance floor cleared" },
    { subsection: "Dance Floor Opens", label: "Entertainment ready" },
    { subsection: "Evening Celebration", label: "Late-night snacks served" },
    { subsection: "Evening Celebration", label: "Bar service confirmed" },
    { subsection: "Evening Celebration", label: "Guest transport confirmed" },
    {
      subsection: "Evening Celebration",
      label: "Accommodation guests informed",
    },
  ],

  sunday_farewell: [
    { subsection: "Checklist", label: "Restaurant booked" },
    { subsection: "Checklist", label: "Guest estimate supplied" },
    { subsection: "Checklist", label: "Reminder message sent" },
    { subsection: "Checklist", label: "Directions shared" },
    { subsection: "Wrap-Up", label: "Thank key family members" },
    { subsection: "Wrap-Up", label: "Final guest departures" },
    { subsection: "Wrap-Up", label: "Collect remaining décor" },
    { subsection: "Wrap-Up", label: "Collect gifts" },
    { subsection: "Wrap-Up", label: "Vendor final settlements confirmed" },
  ],

  reception_checklist: [
    { subsection: "Venue Setup", label: "Tables dressed" },
    { subsection: "Venue Setup", label: "Chairs placed" },
    { subsection: "Venue Setup", label: "Name cards positioned" },
    { subsection: "Venue Setup", label: "Menus positioned" },
    { subsection: "Venue Setup", label: "Candles placed" },
    { subsection: "Venue Setup", label: "Flowers installed" },
    { subsection: "Technical", label: "Speaker system tested" },
    { subsection: "Technical", label: "Microphones tested" },
    { subsection: "Technical", label: "Playlist ready" },
    { subsection: "Technical", label: "Backup playlist ready" },
  ],

  emergency_kit: [
    { subsection: "Essentials", label: "Safety pins" },
    { subsection: "Essentials", label: "Sewing kit" },
    { subsection: "Essentials", label: "Tissues" },
    { subsection: "Essentials", label: "Pain medication" },
    { subsection: "Essentials", label: "Band-aids" },
    { subsection: "Essentials", label: "Phone chargers" },
    { subsection: "Essentials", label: "Cash" },
    { subsection: "Essentials", label: "Breath mints" },
    { subsection: "Essentials", label: "Stain remover" },
    { subsection: "Essentials", label: "Extra makeup" },
  ],
};

// Default vendor roles offered when adding a new vendor.
export const vendorRoles = [
  "Photographer",
  "Videographer",
  "Florist",
  "Caterer",
  "DJ/Band",
  "Venue",
  "Transportation",
  "Other",
];

// Fixed key/value note fields shown on the Emergency & Quick Reference tab.
export const emergencyContactFields = [
  { key: "contact_venue", label: "Venue" },
  { key: "contact_photographer", label: "Photographer" },
  { key: "contact_dj", label: "DJ" },
  { key: "contact_florist", label: "Florist" },
];

export const quickReferenceFields = [
  { key: "ref_venue", label: "Venue" },
  { key: "ref_coordinator", label: "Wedding Coordinator" },
  { key: "ref_photographer", label: "Photographer" },
  { key: "ref_dj", label: "DJ" },
  { key: "ref_best_man", label: "Best Man" },
  { key: "ref_maid_of_honour", label: "Maid of Honour" },
  { key: "ref_emergency", label: "Emergency Contact" },
];

// Free-text note fields for the Friday supper and Sunday breakfast venues.
export const fridaySupperFields = [
  { key: "friday_restaurant", label: "Restaurant" },
  { key: "friday_time", label: "Reservation Time" },
  { key: "friday_address", label: "Address" },
];

export const sundayBreakfastFields = [
  { key: "sunday_restaurant", label: "Restaurant" },
  { key: "sunday_time", label: "Time" },
  { key: "sunday_expected_guests", label: "Expected Guests" },
];
