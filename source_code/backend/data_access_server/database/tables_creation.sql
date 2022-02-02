--------------------- ENUM TYPES CREATION ------------------- 

CREATE TYPE TRIP_STATUS AS ENUM (
  'DRIVER_ON_THE_WAY',
  'DRIVER_ARRIVED_PICKUP', 
  'STARTED', 
  'ENDED', 
  'CANCELED'
);


CREATE TYPE ACCOUNT_ROLE AS ENUM (
  'RIDER',
  'DRIVER',
  'ADMIN'
);


CREATE TYPE ACCOUNT_STATUS AS ENUM (
  'LIVE',
  'WAITING_FOR_APPROVAL',
  'SUSPENDED_FOR_UNPAID',
  'TEMPORARILY_SUSPENDED',
  'DEFINITIVELY_BANNED'
);


CREATE TYPE PAYMENT_TYPE AS ENUM (
  'CASH',
  'CARD',
  'PARTNER_PAYMENT',
  'kITTY_PAYMENT'
);


CREATE TYPE VEHICLE_CATEGORY AS ENUM (
  'STANDARD',
  'PREMIUM',
  'CREW',
  'UBUNTU',
  'LITE'
);


CREATE TYPE GENDER AS ENUM (
  'MALE',
  'FEMALE'
);

CREATE TYPE SUPPORTED_BANK AS ENUM (
  'FNB', 
  'STANDARD_BANK',
  'NEDBANK', 
  'ABSA',
  'CAPITECH',
  'TYME'
);


---------------------  TABLES CREATION ---------------------


CREATE SEQUENCE public.trip_id_seq;

CREATE TABLE public.trip (
  id BIGINT NOT NULL DEFAULT nextval('public.trip_id_seq'),
  started_at TIMESTAMP,
  ended_at TIMESTAMP,
  canceled_at TIMESTAMP,
  security_video_url VARCHAR,
  booking_id BIGINT NOT NULL,
  status TRIP_STATUS NOT NULL DEFAULT 'DRIVER_ON_THE_WAY',
  CONSTRAINT trip_pk PRIMARY KEY (id)
);

ALTER SEQUENCE public.trip_id_seq OWNED BY public.trip.id;


CREATE TABLE public.account (
  id VARCHAR NOT NULL,
  first_name VARCHAR NOT NULL,
  last_name VARCHAR NOT NULL,
  display_name VARCHAR,
  registered_at DATE DEFAULT CURRENT_DATE NOT NULL,
  profile_picture_url VARCHAR NOT NULL,
  gender GENDER NOT NULL,
  email VARCHAR NOT NULL UNIQUE,
  role ACCOUNT_ROLE NOT NULL,
  notification_token VARCHAR,
  account_status ACCOUNT_STATUS NOT NULL,
  phone_number NUMERIC(15) NOT NULL UNIQUE,
  CONSTRAINT account_pk PRIMARY KEY (id)
);


CREATE SEQUENCE public.payment_id_seq;

CREATE TABLE public.payment (
  id BIGINT NOT NULL DEFAULT nextval('public.payment_id_seq'),
  amount DECIMAL(12,2) NOT NULL,
  date_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  recipient_id VARCHAR, -- FOR KITY PAYMENT AND PARTNER PAYMENT
  payer_id VARCHAR, -- NULLABLE in case the payer account is deleted, we still need the payment detail for the company.
  payment_type PAYMENT_TYPE NOT NULL,
  payment_gateway_transaction_id BIGINT NOT NULL,
  CONSTRAINT payment_pk PRIMARY KEY (id)
);

ALTER SEQUENCE public.payment_id_seq OWNED BY public.payment.id;


CREATE SEQUENCE public.review_id_seq;

CREATE TABLE public.review (
  id BIGINT NOT NULL DEFAULT nextval('public.review_id_seq'),
  author_id VARCHAR,
  recipient_id VARCHAR,
  trip_id INTEGER NOT NULL,
  comment VARCHAR(140),
  rating SMALLINT NOT NULL,
  CONSTRAINT review_pk PRIMARY KEY (id)
);

ALTER SEQUENCE public.review_id_seq OWNED BY public.review.id;


CREATE TABLE public.driver (
  account_id VARCHAR NOT NULL,
  id_number VARCHAR NOT NULL,
  nationality VARCHAR NOT NULL,
  date_of_birth DATE NOT NULL,
  alternative_phone_number NUMERIC(15),
  is_south_african_citizen BOOLEAN NOT NULL,
  driver_license_number VARCHAR NOT NULL,
  driver_license_code VARCHAR NOT NULL,
  driver_license_expiry_date DATE NOT NULL,
  has_additional_certifications BOOLEAN NOT NULL,
  home_address_id INTEGER NOT NULL,
  bio VARCHAR(160),
  is_online BOOLEAN DEFAULT FALSE NOT NULL,
  price_by_minute DECIMAL(9,2),
  price_by_km DECIMAL(9,2),
  CONSTRAINT driver_pk PRIMARY KEY (account_id)
);


