import { JSObject } from "../src/types";

export const cloneObjec = (object: JSObject) =>
  JSON.parse(JSON.stringify(object));

export const getSuccessResponse = (responseData: any) => ({
  data: responseData,
  status: "success",
});
