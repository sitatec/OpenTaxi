--------------------- ENUM TYPES CREATION ------------------- 

CREATE TYPE TRIP_STATUS AS ENUM (
  'DRIVER_ON_THE_WAY', 
  'IN_PROGRESS', 
  'FINISHED', 
  'CANCELED'
);


CREATE TYPE USER_ROLE AS ENUM (
  'RIDER',
  'DRIVER',
  'ADMIN'
);


CREATE TYPE ACCOUNT_STATUS AS ENUM (
  'LIVE',
  'WAITING_FOR_APPROVAL',
  'UNPAID_SUBSCRIPTION',
  'TEMPORARILY_SUSPENDED',
  'DEFINITIVELY_BANNED'
);


CREATE TYPE PAYMENT_TYPE AS ENUM (
  'CASH',
  'CARD',
  'PARTNER_PAYMENT',
  'kITTY_PAYMENT'
);


CREATE TYPE PAYMENT_STATUS AS ENUM (
  'SUCCESS',
  'FAILED',
  'REFUSED',
  'WAITING_FOR_CONFIRMATION'
);


CREATE TYPE CAR_TYPE AS ENUM (
  'STANDARD',
  'PREMIUM',
  'VAN',
  'SPECIALIST',
  'LITE'
);


CREATE TYPE DRIVER_GENDER_PREFERENCE AS ENUM (
  'MALE',
  'FEMALE',
  'BOTH'
);


---------------------  TABLES CREATION ---------------------


CREATE SEQUENCE public.trip_id_seq;

CREATE TABLE public.trip (
                id INTEGER NOT NULL DEFAULT nextval('public.trip_id_seq'),
                started_at TIMESTAMP,
                finished_at TIMESTAMP,
                security_video_url VARCHAR,
                status TRIP_STATUS NOT NULL,
                CONSTRAINT trip_pk PRIMARY KEY (id)
);


ALTER SEQUENCE public.trip_id_seq OWNED BY public.trip.id;

CREATE TABLE public.account (
                id VARCHAR NOT NULL,
                first_name VARCHAR NOT NULL,
                surname VARCHAR NOT NULL,
                nickname VARCHAR,
                registred_at DATE DEFAULT CURRENT_DATE NOT NULL,
                email VARCHAR NOT NULL,
                role USER_ROLE NOT NULL,
                account_status ACCOUNT_STATUS NOT NULL,
                phone_number VARCHAR NOT NULL,
                balance NUMERIC(14,2) DEFAULT 0 NOT NULL,
                CONSTRAINT account_pk PRIMARY KEY (id)
);


CREATE UNIQUE INDEX account_idx
 ON public.account
 ( email );

CREATE UNIQUE INDEX account_idx1
 ON public.account
 ( phone_number );

CREATE TABLE public.payment (
                id INTEGER NOT NULL,
                amount NUMERIC(11,2) NOT NULL,
                date_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                recipient_id VARCHAR,
                payer_id VARCHAR NOT NULL,
                status PAYMENT_STATUS NOT NULL,
                payment_type PAYMENT_TYPE NOT NULL,
                payment_gateway_transaction_id BIGINT NOT NULL,
                CONSTRAINT payment_pk PRIMARY KEY (id)
);


CREATE TABLE public.review (
                id INTEGER NOT NULL,
                author_id VARCHAR NOT NULL,
                comment VARCHAR(140),
                recipient_id VARCHAR NOT NULL,
                rating SMALLINT NOT NULL,
                CONSTRAINT review_pk PRIMARY KEY (id)
);


CREATE TABLE public.driver (
                account_id VARCHAR NOT NULL,
                idUrl VARCHAR NOT NULL,
                address VARCHAR NOT NULL,
                alternative_phone_number VARCHAR,
                is_south_african_citizen BOOLEAN NOT NULL,
                profile_picture_url VARCHAR NOT NULL,
                id_image_url VARCHAR NOT NULL,
                driver_licence_url VARCHAR NOT NULL,
                proof_of_residence_url VARCHAR NOT NULL,
                bank_account_confirmation_url VARCHAR NOT NULL,
                additional_certification_urls VARCHAR[] NOT NULL,
                other_platform_rating_url VARCHAR,
                bio VARCHAR,
                is_online BOOLEAN DEFAULT FALSE NOT NULL,
                price_by_minunte INTEGER,
                price_by_km INTEGER,
                CONSTRAINT driver_pk PRIMARY KEY (account_id)
);


