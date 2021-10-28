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

export const RIDER = {
  account_id: ACCOUNT_ID,
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
  account_id: ACCOUNT_ID,
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