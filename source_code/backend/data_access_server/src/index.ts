import express from "express";
import DriverRouter from "./routes/driver_route";
import UserRouter from "./routes/user_route";
import { isAdminUser, validateToken } from "./security";
import { extractTokenFromHeader } from "./utils/http_utils";

const app = express();

app.use(async (req, res, next) => {
  const token = extractTokenFromHeader(req.headers);
  if (!token) {
    res.status(401).end();
  }
  const tokenValidationResult = await validateToken(token as string);
  if (!tokenValidationResult.isValidToken) {
    res.status(401).end();
  } else {
    res.locals.userId = tokenValidationResult.userId;
    next();
  }
});

app.delete("/", async (req, res, next) => {
  const isAdmin = await isAdminUser(res.locals.userId);
  if (!isAdmin) {
    res.status(401).end();
  } else {
    res.locals.role = "admin";
    next();
  }
});


app.use("/user", UserRouter);
app.use("/driver", DriverRouter);

const PORT = process.env.PORT || 8080;

app.listen(PORT, () => {
  console.log(`Server started and listening ${PORT} port.`);
});
