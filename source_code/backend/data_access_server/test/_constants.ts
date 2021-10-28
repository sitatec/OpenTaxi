import { getSuccessResponse } from "./_utils";

export const BASE_URL = "http://localhost:8080";

export const ACCOUNT_URL = `${BASE_URL}/account`;

export const RIDER_URL = `${BASE_URL}/rider`;

export const DRIVER_URL = `${BASE_URL}/driver`;

export const TRIP_URL = `${BASE_URL}/trip`;

export const BOOKING_URL = `${BASE_URL}/booking`;

export const PAYMENT_URL = `${BASE_URL}/payment`;

export const CAR_URL = `${BASE_URL}/car`;

export const REVIEW_URL = `${BASE_URL}/review`;

export const DEFAULT_SUCCESS_RESPONSE = getSuccessResponse(1);