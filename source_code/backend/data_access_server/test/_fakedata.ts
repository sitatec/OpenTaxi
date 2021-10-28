const ACCOUNT_ID = "sljf45Esfjsllsfksl45"; 
export const ACCOUNT = {
  id: ACCOUNT_ID,
  first_name: "Steve",
  surname: "Jobs",
  nickname: "steve jobs",
  email: "stevejobs@apple.com",
  phone_number: 45463454354,
  notification_token: "lsjfETEjflsji4-436lsjf",
  account_status: "LIVE",
  role: "RIDER",
  balance: 0.0
};

export const ACCOUNT_1 = {
  id: ACCOUNT_ID + "1",
  first_name: "Elon",
  surname: "Musk",
  nickname: "elon musk",
  email: "elon@tesla.com",
  phone_number: 9999999999,
  notification_token: "2sjf_sEjflsji4-436lsj_",
  account_status: "LIVE",
  role: "DRIVER",
  balance: 0.0
}

export const RIDER = {
  account_id: ACCOUNT.id,
  driver_gender_preference: "FEMALE",
  recent_places: [
    "Labé",
    "Québec"
  ],
  saved_places: [
    "Labé",
    "Québec"
  ] 
};

export const DRIVER = {
  account_id: ACCOUNT_1.id,
  bio: "some fake bio sljfksjfk", // test if the bio has more than 140
  address: "fake address",
  price_by_km: 75.65,
  additional_certification_urls: ["slfjskfsfs", "lsjfldjksfs"],
  driver_licence_url: "lskfjsfs",
  proof_of_residence_url: "lsjfdkfjs",
  profile_picture_url: "sljfksf",
  alternative_phone_number: 2453675674543,
  bank_account_confirmation_url: "skldjflksjfk",
  is_south_african_citizen: true,
  is_online: false,
  other_platform_rating_url: "lsjfds",
  price_by_minunte: 29.34,
  gender: "MALE",
  id_url: "slfjlksjflks"
};

const PAYMENT_ID = 43;

export const PAYMENT = {
  payment_gateway_transaction_id: "354634643",
  amount: 45364,
  date_time: "2004-10-19T10:23:54.000Z",
  status: "SUCCESS",
  payment_type: "CARD",
  id: PAYMENT_ID,
  recipient_id: null,
  payer_id: ACCOUNT_ID
};

const BOOKING_ID = 366;

export const BOOKING = {
  departure_address: "sdf",
  destination_address: "lsdjfs",
  payment_id: PAYMENT_ID,
  booked_at: "2004-10-19T10:23:54.000Z",
  id: BOOKING_ID,
  rider_id: RIDER.account_id,
  driver_id: DRIVER.account_id
};

export const TRIP = {
  id: 1,
  status: "IN_PROGRESS",
  booking_id: BOOKING_ID,
  security_video_url: "url",
  started_at: "2004-10-19T10:23:54.000Z",
  finished_at: "2004-10-19T10:23:54.000Z"
}

export const CAR = {
  id:1,
  number_of_seats: 4,
  type: 'STANDARD',
  model: "S",
  driver_id: DRIVER.account_id,
  additional_info: "slfsf",
  registration_number: "XS-456",
  color: 'RED',
  brand: 'TESLA'
}

export const REVIEW = {
  recipient_id: DRIVER.account_id,
  id: 1,
  rating: 3,
  comment: "slfjslkf",
  author_id: RIDER.account_id
}