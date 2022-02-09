const ACCOUNT_ID = "sljf45Esfjsllsfksl45";
export const ACCOUNT = {
  id: ACCOUNT_ID,
  first_name: "Steve",
  last_name: "Jobs",
  display_name: "steve jobs",
  email: "stevejobs@apple.com",
  profile_picture_url: "urltopic.jpg",
  phone_number: "45463454354",
  notification_token: "lsjfETEjflsji4-436lsjf",
  account_status: "LIVE",
  gender: "FEMALE",
  role: "RIDER",
};

export const ACCOUNT_1 = {
  id: ACCOUNT_ID + "1",
  first_name: "Elon",
  last_name: "Musk",
  display_name: "elon musk",
  email: "elon@tesla.com",
  profile_picture_url: "urltopic.jpg",
  phone_number: "9999999999",
  notification_token: "2sjf_sEjflsji4-436lsj_",
  account_status: "LIVE",
  role: "DRIVER",
  gender: "MALE",
};

export const RIDER = {
  account_id: ACCOUNT.id,
  driver_gender_preference: "FEMALE",
  balance: "122.00",
  payment_token: null,
};

export const ADDRESS = {
  id: 1,
  street_address: "slkfjs",
  street_address_line_two: "lfjs",
  postal_code: "sSFG",
  city: "CITY",
  province: "PROVINCE",
};

export const DRIVER = {
  account_id: ACCOUNT_1.id,
  bio: "some fake bio sljfksjfk", // test if the bio has more than 140
  price_by_km: "75.65",
  id_number: "id_number",
  nationality: "lskfjsfs",
  date_of_birth: "2004-10-19",
  driver_license_expiry_date: "2004-10-19",
  driver_license_number: "lsjfdkfjs",
  driver_license_code: "lsjfdkfjs",
  alternative_phone_number: "2453675674543",
  has_additional_certifications: true,
  home_address_id: ADDRESS.id,
  is_south_african_citizen: true,
  online_status: 'OFFLINE',
  price_by_minute: "29.34",
};

const PAYMENT_ID = 43;

export const PAYMENT = {
  payment_gateway_transaction_id: "354634643",
  amount: "45364.00",
  date_time: "2004-10-19T10:23:54.000Z",
  payment_type: "CARD",
  id: PAYMENT_ID,
  recipient_id: null,
  payer_id: ACCOUNT_ID,
};

const BOOKING_ID = 366;

export const BOOKING = {
  pickup_address_id: 1,
  dropoff_address_id: 2,
  payment_id: PAYMENT_ID,
  booked_at: "2004-10-19T10:23:54.000Z",
  id: BOOKING_ID,
  rider_id: RIDER.account_id,
  driver_id: DRIVER.account_id,
};

export const EMERGENCY_CONTACT = {
  id: 1,
  first_name: "fs",
  last_name: "s",
  phone_number: "3467474223",
  account_id: ACCOUNT_ID,
  is_primary: true,
};

export const BANK_ACCOUNT = {
  id: 1,
  bank_name: "FNB",
  account_type: "w",
  account_holder_name: "sfs",
  account_number: "sfslfjs",
  branch_code: "sd",
  driver_id: DRIVER.account_id,
};

export const TRIP = {
  id: 1,
  status: "STARTED",
  booking_id: BOOKING_ID,
  security_video_url: "url",
  started_at: "2004-10-19T10:23:54.000Z",
  ended_at: "2004-10-19T10:23:54.000Z",
};

export const VEHICLE = {
  id: 1,
  category: "STANDARD",
  model: "S",
  driver_id: DRIVER.account_id,
  registration_number: "XS-456",
  color: "RED",
  make: "TESLA",
  year: "2014",
  vin_number: "SFS",
  license_plate_number: "slfjslfjsdl",
  license_disk_number: "slfjslfjsdl",
  license_disk_expiry_date: "2004-10-19",
  has_inspection_report: true,
  has_insurance: true,
  speedometer_on: true,
};

export const REVIEW = {
  recipient_id: DRIVER.account_id,
  id: 1,
  rating: 3,
  comment: "slfjslkf",
  author_id: RIDER.account_id,
  trip_id: TRIP.id,
};

export const FAVORITE_PLACE = {
  id: "0",
  street_address: "addr",
  rider_id: RIDER.account_id,
  place_label: "name",
};
