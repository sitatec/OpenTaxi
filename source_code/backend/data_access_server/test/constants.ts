import { getSuccessResponse } from "./utils";

export const BASE_URL = "http://localhost:8080";

export const ACCOUNT_URL = `${BASE_URL}/account`;

export const RIDER_URL = `${BASE_URL}/rider`;

export const DRIVER_URL = `${BASE_URL}/driver`;

export const TRIP_URL = `${BASE_URL}/trip`;

export const BOOKING_URL = `${BASE_URL}/booking`;

export const PAYMENT_URL = `${BASE_URL}/payment`;

export const VEHICLE_URL = `${BASE_URL}/vehicle`;

export const REVIEW_URL = `${BASE_URL}/review`;

export const ADDRESS_URL = `${BASE_URL}/address`;

export const BANK_ACCOUNT_URL = `${BASE_URL}/bank_account`;

export const EMERGENCY_CONTACT_URL = `${BASE_URL}/emergency_contact`;

export const DEFAULT_SUCCESS_RESPONSE = getSuccessResponse(1);