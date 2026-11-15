export interface GuestCsvRow {
  firstName: string;
  whatsappNumber: string | null;
  partnerNames: string[];
  rowNumber: number;
}

const REQUIRED_HEADERS = [
  'first_name',
  'whatsapp_number',
  'partner_1_first_name',
  'partner_2_first_name',
  'partner_3_first_name'
];

export function parseGuestCsv(csv: string): GuestCsvRow[] {
  const records: string[][] = [];
  let record: string[] = [];
  let field = '';
  let quoted = false;

  for (let index = 0; index < csv.length; index += 1) {
    const character = csv[index];
    if (quoted) {
      if (character === '"' && csv[index + 1] === '"') {
        field += '"';
        index += 1;
      } else if (character === '"') {
        quoted = false;
      } else {
        field += character;
      }
    } else if (character === '"' && field.length === 0) {
      quoted = true;
    } else if (character === ',') {
      record.push(field);
      field = '';
    } else if (character === '\n' || character === '\r') {
      if (character === '\r' && csv[index + 1] === '\n') index += 1;
      record.push(field);
      records.push(record);
      record = [];
      field = '';
    } else {
      field += character;
    }
  }

  if (quoted) throw new Error('The CSV has an unclosed quoted field.');
  if (field.length > 0 || record.length > 0) {
    record.push(field);
    records.push(record);
  }

  const header = (records.shift() ?? []).map((value, index) =>
    (index === 0 ? value.replace(/^\uFEFF/, '') : value).trim().toLowerCase()
  );
  if (REQUIRED_HEADERS.some((required) => !header.includes(required))) {
    throw new Error(`CSV must include these columns: ${REQUIRED_HEADERS.join(', ')}.`);
  }
  if (new Set(header).size !== header.length) {
    throw new Error('The CSV contains duplicate column names.');
  }

  const column = new Map(header.map((name, index) => [name, index]));
  const rows: GuestCsvRow[] = [];

  for (const [index, values] of records.entries()) {
    if (values.every((value) => !value.trim())) continue;
    if (values.length > header.length && values.slice(header.length).some((value) => value.trim())) {
      throw new Error(`Row ${index + 2} has more values than the header.`);
    }

    const get = (name: string) => values[column.get(name)!]?.trim() ?? '';
    const firstName = get('first_name');
    const partnerNames = [
      get('partner_1_first_name'),
      get('partner_2_first_name'),
      get('partner_3_first_name')
    ].filter(Boolean);

    if (!firstName) throw new Error(`Row ${index + 2} is missing first_name.`);
    rows.push({
      firstName,
      whatsappNumber: get('whatsapp_number') || null,
      partnerNames,
      rowNumber: index + 2
    });
  }

  if (rows.length === 0) throw new Error('The CSV has no guest rows to import.');
  return rows;
}
