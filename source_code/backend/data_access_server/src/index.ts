import express from "express";
import userRoute from "./routes/user";

const app = express()

app.use((req, res, next) => {

  next();
});

app.delete('/', (req, res, next) => {

  next();
});

app.use("/user", userRoute);


const PORT = process.env.PORT || 8080;

app.listen(PORT,() => {
  console.log(`Server started and listening ${PORT} port.`)
});