CREATE SEQUENCE public.subscription_id_seq;

CREATE TABLE public.subscription (
                id INTEGER NOT NULL DEFAULT nextval('public.subscription_id_seq'),
                price NUMERIC(11,2) NOT NULL,
                started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                end_at TIMESTAMP NOT NULL,
                payment_gateway_transaction_id BIGINT NOT NULL,
                driver_id VARCHAR NOT NULL,
                CONSTRAINT subscription_pk PRIMARY KEY (id)
);


ALTER SEQUENCE public.subscription_id_seq OWNED BY public.subscription.id;

CREATE SEQUENCE public.car_id_seq;

CREATE TABLE public.car (
                id INTEGER NOT NULL DEFAULT nextval('public.car_id_seq'),
                brand VARCHAR NOT NULL,
                model VARCHAR NOT NULL,
                number_of_seats SMALLINT NOT NULL,
                additional_info VARCHAR,
                registration_number VARCHAR(15) NOT NULL,
                color VARCHAR NOT NULL,
                driver_id VARCHAR NOT NULL,
                type CAR_TYPE NOT NULL,
                CONSTRAINT car_pk PRIMARY KEY (id)
);


ALTER SEQUENCE public.car_id_seq OWNED BY public.car.id;

CREATE TABLE public.rider (
                account_id VARCHAR NOT NULL,
                driver_gender_preference DRIVER_GENDER_PREFERENCE DEFAULT 'BOTH' NOT NULL,
                recent_places VARCHAR[],
                saved_places VARCHAR[],
                CONSTRAINT rider_pk PRIMARY KEY (account_id)
);


CREATE TABLE public.favorite_driver (
                driver_id VARCHAR NOT NULL,
                rider_id VARCHAR NOT NULL,
                CONSTRAINT favorite_driver_pk PRIMARY KEY (driver_id, rider_id)
);


CREATE TABLE public.booking (
                id INTEGER NOT NULL,
                payment_id INTEGER NOT NULL,
                rider_id VARCHAR NOT NULL,
                driver_id VARCHAR NOT NULL,
                booked_at TIMESTAMP NOT NULL,
                departure_address VARCHAR NOT NULL,
                destination_address VARCHAR NOT NULL,
                trip_id INTEGER NOT NULL,
                CONSTRAINT booking_pk PRIMARY KEY (id)
);


ALTER TABLE public.booking ADD CONSTRAINT trip_booking_fk
FOREIGN KEY (trip_id)
REFERENCES public.trip (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.rider ADD CONSTRAINT account_rider_fk
FOREIGN KEY (account_id)
REFERENCES public.account (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.driver ADD CONSTRAINT account_driver_fk
FOREIGN KEY (account_id)
REFERENCES public.account (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.review ADD CONSTRAINT account_review_fk
FOREIGN KEY (author_id)
REFERENCES public.account (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.review ADD CONSTRAINT account_review_fk1
FOREIGN KEY (recipient_id)
REFERENCES public.account (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.payment ADD CONSTRAINT account_payment_fk
FOREIGN KEY (payer_id)
REFERENCES public.account (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.payment ADD CONSTRAINT account_payment_fk1
FOREIGN KEY (recipient_id)
REFERENCES public.account (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.booking ADD CONSTRAINT payment_booking_fk
FOREIGN KEY (payment_id)
REFERENCES public.payment (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.car ADD CONSTRAINT driver_car_fk
FOREIGN KEY (driver_id)
REFERENCES public.driver (account_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.booking ADD CONSTRAINT driver_booking_fk
FOREIGN KEY (driver_id)
REFERENCES public.driver (account_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.subscription ADD CONSTRAINT driver_subscription_fk
FOREIGN KEY (driver_id)
REFERENCES public.driver (account_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.favorite_driver ADD CONSTRAINT driver_favorite_driver_fk
FOREIGN KEY (driver_id)
REFERENCES public.driver (account_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.booking ADD CONSTRAINT rider_booking_fk
FOREIGN KEY (rider_id)
REFERENCES public.rider (account_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE public.favorite_driver ADD CONSTRAINT rider_favorite_driver_fk
FOREIGN KEY (rider_id)
REFERENCES public.rider (account_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;