CREATE SEQUENCE public.vehicle_id_seq;

CREATE TABLE public.vehicle (
  id INTEGER NOT NULL DEFAULT nextval('public.vehicle_id_seq'),
  make VARCHAR NOT NULL,
  model VARCHAR NOT NULL,
  year NUMERIC(4) NOT NULL,
  registration_number VARCHAR NOT NULL,
  vin_number VARCHAR NOT NULL,
  license_plate_number VARCHAR NOT NULL,
  license_disk_number VARCHAR NOT NULL,
  license_disk_expiry_date DATE NOT NULL,
  has_inspection_report BOOLEAN NOT NULL,
  has_insurance BOOLEAN NOT NULL,
  speedometer_on BOOLEAN NOT NULL,
  color VARCHAR NOT NULL,
  driver_id VARCHAR NOT NULL,
  category VEHICLE_CATEGORY NOT NULL,
  CONSTRAINT vehicle_pk PRIMARY KEY (id)
);

ALTER SEQUENCE public.vehicle_id_seq OWNED BY public.vehicle.id;


CREATE TABLE public.rider (
  account_id VARCHAR NOT NULL,
  driver_gender_preference GENDER,
  payment_token VARCHAR,
  balance DECIMAL(14,2) DEFAULT 0 NOT NULL,  
  CONSTRAINT rider_pk PRIMARY KEY (account_id)
);


CREATE TABLE public.favorite_driver (
  driver_id VARCHAR NOT NULL,
  rider_id VARCHAR NOT NULL,
  CONSTRAINT favorite_driver_pk PRIMARY KEY (driver_id, rider_id)
);


CREATE SEQUENCE public.booking_id_seq;

CREATE TABLE public.booking (
  id BIGINT NOT NULL DEFAULT nextval('public.booking_id_seq'),
  payment_id BIGINT,
  rider_id VARCHAR,-- NULLABLE in case the rider account is deleted, the company still needs the booking details.
  driver_id VARCHAR,
  booked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  start_timestamp TIMESTAMP, -- FOR future bookings
  pickup_address_id BIGINT NOT NULL,
  dropoff_address_id BIGINT NOT NULL,
  CONSTRAINT booking_pk PRIMARY KEY (id)
);

ALTER SEQUENCE public.booking_id_seq OWNED BY public.booking.id;


CREATE TABLE public.booking_stop_address(
  booking_id BIGINT NOT NULL,
  address_id BIGINT NOT NULL,
  CONSTRAINT booking_stop_addresses_pk PRIMARY KEY (booking_id, address_id)
)


CREATE SEQUENCE public.address_id_seq;

CREATE TABLE public.address (
  id BIGINT NOT NULL DEFAULT nextval('public.address_id_seq'),
  street_address VARCHAR NOT NULL,
  street_address_line_two VARCHAR,
  postal_code VARCHAR NOT NULL,
  city VARCHAR NOT NULL,
  province VARCHAR NOT NULL,
  CONSTRAINT address_pk PRIMARY KEY (id)
);

ALTER SEQUENCE public.address_id_seq OWNED BY public.address.id;


CREATE SEQUENCE public.favorite_place_id_seq;

CREATE TABLE public.favorite_place (
  id BIGINT NOT NULL DEFAULT nextval('public.favorite_place_id_seq'),
  street_address VARCHAR NOT NULL,
  rider_id VARCHAR NOT NULL,
  place_label VARCHAR NOT NULL,
  CONSTRAINT favorite_place_pk PRIMARY KEY (id)
);

ALTER SEQUENCE public.favorite_place_id_seq OWNED BY public.favorite_place.id;


CREATE SEQUENCE public.emergency_contact_id_seq;

CREATE TABLE public.emergency_contact (
  id BIGINT NOT NULL DEFAULT nextval('public.emergency_contact_id_seq'),
  first_name VARCHAR NOT NULL,
  last_name VARCHAR NOT NULL,
  phone_number NUMERIC(15) NOT NULL,
  account_id VARCHAR NOT NULL,
  is_primary BOOLEAN NOT NULL,
  CONSTRAINT emergency_contact_pk PRIMARY KEY (id)
);

ALTER SEQUENCE public.emergency_contact_id_seq OWNED BY public.emergency_contact.id;


CREATE SEQUENCE public.bank_account_id_seq;

CREATE TABLE public.bank_account (
  id INTEGER NOT NULL DEFAULT nextval('public.bank_account_id_seq'),
  bank_name SUPPORTED_BANK NOT NULL,
  account_type VARCHAR,
  account_holder_name VARCHAR NOT NULL,
  account_number VARCHAR NOT NULL,
  branch_code VARCHAR NOT NULL,
  driver_id VARCHAR NOT NULL,
  CONSTRAINT bank_account_pk PRIMARY KEY (id)
);

ALTER SEQUENCE public.bank_account_id_seq OWNED BY public.bank_account.id;

------------------------------ CONSTRAINTS --------------------------------

ALTER TABLE public.bank_account ADD CONSTRAINT bank_account_driver_fk
FOREIGN KEY (driver_id)
REFERENCES public.driver (account_id)
ON DELETE CASCADE
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.emergency_contact ADD CONSTRAINT emergency_contact_account_fk
FOREIGN KEY (account_id)
REFERENCES public.account (id)
ON DELETE CASCADE
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.favorite_place ADD CONSTRAINT favorite_place_rider_fk
FOREIGN KEY (rider_id)
REFERENCES public.rider (account_id)
ON DELETE CASCADE
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- TODO make sure when deleting the driver to delete his address
ALTER TABLE public.driver ADD CONSTRAINT driver_home_address_fk
FOREIGN KEY (home_address_id)
REFERENCES public.address (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.booking ADD CONSTRAINT booking_dropoff_addr_fk
FOREIGN KEY (dropoff_address_id)
REFERENCES public.address (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.booking ADD CONSTRAINT booking_pickup_addr_fk
FOREIGN KEY (pickup_address_id)
REFERENCES public.address (id)
ON UPDATE NO ACTION
ON DELETE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.booking_stop_address ADD CONSTRAINT booking_stop_address_address_id
FOREIGN KEY (address_id)
REFERENCES public.address (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE

ALTER TABLE public.booking_stop_address ADD CONSTRAINT booking_stop_address_booking_id
FOREIGN KEY (booking_id)
REFERENCES public.booking (id)
ON DELETE CASCADE
ON UPDATE NO ACTION
NOT DEFERRABLE

ALTER TABLE public.trip ADD CONSTRAINT booking_trip_fk
FOREIGN KEY (booking_id)
REFERENCES public.booking (id)
ON DELETE CASCADE
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.rider ADD CONSTRAINT account_rider_fk
FOREIGN KEY (account_id)
REFERENCES public.account (id)
ON DELETE CASCADE
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.driver ADD CONSTRAINT account_driver_fk
FOREIGN KEY (account_id)
REFERENCES public.account (id)
ON DELETE CASCADE
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.review ADD CONSTRAINT account_review_author_fk
FOREIGN KEY (author_id)
REFERENCES public.account (id)
ON DELETE SET NULL
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.review ADD CONSTRAINT account_review_recipient_fk
FOREIGN KEY (recipient_id)
REFERENCES public.account (id)
ON DELETE SET NULL
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.review ADD CONSTRAINT trip_review_fk
FOREIGN KEY (trip_id)
REFERENCES public.review (id)
ON DELETE CASCADE
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.payment ADD CONSTRAINT account_payment_payer_fk
FOREIGN KEY (payer_id)
REFERENCES public.account (id)
ON DELETE SET NULL
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.payment ADD CONSTRAINT account_payment_recipient_fk
FOREIGN KEY (recipient_id)
REFERENCES public.account (id)
ON DELETE SET NULL
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.booking ADD CONSTRAINT payment_booking_fk
FOREIGN KEY (payment_id)
REFERENCES public.payment (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.vehicle ADD CONSTRAINT driver_vehicle_fk
FOREIGN KEY (driver_id)
REFERENCES public.driver (account_id)
ON DELETE CASCADE
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.booking ADD CONSTRAINT driver_booking_fk
FOREIGN KEY (driver_id)
REFERENCES public.driver (account_id)
ON DELETE SET NULL
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.favorite_driver ADD CONSTRAINT driver_favorite_driver_fk
FOREIGN KEY (driver_id)
REFERENCES public.driver (account_id)
ON DELETE CASCADE
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.booking ADD CONSTRAINT rider_booking_fk
FOREIGN KEY (rider_id)
REFERENCES public.rider (account_id)
ON DELETE SET NULL
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.favorite_driver ADD CONSTRAINT rider_favorite_driver_fk
FOREIGN KEY (rider_id)
REFERENCES public.rider (account_id)
ON DELETE CASCADE
ON UPDATE NO ACTION
NOT DEFERRABLE;